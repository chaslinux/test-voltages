#!/bin/bash
# battery_runtime.sh
# Estimate battery runtime in minutes and hours using upower

# Find battery device automatically
BATTERY=$(upower -e | grep -i "battery" | head -n1)

if [ -z "$BATTERY" ]; then
    echo "No battery found!"
    exit 1
fi

# Get battery state
STATE=$(upower -i "$BATTERY" | grep "state:" | awk '{print $2}')

# Get current energy (Wh) and consumption rate (W)
ENERGY=$(upower -i "$BATTERY" | grep "energy:" | head -n1 | awk '{print $2}')
RATE=$(upower -i "$BATTERY" | grep "energy-rate:" | awk '{print $2}')

# Check if RATE is zero to avoid division by zero
if [ "$RATE" = "0" ]; then
    echo "Battery not discharging or energy rate is zero. Cannot estimate runtime."
    exit 1
fi

# Calculate hours and minutes
HOURS=$(echo "$ENERGY / $RATE" | bc -l)
MINUTES=$(echo "$HOURS * 60" | bc)

# Format output
printf "Battery state: %s\n" "$STATE"
printf "Approx battery runtime: %.0f minutes (~%.1f hours)\n" "$MINUTES" "$HOURS"

