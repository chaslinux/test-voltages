#!/bin/bash
# test-voltages.sh
# Multi-battery runtime monitor with HH:MM format
# Works on systems with one or more batteries

# Find all batteries
BATTERIES=$(upower -e | grep -i "battery")

if [ -z "$BATTERIES" ]; then
    echo "No battery found!"
    exit 1
fi

TOTAL_ENERGY=0
TOTAL_RATE=0

echo "Battery status:"

# Loop through each battery
for BAT in $BATTERIES; do
    NAME=$(upower -i "$BAT" | grep "model:" | awk '{$1=""; print $0}' | sed 's/^ *//')
    STATE=$(upower -i "$BAT" | grep "state:" | awk '{print $2}')
    ENERGY=$(upower -i "$BAT" | grep "energy:" | head -n1 | awk '{print $2}')
    RATE=$(upower -i "$BAT" | grep "energy-rate:" | awk '{print $2}')

    # Add to totals
    TOTAL_ENERGY=$(echo "$TOTAL_ENERGY + $ENERGY" | bc)
    TOTAL_RATE=$(echo "$TOTAL_RATE + $RATE" | bc)

    # Calculate runtime for this battery
    if [ "$RATE" = "0" ]; then
        RUNTIME="N/A"
    else
        HOURS=$(echo "$ENERGY / $RATE" | bc -l)
        MINUTES=$(echo "$HOURS * 60" | bc)
        HH=$(printf "%02d" $(echo "$MINUTES / 60" | bc))
        MM=$(printf "%02d" $(echo "$MINUTES % 60" | bc))
        RUNTIME="${HH}:${MM}"
    fi

    printf "- %s: State=%s, Energy=%.2fWh, Rate=%.2fW, Runtime=%s\n" "$NAME" "$STATE" "$ENERGY" "$RATE" "$RUNTIME"
done

# Total combined runtime
if [ "$TOTAL_RATE" = "0" ]; then
    TOTAL_RUNTIME="N/A"
else
    TOTAL_HOURS=$(echo "$TOTAL_ENERGY / $TOTAL_RATE" | bc -l)
    TOTAL_MINUTES=$(echo "$TOTAL_HOURS * 60" | bc)
    TOTAL_HH=$(printf "%02d" $(echo "$TOTAL_MINUTES / 60" | bc))
    TOTAL_MM=$(printf "%02d" $(echo "$TOTAL_MINUTES % 60" | bc))
    TOTAL_RUNTIME="${TOTAL_HH}:${TOTAL_MM}"
fi

printf "\nTotal: Energy=%.2fWh, Rate=%.2fW, Combined Runtime=%s\n" "$TOTAL_ENERGY" "$TOTAL_RATE" "$TOTAL_RUNTIME"


