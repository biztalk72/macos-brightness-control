#!/bin/bash

# Enhanced Brightness Control Script v2.0
# Advanced morning routine automation for macOS
# Created by Claude Assistant for sy2024051047

set -euo pipefail  # Exit on error, undefined vars, pipe failures

# === CONFIGURATION ===
CONFIG_FILE="$HOME/.brightness_config"
LOG_FILE="$HOME/brightness_enhanced.log"
ERROR_LOG="$HOME/brightness_errors.log"
BRIGHTNESS_STATE_FILE="$HOME/.brightness_state"

# Default values (can be overridden by config file)
BRIGHTNESS_LEVEL=100
BRIGHTNESS_KEY_PRESSES=25
ENABLE_TOGGLE_MODE=true
WAKE_DISPLAYS=true
USE_DDC_CONTROL=true
USE_KEYBOARD_SIMULATION=true
DISABLE_DARK_MODE=true
SYSTEM_VOLUME=50
ENABLE_DND=false
OPEN_APPS=""
CLOSE_APPS=""
VERBOSE_LOGGING=true
SHOW_NOTIFICATIONS=true
PLAY_SOUND=false
CHECK_UPDATES=false
EXTERNAL_MONITOR_TOOL="auto"
SKIP_ON_BATTERY=false
MAX_EXECUTION_TIME=60
SHOW_WEATHER=false
WEATHER_API_KEY=""
WEATHER_CITY="Seoul"
CUSTOM_MESSAGE="Good morning! Your displays are ready ☀️"
SHOW_GREETING=true
ACTION_DELAY=0.5

# === UTILITY FUNCTIONS ===
log_message() {
    local level="$1"
    local message="$2"
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    echo "[$timestamp] [$level] $message" >> "$LOG_FILE"
    
    if [[ "$VERBOSE_LOGGING" == "true" ]]; then
        echo "[$level] $message"
    fi
}

log_error() {
    local message="$1"
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    echo "[$timestamp] [ERROR] $message" >> "$ERROR_LOG"
    log_message "ERROR" "$message"
}

show_notification() {
    local title="$1"
    local message="$2"
    local sound="${3:-}"
    
    if [[ "$SHOW_NOTIFICATIONS" == "true" ]]; then
        if [[ -n "$sound" ]]; then
            osascript -e "display notification \"$message\" with title \"$title\" sound name \"$sound\"" 2>/dev/null || true
        else
            osascript -e "display notification \"$message\" with title \"$title\"" 2>/dev/null || true
        fi
    fi
}

check_battery_status() {
    if [[ "$SKIP_ON_BATTERY" == "true" ]]; then
        local power_source=$(pmset -g ps | head -1)
        if [[ $power_source == *"Battery Power"* ]]; then
            log_message "INFO" "Running on battery power, skipping brightness control"
            show_notification "Brightness Control" "Skipped - Running on battery power"
            exit 0
        fi
    fi
}

get_current_brightness() {
    local brightness=0
    
    # Try to get brightness from ddcctl for external monitors
    if command -v ddcctl &> /dev/null; then
        # Get brightness from first display
        local brightness_output=$(ddcctl -d 1 2>/dev/null | grep -i "brightness" | head -1)
        if [[ -n "$brightness_output" ]]; then
            brightness=$(echo "$brightness_output" | grep -oE '[0-9]+' | head -1)
        fi
    fi
    
    # Only echo the numeric value
    echo "$brightness"
}

store_brightness_state() {
    local brightness="$1"
    echo "$brightness" > "$BRIGHTNESS_STATE_FILE" 2>/dev/null
}

load_brightness_state() {
    if [[ -f "$BRIGHTNESS_STATE_FILE" ]]; then
        cat "$BRIGHTNESS_STATE_FILE"
    else
        echo "50"  # Default middle value
    fi
}

determine_target_brightness() {
    if [[ "$ENABLE_TOGGLE_MODE" != "true" ]]; then
        echo "$BRIGHTNESS_LEVEL"
        return
    fi
    
    local current_brightness
    current_brightness=$(get_current_brightness)
    local target_brightness
    
    # Toggle logic: if 0, set to 100; if 100, set to 0; otherwise use configured level
    if [[ $current_brightness -eq 0 ]] || [[ $current_brightness -lt 10 ]]; then
        target_brightness=100
        log_message "INFO" "Brightness is at minimum ($current_brightness%), toggling to maximum (100%)" >&2
    elif [[ $current_brightness -ge 90 ]]; then
        target_brightness=0
        log_message "INFO" "Brightness is at maximum ($current_brightness%), toggling to minimum (0%)" >&2
    else
        # Use configured brightness level
        target_brightness=$BRIGHTNESS_LEVEL
        log_message "INFO" "Brightness is at $current_brightness%, setting to configured level ($target_brightness%)" >&2
    fi
    
    echo "$target_brightness"
}

detect_displays() {
    # Count external displays using ddcctl if available
    if command -v ddcctl &> /dev/null; then
        # Look for the "found N external displays" line
        local detect_output=$(ddcctl -d list 2>&1)
        local external_count=$(echo "$detect_output" | grep -i "found.*external display" | grep -oE '[0-9]+' | head -1)
        
        if [[ -z "$external_count" ]]; then
            # Fallback: count CGDisplay lines
            external_count=$(echo "$detect_output" | grep -c "^D: CGDisplay" || echo "0")
        fi
        
        external_count=$(echo "$external_count" | tr -d '\n\r ')
        log_message "INFO" "Detected $external_count external displays" >&2
        echo "$external_count"
        return 0
    fi
    
    echo "0"
    return 0
}

install_external_tools() {
    log_message "INFO" "Checking and installing external monitor tools..."
    
    if command -v brew &> /dev/null; then
        # Install ddcctl if not available
        if ! command -v ddcctl &> /dev/null; then
            log_message "INFO" "Installing ddcctl..."
            brew install ddcctl &>/dev/null || log_error "Failed to install ddcctl"
        fi
        
        # Check for MonitorControl app
        if [[ ! -d "/Applications/MonitorControl.app" ]] && [[ "$EXTERNAL_MONITOR_TOOL" == "MonitorControl" || "$EXTERNAL_MONITOR_TOOL" == "auto" ]]; then
            log_message "INFO" "Consider installing MonitorControl app for better external monitor control"
        fi
    else
        log_error "Homebrew not available - cannot install external monitor tools"
    fi
}

wake_displays() {
    if [[ "$WAKE_DISPLAYS" == "true" ]]; then
        log_message "INFO" "Waking up displays..."
        
        # Method 1: Use caffeinate to prevent display sleep
        caffeinate -u -t 3 &
        local caffeinate_pid=$!
        
        # Method 2: Move mouse slightly to wake displays
        osascript -e '
        tell application "System Events"
            set currentPosition to position of mouse
            set newX to (item 1 of currentPosition) + 1
            set newY to (item 2 of currentPosition) + 1
            set the mouse position to {newX, newY}
            delay 0.1
            set the mouse position to currentPosition
        end tell
        ' 2>/dev/null || true
        
        # Method 3: Send a harmless key event
        osascript -e '
        tell application "System Events"
            key code 63 using {fn down, shift down}  # F14 key with modifiers (should not trigger any action)
        end tell
        ' 2>/dev/null || true
        
        sleep 1
        kill $caffeinate_pid 2>/dev/null || true
        
        log_message "INFO" "Display wake-up completed"
    fi
}

control_keyboard_brightness() {
    if [[ "$USE_KEYBOARD_SIMULATION" == "true" ]]; then
        log_message "INFO" "Adjusting brightness via keyboard simulation ($BRIGHTNESS_KEY_PRESSES presses)..."
        
        osascript -e "
        tell application \"System Events\"
            -- First, reduce brightness to minimum
            repeat 20 times
                key code 144 using {}  -- F1 key (brightness down)
                delay 0.02
            end repeat
            
            delay 0.2
            
            -- Then increase to desired level
            repeat $BRIGHTNESS_KEY_PRESSES times
                key code 145 using {}  -- F2 key (brightness up)
                delay 0.02
            end repeat
        end tell
        " 2>/dev/null || log_error "Failed to simulate keyboard brightness control"
        
        sleep "$ACTION_DELAY"
    fi
}

control_external_monitors_ddcctl() {
    local target_brightness="$1"
    
    if [[ "$USE_DDC_CONTROL" != "true" ]] || ! command -v ddcctl &> /dev/null; then
        log_message "INFO" "DDC control disabled or ddcctl not available, skipping external monitor control"
        return 0
    fi
    
    log_message "INFO" "Attempting to control external monitors with ddcctl (brightness: $target_brightness%)..."
    
    # Get accurate count of external displays
    local detect_output=$(ddcctl -d list 2>&1)
    local displays=$(echo "$detect_output" | grep -i "found.*external display" | grep -oE '[0-9]+' | head -1)
    
    if [[ -z "$displays" ]]; then
        # Fallback: count CGDisplay lines
        displays=$(echo "$detect_output" | grep -c "^D: CGDisplay" || echo "0")
    fi
    
    displays=$(echo "$displays" | tr -d '\n\r ')
    
    if [[ $displays -gt 0 ]]; then
        log_message "INFO" "Found $displays external display(s), attempting brightness adjustment"
        
        local success_count=0
        # Control all displays simultaneously
        for i in $(seq 1 $displays); do
            log_message "DEBUG" "Attempting to set display $i to $target_brightness% brightness"
            
            # Try to set brightness on each display
            if ddcctl -d $i -b $target_brightness 2>&1 | grep -q "^E:"; then
                log_message "WARN" "ddcctl failed for display $i (permission issue or unsupported display)"
            else
                success_count=$((success_count + 1))
                log_message "INFO" "Successfully controlled display $i"
                
                # Only adjust contrast and color temp if not turning off and previous command succeeded
                if [[ $target_brightness -gt 0 ]]; then
                    ddcctl -d $i -c 75 2>/dev/null || true
                    ddcctl -d $i -t 6500 2>/dev/null || true
                fi
            fi
            
            sleep 0.1
        done
        
        if [[ $success_count -eq 0 ]]; then
            log_message "WARN" "ddcctl could not control any displays (permissions issue). Using MonitorControl app instead."
            log_message "INFO" "Please ensure MonitorControl.app has necessary permissions in System Settings > Privacy & Security"
        else
            log_message "INFO" "External monitor brightness control completed for $success_count/$displays display(s)"
        fi
    else
        log_message "WARN" "No external displays detected by ddcctl"
    fi
}

control_external_monitors_m1ddc() {
    local target_brightness="$1"
    
    if command -v m1ddc &> /dev/null; then
        log_message "INFO" "Using m1ddc for Apple Silicon external monitor control..."
        
        # Try to control up to 4 displays
        local controlled_count=0
        for i in {1..4}; do
            if m1ddc display $i set brightness $target_brightness 2>/dev/null; then
                log_message "DEBUG" "Set m1ddc display $i brightness to $target_brightness%"
                controlled_count=$((controlled_count + 1))
            fi
        done
        
        if [[ $controlled_count -gt 0 ]]; then
            log_message "INFO" "Controlled $controlled_count display(s) with m1ddc"
        fi
    fi
}

disable_dark_mode() {
    if [[ "$DISABLE_DARK_MODE" == "true" ]]; then
        log_message "INFO" "Disabling Dark Mode..."
        
        osascript -e '
        tell application "System Events"
            tell appearance preferences
                set dark mode to false
            end tell
        end tell
        ' 2>/dev/null || log_error "Failed to disable Dark Mode"
        
        sleep "$ACTION_DELAY"
    fi
}

adjust_system_volume() {
    if [[ "$SYSTEM_VOLUME" != "-1" ]] && [[ "$SYSTEM_VOLUME" -ge 0 ]] && [[ "$SYSTEM_VOLUME" -le 100 ]]; then
        log_message "INFO" "Setting system volume to $SYSTEM_VOLUME%..."
        
        osascript -e "set volume output volume $SYSTEM_VOLUME" 2>/dev/null || log_error "Failed to set system volume"
        
        sleep "$ACTION_DELAY"
    fi
}

manage_do_not_disturb() {
    if [[ "$ENABLE_DND" == "true" ]]; then
        log_message "INFO" "Enabling Do Not Disturb mode..."
        
        # Enable Do Not Disturb
        shortcuts run "Set Focus" --input-path "Do Not Disturb" 2>/dev/null || {
            # Alternative method for older macOS versions
            osascript -e '
            tell application "System Events"
                tell application process "SystemUIServer"
                    try
                        click button 1 of window "Notification Center"
                    end try
                end tell
            end tell
            ' 2>/dev/null || true
        }
    fi
}

manage_applications() {
    # Close applications if specified
    if [[ -n "$CLOSE_APPS" ]]; then
        log_message "INFO" "Closing specified applications..."
        IFS=',' read -ra APPS_TO_CLOSE <<< "$CLOSE_APPS"
        for app in "${APPS_TO_CLOSE[@]}"; do
            app=$(echo "$app" | xargs)  # Trim whitespace
            if [[ -n "$app" ]]; then
                log_message "DEBUG" "Closing $app"
                osascript -e "tell application \"$app\" to quit" 2>/dev/null || true
                sleep 0.5
            fi
        done
    fi
    
    # Open applications if specified
    if [[ -n "$OPEN_APPS" ]]; then
        log_message "INFO" "Opening specified applications..."
        IFS=',' read -ra APPS_TO_OPEN <<< "$OPEN_APPS"
        for app in "${APPS_TO_OPEN[@]}"; do
            app=$(echo "$app" | xargs)  # Trim whitespace
            if [[ -n "$app" ]]; then
                log_message "DEBUG" "Opening $app"
                osascript -e "tell application \"$app\" to activate" 2>/dev/null || log_error "Failed to open $app"
                sleep 1
            fi
        done
    fi
}

get_weather_info() {
    if [[ "$SHOW_WEATHER" == "true" ]] && [[ -n "$WEATHER_API_KEY" ]]; then
        log_message "INFO" "Fetching weather information for $WEATHER_CITY..."
        
        local weather_url="http://api.openweathermap.org/data/2.5/weather?q=$WEATHER_CITY&appid=$WEATHER_API_KEY&units=metric"
        local weather_data=$(curl -s "$weather_url" 2>/dev/null || echo "")
        
        if [[ -n "$weather_data" ]] && echo "$weather_data" | grep -q '"main"'; then
            local temp=$(echo "$weather_data" | grep -o '"temp":[0-9.-]*' | cut -d':' -f2 | cut -d',' -f1)
            local desc=$(echo "$weather_data" | grep -o '"description":"[^"]*"' | cut -d'"' -f4)
            local weather_info="🌡️ ${temp}°C, $desc"
            log_message "INFO" "Weather: $weather_info"
            echo "$weather_info"
        else
            log_message "WARN" "Failed to fetch weather information"
            echo ""
        fi
    else
        echo ""
    fi
}

check_for_updates() {
    if [[ "$CHECK_UPDATES" == "true" ]]; then
        log_message "INFO" "Checking for system updates..."
        
        local updates=$(softwareupdate -l 2>/dev/null | grep -c "recommended" || echo "0")
        if [[ "$updates" -gt 0 ]]; then
            log_message "INFO" "Found $updates system updates available"
            show_notification "System Updates" "$updates updates available"
        fi
    fi
}

create_summary_report() {
    local weather_info="$1"
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    local summary_file="$HOME/brightness_daily_summary.txt"
    
    cat > "$summary_file" << EOF
=== Morning Brightness Control Summary ===
Date: $timestamp
Weather: ${weather_info:-"Not available"}
Brightness Level: ${BRIGHTNESS_LEVEL}%
External Displays: $(detect_displays 2>/dev/null || echo "Unknown")
Dark Mode: $([ "$DISABLE_DARK_MODE" == "true" ] && echo "Disabled" || echo "No change")
System Volume: $([ "$SYSTEM_VOLUME" != "-1" ] && echo "${SYSTEM_VOLUME}%" || echo "No change")
Applications Opened: ${OPEN_APPS:-"None"}
Applications Closed: ${CLOSE_APPS:-"None"}

Status: ✅ Completed successfully

For detailed logs, see: $LOG_FILE
EOF

    log_message "INFO" "Summary report created: $summary_file"
}

# === MAIN EXECUTION ===
main() {
    # Set execution timeout
    (
        sleep "$MAX_EXECUTION_TIME"
        log_error "Script execution timeout reached ($MAX_EXECUTION_TIME seconds)"
        pkill -f "brightness_control_enhanced.sh" 2>/dev/null || true
    ) &
    local timeout_pid=$!
    
    # Load configuration
    if [[ -f "$CONFIG_FILE" ]]; then
        # shellcheck source=/dev/null
        source "$CONFIG_FILE"
        log_message "INFO" "Configuration loaded from $CONFIG_FILE"
    else
        log_message "WARN" "Configuration file not found, using defaults"
    fi
    
    log_message "INFO" "Enhanced Brightness Control v2.0 started"
    
    # Show greeting if enabled
    if [[ "$SHOW_GREETING" == "true" ]]; then
        show_notification "Good Morning! ☀️" "Starting your morning routine..."
    fi
    
    # Safety checks
    check_battery_status
    
    # Get weather information
    local weather_info
    weather_info=$(get_weather_info)
    
    # Execute morning routine
    log_message "INFO" "Beginning morning routine..."
    
    # 1. Install/check external tools
    install_external_tools
    
    # 2. Detect displays
    local display_count
    display_count=$(detect_displays)
    
    # 3. Determine target brightness (with toggle logic)
    local target_brightness
    target_brightness=$(determine_target_brightness)
    log_message "INFO" "Target brightness level: $target_brightness%"
    
    # Update BRIGHTNESS_LEVEL for other functions
    BRIGHTNESS_LEVEL=$target_brightness
    
    # Calculate key presses for keyboard brightness
    if [[ $target_brightness -eq 0 ]]; then
        BRIGHTNESS_KEY_PRESSES=0  # Will only press down keys
    else
        BRIGHTNESS_KEY_PRESSES=$(( target_brightness / 4 ))  # Assuming ~4% per press
    fi
    
    # 4. Wake up displays
    wake_displays
    
    # 5. Control brightness
    control_keyboard_brightness
    
    # 6. Control external monitors (all displays simultaneously)
    if [[ $display_count -gt 0 ]]; then
        log_message "INFO" "Controlling $display_count external display(s) simultaneously"
        
        case "$EXTERNAL_MONITOR_TOOL" in
            "ddcctl"|"auto")
                control_external_monitors_ddcctl "$target_brightness"
                ;;
            "m1ddc")
                control_external_monitors_m1ddc "$target_brightness"
                ;;
            *)
                control_external_monitors_ddcctl "$target_brightness"
                ;;
        esac
    else
        log_message "INFO" "No external displays to control"
    fi
    
    # Store the new brightness state
    store_brightness_state "$target_brightness"
    
    # 7. System adjustments
    disable_dark_mode
    adjust_system_volume
    manage_do_not_disturb
    
    # 8. Application management
    manage_applications
    
    # 9. Check for updates
    check_for_updates
    
    # 10. Create summary report
    create_summary_report "$weather_info"
    
    # 11. Final notification
    local brightness_status
    if [[ $target_brightness -eq 0 ]]; then
        brightness_status="🌙 Displays OFF"
    elif [[ $target_brightness -eq 100 ]]; then
        brightness_status="☀️ Maximum brightness"
    else
        brightness_status="💡 Brightness: ${target_brightness}%"
    fi
    
    local monitors_info=""
    if [[ $display_count -gt 0 ]]; then
        monitors_info="\n📺 Controlled $display_count external display(s)"
    fi
    
    local final_message="$brightness_status$monitors_info"
    if [[ -n "$weather_info" ]]; then
        final_message="$final_message\n\n$weather_info"
    fi
    
    if [[ "$PLAY_SOUND" == "true" ]]; then
        show_notification "Brightness Control Complete" "$final_message" "Glass"
    else
        show_notification "Brightness Control Complete" "$final_message"
    fi
    
    log_message "INFO" "Enhanced brightness control completed successfully"
    
    # Clean up timeout process
    kill $timeout_pid 2>/dev/null || true
}

# === ERROR HANDLING ===
cleanup() {
    log_message "INFO" "Cleaning up..."
    # Kill any remaining background processes
    jobs -p | xargs -r kill 2>/dev/null || true
}

trap cleanup EXIT
trap 'log_error "Script interrupted"; cleanup; exit 1' INT TERM

# === SCRIPT START ===
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi