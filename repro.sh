#!/bin/bash
magick -size 254x400 gradient: test_pattern.jpg
PYTHONPATH=src python -m autoforge \
  --input_image=test_pattern.jpg \
  --csv_file=polylite-abs-owned.csv \
  --output_folder=out/test_pattern \
  --solver_size=200 \
  --iterations=100