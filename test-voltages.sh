#!/bin/bash
# test-voltages.sh
# Multi-battery runtime monitor with HH:MM format

# Find all batteries
BATTERIES=$(upower -e | grep -i "battery")

if [ -z "$BATTERIES" ]; then
    echo "No battery found!"
    exit 1
fi

TOTAL_ENERGY=0
TOTAL_RATE=0

echo "Battery status:"

for BAT in $BATTERIES; do
    # Get battery info
    NAME=$(upower -i "$BAT" | grep "model:" | awk '{$1=""; print $0}' | sed 's/^ *//')
    STATE=$(upower -i "$BAT" | grep "state:" | awk '{print $2}')
    ENERGY=$(upower -i "$BAT" | grep "energy:" | head -n1 | awk '{print $2}')
    RATE=$(upower -i "$BAT" | grep "energy-rate:" | awk '{print $2}')

    # Default values if missing
    ENERGY=${ENERGY:-0}
    RATE=${RATE:-0}

    # Add to totals
    TOTAL_ENERGY=$(echo "$TOTAL_ENERGY + $ENERGY" | bc)
    TOTAL_RATE=$(echo "$TOTAL_RATE + $RATE" | bc)

    # Calculate per-battery runtime
    if (( $(echo "$RATE == 0" | bc -l) )); then
        RUNTIME="N/A"
        ENERGY_FMT="$ENERGY"
        RATE_FMT="$RATE"
    else
        HOURS=$(echo "$ENERGY / $RATE" | bc -l)
        MINUTES=$(echo "$HOURS * 60" | bc)
        HH=$(printf "%02d" $(echo "$MINUTES / 60" | bc))
        MM=$(printf "%02d" $(echo "$MINUTES % 60" | bc))
        RUNTIME="${HH}:${MM}"
        ENERGY_FMT=$(printf "%.2f" "$ENERGY")
        RATE_FMT=$(printf "%.2f" "$RATE")
    fi

    printf "- %s: State=%s, Energy=%sWh, Rate=%sW, Runtime=%s\n" "$NAME" "$STATE" "$ENERGY_FMT" "$RATE_FMT" "$RUNTIME"
done  # <- close the for loop

# Calculate total runtime
if (( $(echo "$TOTAL_RATE == 0" | bc -l) )); then
    TOTAL_RUNTIME="N/A"
else
    TOTAL_HOURS=$(echo "$TOTAL_ENERGY / $TOTAL_RATE" | bc -l)
    TOTAL_MINUTES=$(echo "$TOTAL_HOURS * 60" | bc)
    TOTAL_HH=$(printf "%02d" $(echo "$TOTAL_MINUTES / 60" | bc))
    TOTAL_MM=$(printf "%02d" $(echo "$TOTAL_MINUTES % 60" | bc))
    TOTAL_RUNTIME="${TOTAL_HH}:${TOTAL_MM}"
fi

# Format total energy/rate safely
TOTAL_ENERGY_FMT=$(printf "%.2f" "$TOTAL_ENERGY")
TOTAL_RATE_FMT=$(printf "%.2f" "$TOTAL_RATE")

printf "\nTotal: Energy=%sWh, Rate=%sW, Combined Runtime=%s\n" "$TOTAL_ENERGY_FMT" "$TOTAL_RATE_FMT" "$TOTAL_RUNTIME"

