#!/bin/bash

INPUT="path/to/local/audio/file.wav"
OUTPUT="./output/"

exec uv run birdnet-analyze "$INPUT" -o "$OUTPUT"
