#!/usr/bin/env python3

import sys
import json
import argparse
from collections import defaultdict

def parse_hfp_file(filename):
    """Parse an HFP file to get color usage information."""
    with open(filename) as f:
        data = json.load(f)
    
    # Store full color info from the HFP file
    colors = [{
        "brand": color["Brand"],
        "type": color["Type"],
        "color": color["Color"],
        "name": color["Name"],
        "uuid": color["uuid"]
    } for color in reversed(data["filament_set"])]
    start_layers = data.get("slider_values", [])
    
    background_color = colors[0]

    # Calculate layer counts for each color
    color_layers = defaultdict(int)

    # Background color is used from 0 to first slider value
    color_key = json.dumps(background_color)  # Use JSON string as dict key
    color_layers[color_key] = int(float(start_layers[0]))

    # For each color, count layers from its start to the next color's start
    for i in range(1, len(start_layers)):
        current_color = colors[i]
        current_key = json.dumps(current_color)
        current_start = int(float(start_layers[i-1]))
        next_start = int(float(start_layers[i]))

        if next_start < current_start:
            print(f"Error: Next start layer {next_start} is less than current start layer {current_start}")
            continue

        color_layers[current_key] += next_start - current_start
        
    return background_color, dict(color_layers)

def parse_args():
    """Parse command line arguments."""
    parser = argparse.ArgumentParser(description='Analyze color usage in an HFP file.')
    parser.add_argument('hfp_file', help='Input HFP file')
    parser.add_argument('-n', '--num-colors', type=int, help='Number of colors to output (default: all)')
    return parser.parse_args()

def get_color_info(hfp_file, num_colors=None):
    """Get color information from HFP file and return sorted list of colors with layer counts."""
    background_color, color_layers = parse_hfp_file(hfp_file)
    
    # Convert the defaultdict keys back to dicts
    color_info = [(json.loads(color_key), count) for color_key, count in color_layers.items()]
    
    # Sort by layer count
    color_info.sort(key=lambda x: x[1], reverse=True)
    
    # Limit the number of colors if specified
    if num_colors is not None:
        color_info = color_info[:num_colors]
    
    return color_info

def print_csv(color_info):
    """Print color information in CSV format."""
    print("Brand, Type, Color, Name, TD, Owned, Uuid")
    
    for color_dict, count in color_info:
        print(f"{color_dict['brand']},{color_dict['type']},{color_dict['color']},{color_dict['name']},{count},false,{color_dict['uuid']}")

def main():
    args = parse_args()

    try:
        color_info = get_color_info(args.hfp_file, args.num_colors)
        print_csv(color_info)
    except FileNotFoundError:
        print(f"Error: File '{args.hfp_file}' not found", file=sys.stderr)
        sys.exit(1)
    except ValueError as e:
        print(f"Error: {str(e)}", file=sys.stderr)
        sys.exit(1)
    except Exception as e:
        print(f"Error processing file: {e}", file=sys.stderr)
        sys.exit(1)

if __name__ == '__main__':
    main() 