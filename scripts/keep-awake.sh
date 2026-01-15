#!/bin/bash

# keep-awake.sh
# Prevents macOS from going to sleep by simulating user activity via AppleScript
# Useful when machine has banned apps like Amphetamine, Caffeine, and caffeinate command

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Interval between checks (in seconds)
# Default: 30 seconds (checks idle time every 30s)
INTERVAL="${KEEP_AWAKE_INTERVAL:-30}"

# Idle threshold before moving mouse (in seconds)
# Default: 2 minutes 30 seconds (150 seconds)
# Only moves mouse if system has been idle for this long
IDLE_THRESHOLD="${KEEP_AWAKE_IDLE_THRESHOLD:-150}"

# Function to get system idle time in seconds
# Returns the number of seconds since last user activity
get_idle_time() {
    # Use ioreg to get HIDIdleTime (time since last input event)
    # Returns time in nanoseconds, convert to seconds
    local idle_ns=$(ioreg -w 0 -c IOHIDSystem 2>/dev/null | awk '/HIDIdleTime/ {print int($NF/1000000000); exit}')

    if [ -n "$idle_ns" ] && [ "$idle_ns" -ge 0 ]; then
        echo "$idle_ns"
    else
        # Fallback: return 0 if we can't determine idle time
        echo "0"
    fi
}

# Function to simulate user activity
# Uses AppleScript to move mouse cursor by 1 pixel (imperceptible)
# This prevents macOS from detecting idle time and going to sleep
simulate_activity() {
    # Use osascript to move mouse cursor slightly
    # This is the most reliable method that works without special permissions
    osascript <<'APPLESCRIPT' 2>/dev/null
tell application "System Events"
    try
        -- Method 1: Try to get and move mouse position
        -- Note: This may require Accessibility permissions on first run
        set mouseLoc to mouse location
        set x to item 1 of mouseLoc
        set y to item 2 of mouseLoc

        -- Move mouse 1 pixel right and back (imperceptible)
        set mouse location to {x + 1, y}
        delay 0.01
        set mouse location to {x, y}
    on error
        -- Method 2: Fallback - simulate a harmless modifier key press
        -- This won't interfere with user's work but resets idle timer
        try
            key code 63 using {shift down, control down}
        on error
            -- Method 3: Last resort - just trigger a system event
            do shell script "echo ''"
        end try
    end try
end tell
APPLESCRIPT
}

# Function to display usage
usage() {
    cat << EOF
Usage: $0 [duration] [options]

Prevents macOS from going to sleep by simulating user activity (mouse movement).
Only moves the mouse if the system has been idle for a set amount of time,
preventing interruptions while you're actively working.

Works even when caffeinate and other sleep-prevention apps are blocked.

Arguments:
  duration    Optional. Duration to keep awake (e.g., 1h, 2h, 3h, 4h, 30m)
              If not specified, keeps awake indefinitely until interrupted.

Options:
  -i, --interval SECONDS      Interval between idle checks (default: 30)
  -t, --idle-threshold SECONDS Idle time before moving mouse (default: 150 = 2m30s)
  -h, --help                   Show this help message

Environment Variables:
  KEEP_AWAKE_INTERVAL          Set default check interval in seconds (default: 30)
  KEEP_AWAKE_IDLE_THRESHOLD    Set idle threshold in seconds (default: 150)

Examples:
  $0                           # Keep awake indefinitely (checks every 30s, moves if idle 2m30s)
  $0 1h                        # Keep awake for 1 hour
  $0 2h -i 60                  # Keep awake for 2 hours, checking every 60 seconds
  $0 -t 300                    # Keep awake, only move mouse if idle for 5 minutes
  $0 2h -i 30 -t 120           # Keep awake 2h, check every 30s, move if idle 2m

Press Ctrl+C to stop and allow sleep again.

EOF
}

# Parse arguments
DURATION=""
while [[ $# -gt 0 ]]; do
    case $1 in
        -h|--help)
            usage
            exit 0
            ;;
        -i|--interval)
            INTERVAL="$2"
            shift 2
            ;;
        -t|--idle-threshold)
            IDLE_THRESHOLD="$2"
            shift 2
            ;;
        *)
            if [ -z "$DURATION" ]; then
                DURATION="$1"
            else
                echo -e "${RED}Error: Unknown argument: $1${NC}" >&2
                usage
                exit 1
            fi
            shift
            ;;
    esac
done

# Validate interval
if ! [[ "$INTERVAL" =~ ^[0-9]+$ ]] || [ "$INTERVAL" -lt 1 ]; then
    echo -e "${RED}Error: Interval must be a positive integer (seconds).${NC}" >&2
    exit 1
fi

# Validate idle threshold
if ! [[ "$IDLE_THRESHOLD" =~ ^[0-9]+$ ]] || [ "$IDLE_THRESHOLD" -lt 1 ]; then
    echo -e "${RED}Error: Idle threshold must be a positive integer (seconds).${NC}" >&2
    exit 1
fi

# Convert duration to seconds if provided
TOTAL_SECONDS=""
if [ -n "$DURATION" ]; then
    # Parse duration (supports formats like 1h, 2h, 30m, 1.5h, etc.)
    if [[ "$DURATION" =~ ^([0-9]+\.?[0-9]*)([hm])$ ]]; then
        VALUE="${BASH_REMATCH[1]}"
        UNIT="${BASH_REMATCH[2]}"

        if [ "$UNIT" == "h" ]; then
            # Convert hours to seconds (using awk for portability)
            TOTAL_SECONDS=$(awk "BEGIN {printf \"%.0f\", $VALUE * 3600}")
        elif [ "$UNIT" == "m" ]; then
            # Convert minutes to seconds
            TOTAL_SECONDS=$(awk "BEGIN {printf \"%.0f\", $VALUE * 60}")
        fi
    else
        echo -e "${RED}Error: Invalid duration format. Use format like '1h', '2h', '30m', etc.${NC}" >&2
        usage
        exit 1
    fi
fi

# Check if osascript is available (should be on all macOS systems)
if ! command -v osascript &> /dev/null; then
    echo -e "${RED}Error: osascript command not found. This script requires macOS.${NC}" >&2
    exit 1
fi

# Note about Accessibility permissions
echo -e "${BLUE}Note: This script uses mouse movement simulation to prevent sleep.${NC}"
echo -e "${BLUE}macOS may prompt for Accessibility permissions on first run.${NC}"
echo ""

# Convert idle threshold to human-readable format
IDLE_MINUTES=$((IDLE_THRESHOLD / 60))
IDLE_SECONDS=$((IDLE_THRESHOLD % 60))
if [ $IDLE_MINUTES -gt 0 ]; then
    if [ $IDLE_SECONDS -gt 0 ]; then
        IDLE_DISPLAY="${IDLE_MINUTES}m ${IDLE_SECONDS}s"
    else
        IDLE_DISPLAY="${IDLE_MINUTES}m"
    fi
else
    IDLE_DISPLAY="${IDLE_SECONDS}s"
fi

# Display status message
if [ -n "$TOTAL_SECONDS" ]; then
    HOURS=$(awk "BEGIN {printf \"%.1f\", $TOTAL_SECONDS / 3600}")
    if (( $(echo "$HOURS >= 1" | awk '{print ($1 >= 1)}') )); then
        echo -e "${GREEN}Keeping Mac awake for ${HOURS} hour(s)...${NC}"
    else
        MINUTES=$(awk "BEGIN {printf \"%.0f\", $TOTAL_SECONDS / 60}")
        echo -e "${GREEN}Keeping Mac awake for ${MINUTES} minute(s)...${NC}"
    fi
    echo -e "${BLUE}Check interval: ${INTERVAL} seconds${NC}"
    echo -e "${BLUE}Idle threshold: ${IDLE_DISPLAY} (mouse moves only if idle this long)${NC}"
    echo -e "${YELLOW}Press Ctrl+C to stop early.${NC}"
else
    echo -e "${GREEN}Keeping Mac awake indefinitely...${NC}"
    echo -e "${BLUE}Check interval: ${INTERVAL} seconds${NC}"
    echo -e "${BLUE}Idle threshold: ${IDLE_DISPLAY} (mouse moves only if idle this long)${NC}"
    echo -e "${YELLOW}Press Ctrl+C to stop and allow sleep again.${NC}"
fi

# Trap Ctrl+C to exit gracefully
trap 'echo -e "\n${GREEN}Stopped. Mac will now sleep normally.${NC}"; exit 0' INT TERM

# Main loop
START_TIME=$(date +%s)
ITERATION=0

while true; do
    # Check if duration has elapsed
    if [ -n "$TOTAL_SECONDS" ]; then
        CURRENT_TIME=$(date +%s)
        ELAPSED=$((CURRENT_TIME - START_TIME))

        if [ $ELAPSED -ge $TOTAL_SECONDS ]; then
            echo -e "${GREEN}Duration complete. Mac will now sleep normally.${NC}"
            exit 0
        fi

        REMAINING=$((TOTAL_SECONDS - ELAPSED))
        if [ $((ITERATION % 10)) -eq 0 ]; then
            # Show progress every 10 iterations
            HOURS_REMAINING=$(awk "BEGIN {printf \"%.1f\", $REMAINING / 3600}")
            if (( $(echo "$HOURS_REMAINING >= 1" | awk '{print ($1 >= 1)}') )); then
                echo -e "${BLUE}Time remaining: ${HOURS_REMAINING} hour(s)${NC}"
            else
                MINUTES_REMAINING=$(awk "BEGIN {printf \"%.0f\", $REMAINING / 60}")
                echo -e "${BLUE}Time remaining: ${MINUTES_REMAINING} minute(s)${NC}"
            fi
        fi
    fi

    # Check system idle time
    IDLE_TIME=$(get_idle_time)

    # Only simulate activity if system has been idle for the threshold duration
    if [ "$IDLE_TIME" -ge "$IDLE_THRESHOLD" ]; then
        # System is idle, move mouse to prevent sleep
        simulate_activity >/dev/null 2>&1

        # Optional: Log when we move the mouse (every 10th time to avoid spam)
        if [ $((ITERATION % 10)) -eq 0 ]; then
            IDLE_MIN=$((IDLE_TIME / 60))
            IDLE_SEC=$((IDLE_TIME % 60))
            if [ $IDLE_MIN -gt 0 ]; then
                echo -e "${BLUE}[Idle: ${IDLE_MIN}m ${IDLE_SEC}s] Moved mouse to prevent sleep${NC}"
            else
                echo -e "${BLUE}[Idle: ${IDLE_SEC}s] Moved mouse to prevent sleep${NC}"
            fi
        fi
    fi
    # If not idle enough, do nothing - user is actively working

    # Wait for the specified interval
    sleep "$INTERVAL"

    ITERATION=$((ITERATION + 1))
done
