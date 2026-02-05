#!/bin/bash
# test-voltages.sh

BATTERY=$(upower -e | grep -i "battery" | head -n1)

if [ -z "$BATTERY" ]; then
    echo "No battery found!"
    exit 1
fi

STATE=$(upower -i "$BATTERY" | grep "state:" | awk '{print $2}')
ENERGY=$(upower -i "$BATTERY" | grep "energy:" | head -n1 | awk '{print $2}')
RATE=$(upower -i "$BATTERY" | grep "energy-rate:" | awk '{print $2}')

if [ "$RATE" = "0" ] || [ -z "$RATE" ]; then
    echo "Battery not discharging, cannot estimate runtime."
    exit 1
fi

HOURS=$(echo "$ENERGY / $RATE" | bc -l)
MINUTES=$(echo "$HOURS * 60" | bc)

HH=$(printf "%02d" $(echo "$MINUTES / 60" | bc))
MM=$(printf "%02d" $(echo "$MINUTES % 60" | bc))

printf "Battery state: %s\n" "$STATE"
printf "Approx runtime: %s hours (%s:%s HH:MM)\n" "$(printf "%.2f" "$HOURS")" "$HH" "$MM"

