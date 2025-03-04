#!/bin/bash

# Configuration variables

SOLVER_SIZE=200
NUM_ITERATIONS=4000
VISUALIZE=false
CSV_FILE=polylite-abs-owned.csv

source venv/bin/activate

# Get and shuffle jpg/jpeg images from "in" dir
#image_list=($(ls in/*.{jpg,jpeg} 2>/dev/null | shuf))
image_list=($(ls in/*.{jpg,jpeg} 2>/dev/null))

# Process images in shuffled order
for img in "${image_list[@]}"; do
    # Get filename without extension and path
    filename=$(basename "$img")
    name="${filename%.*}"

    # Create output directory
    mkdir -p "out/$name"

    # Build command arguments
    args=(
        --input_image="$img"
        --csv_file=$CSV_FILE
        --output_folder="out/$name"
        --iterations=$NUM_ITERATIONS
        --solver_size=$SOLVER_SIZE
        --random_seed=0
    )

    # Add visualization flag if enabled
    if [ "$VISUALIZE" = true ]; then
        args+=(--visualize)
    fi
    
    # Run autoforge
    PYTHONPATH=src python -m autoforge "${args[@]}"
done
