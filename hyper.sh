#!/bin/bash

# Configuration variables
IMAGE_INDEX=3  # Index of the image to process (0-based)
SOLVER_SIZE=200
VISUALIZE=false
CSV_FILE=polylite-abs-owned.csv
ITERATIONS_VALUES=(1000 2000 3000 4000)

source venv/bin/activate

# Get jpg/jpeg images from "in" dir
image_list=($(ls in/*.{jpg,jpeg} 2>/dev/null))

# Display available images with their indices
echo "Available images:"
for i in "${!image_list[@]}"; do
    echo "[$i] ${image_list[$i]}"
done
echo

# Check if the selected index is valid
if [ $IMAGE_INDEX -ge ${#image_list[@]} ]; then
    echo "Error: IMAGE_INDEX ($IMAGE_INDEX) is out of range. Only ${#image_list[@]} images available."
    exit 1
fi

# Process only the selected image
img="${image_list[$IMAGE_INDEX]}"

# Get filename without extension and path
filename=$(basename "$img")
name="${filename%.*}"

# Iterate over max_tau values
for iterations in "${ITERATIONS_VALUES[@]}"; do
    echo "Processing with min_tau = $iterations"
    
    # Create output directory with max_tau suffix
    out_dir="out/${name}_tau${max_tau}"
    mkdir -p "$out_dir"

    # Build command arguments
    args=(
        --input_image="$img"
        --csv_file=$CSV_FILE
        --output_folder="$out_dir"
        --iterations=$iterations
        --solver_size=$SOLVER_SIZE
        --random_seed=24
    )

    # Add visualization flag if enabled
    if [ "$VISUALIZE" = true ]; then
        args+=(--visualize)
    fi

    # Run autoforge
    set -x
    PYTHONPATH=src python -m autoforge "${args[@]}"
    set +x
done
