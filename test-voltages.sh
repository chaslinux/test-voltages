#!/bin/bash
# Estimate battery runtime in minutes and hours using upower

# Find the battery device
BATTERY=$(upower -e | grep -i "battery" | head -n1)

# Get current energy (Wh) and consumption rate (W)
ENERGY=$(upower -i "$BATTERY" | grep "energy:" | head -n1 | awk '{print $2}')
RATE=$(upower -i "$BATTERY" | grep "energy-rate:" | awk '{print $2}')

# Check for zero rate
if [ "$RATE" = "0" ] || [ -z "$RATE" ]; then
    echo "Battery not discharging or energy rate is zero. Cannot estimate runtime."
    exit 1
fi

# Calculate hours and minutes
HOURS=$(echo "$ENERGY / $RATE" | bc -l)
MINUTES=$(echo "$HOURS * 60" | bc)

# Format output
echo "Approx battery runtime: $(printf "%.0f" $MINUTES) minutes (~$(printf "%.1f" $HOURS) hours)"

