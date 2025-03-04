#!/bin/sh

# Check if a file is provided as an argument
if [ $# -ne 1 ]; then
    echo "Usage: $0 swap_instructions.txt"
    exit 1
fi

# Check if the file exists
if [ ! -f "$1" ]; then
    echo "Error: File '$1' not found"
    exit 1
fi

# Create a temporary file to store color counts
tmp_file=$(mktemp)
trap 'rm -f $tmp_file' EXIT

# Process the file and count layers for each color
current_color="background color"
last_layer=0
max_layer=0

# Get the first color mentioned after "swap to" as that will be the background color's name
background_name=$(grep -m 1 "swap to" "$1" | sed 's/.*swap to //')

# Initialize the temporary file with tab separator
printf "%s\t%d\n" "$background_name" 0 > "$tmp_file"

while IFS= read -r line; do
    if [ "${line#At layer}" != "$line" ]; then
        # Extract layer number
        layer=$(echo "$line" | sed 's/.*#\([0-9]*\).*/\1/')
        # Extract next color
        next_color=$(echo "$line" | sed 's/.*swap to //')
        
        # Update max layer
        if [ "$layer" -gt "$max_layer" ]; then
            max_layer=$layer
        fi
        
        # Calculate layers for current color
        layer_count=$((layer - last_layer))
        
        # Update count for current color
        found=0
        while IFS="$(printf '\t')" read -r color count; do
            if [ "$color" = "$current_color" ]; then
                new_count=$((count + layer_count))
                # Use tab as separator for sed
                sed -i.bak "s/^$color$(printf '\t').*/$color$(printf '\t')$new_count/" "$tmp_file"
                found=1
                break
            fi
        done < "$tmp_file"
        
        if [ $found -eq 0 ]; then
            printf "%s\t%d\n" "$current_color" "$layer_count" >> "$tmp_file"
        fi
        
        # Update tracking variables
        current_color="$next_color"
        last_layer=$layer
        
    elif [ "${line#For the rest}" != "$line" ]; then
        # Handle remaining layers for current color
        layer_count=$((max_layer - last_layer))
        final_color=$(echo "$line" | sed 's/For the rest, use //')
        
        # Update count for current color
        found=0
        while IFS="$(printf '\t')" read -r color count; do
            if [ "$color" = "$current_color" ]; then
                new_count=$((count + layer_count))
                sed -i.bak "s/^$color$(printf '\t').*/$color$(printf '\t')$new_count/" "$tmp_file"
                found=1
                break
            fi
        done < "$tmp_file"
        
        if [ $found -eq 0 ]; then
            printf "%s\t%d\n" "$current_color" "$layer_count" >> "$tmp_file"
        fi
        
        # Add 100 layers for the final color
        found=0
        while IFS="$(printf '\t')" read -r color count; do
            if [ "$color" = "$final_color" ]; then
                new_count=$((count + 100))
                sed -i.bak "s/^$color$(printf '\t').*/$color$(printf '\t')$new_count/" "$tmp_file"
                found=1
                break
            fi
        done < "$tmp_file"
        
        if [ $found -eq 0 ]; then
            printf "%s\t%d\n" "$final_color" 100 >> "$tmp_file"
        fi
    fi
done < "$1"

# Print the background color with its count
while IFS="$(printf '\t')" read -r color count; do
    if [ "$color" = "$background_name" ]; then
        printf "%s (background, %d layers)\n" "$color" "$count"
        break
    fi
done < "$tmp_file"

# Print the top 3 non-background colors
grep -v "^$background_name$(printf '\t')" "$tmp_file" | sort -t"$(printf '\t')" -k2,2nr | head -n 3 | while IFS="$(printf '\t')" read -r color count; do
    printf "%s\n" "$color"
done