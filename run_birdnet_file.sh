#!/bin/bash

INPUT="/data/P-Prosjekter/41201775_nasjonal_insektovervaking/2025/analysis/rawData/acoustic_data/SMA07666/Data/SMA07666_20250707_171202.wav"
OUTPUT="./output/NorIns"

exec uv run birdnet-analyze "$INPUT" -o "$OUTPUT"
