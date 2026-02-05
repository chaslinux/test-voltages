#!/bin/bash

# Get all battery paths
BPATHS=($(upower -e | grep BAT))
VVAL=0

# Initialize voltage array
voltages=()

# Loop over batteries and get voltages
for bat in "${BPATHS[@]}"; do
    voltage=$(upower -i "$bat" | grep 'voltage:' | awk '{print $2 " " $3}')
    voltages+=("$voltage")
done

# Print all voltages
for i in "${!voltages[@]}"; do
    echo "Battery $i voltage: ${voltages[$i]}"
done

