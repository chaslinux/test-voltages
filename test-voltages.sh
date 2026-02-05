#!/bin/bash

# Get all battery paths
BPATHS=($(upower -e | grep BAT))

# Initialize voltage array
voltages=()

# Loop over batteries and get voltages
for bat in "${BPATHS[@]}"; do
    # Extract numeric voltage only
    voltage=$(upower -i "$bat" | grep 'voltage:' | awk '{print $2}')
    voltages+=("$voltage")
done

# Print all voltages
for i in "${!voltages[@]}"; do
    echo "Battery $i voltage: ${voltages[$i]}"
done


