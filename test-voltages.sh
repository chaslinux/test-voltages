#!/bin/bash
BATTERY=$(upower -e | grep -i "battery" | head -n1)

if [ -z "$BATTERY" ]; then
    echo "No battery found!"
    exit 1
fi

STATE=$(upower -i "$BATTERY" | grep "state:" | awk '{print $2}')

# Convert possible scientific notation to normal float
ENERGY=$(upower -i "$BATTERY" | grep "energy:" | head -n1 | awk '{printf "%.6f", $2}')
RATE=$(upower -i "$BATTERY" | grep "energy-rate:" | awk '{printf "%.6f", $2}')

if (( $(echo "$RATE == 0" | bc -l) )); then
    echo "Battery not discharging, cannot estimate runtime."
    exit 1
fi

HOURS=$(echo "$ENERGY / $RATE" | bc -l)
MINUTES=$(echo "$HOURS * 60" | bc)
HH=$(printf "%02d" $(echo "$MINUTES / 60" | bc))
MM=$(printf "%02d" $(echo "$MINUTES % 60" | bc))

printf "Battery state: %s\n" "$STATE"
printf "Approx runtime: %.2f hours (%s:%s HH:MM)\n" "$HOURS" "$HH" "$MM"

