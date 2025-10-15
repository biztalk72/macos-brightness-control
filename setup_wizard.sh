#!/bin/bash

# Enhanced Brightness Control Setup Wizard
# Interactive configuration for morning routine automation
# Created by Claude Assistant for sy2024051047

set -euo pipefail

CONFIG_FILE="$HOME/.brightness_config"
ENHANCED_SCRIPT="$HOME/brightness_control_enhanced.sh"
PLIST_FILE="$HOME/Library/LaunchAgents/com.user.brightness.enhanced.plist"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Utility functions
print_header() {
    echo -e "${CYAN}"
    echo "╔════════════════════════════════════════════════════════════╗"
    echo "║              Enhanced Brightness Control v2.0             ║"
    echo "║                    Setup Wizard                           ║"
    echo "╚════════════════════════════════════════════════════════════╝"
    echo -e "${NC}"
}

print_section() {
    echo -e "${PURPLE}━━━ $1 ━━━${NC}"
}

ask_yes_no() {
    local question="$1"
    local default="${2:-n}"
    
    while true; do
        if [[ "$default" == "y" ]]; then
            read -p "$(echo -e ${YELLOW}$question${NC}) [Y/n]: " answer
            answer=${answer:-y}
        else
            read -p "$(echo -e ${YELLOW}$question${NC}) [y/N]: " answer
            answer=${answer:-n}
        fi
        
        case $answer in
            [Yy]* ) return 0;;
            [Nn]* ) return 1;;
            * ) echo "Please answer yes or no.";;
        esac
    done
}

ask_number() {
    local question="$1"
    local min="$2"
    local max="$3"
    local default="$4"
    
    while true; do
        read -p "$(echo -e ${YELLOW}$question${NC}) [$default]: " answer
        answer=${answer:-$default}
        
        if [[ "$answer" =~ ^[0-9]+$ ]] && (( answer >= min && answer <= max )); then
            echo "$answer"
            return
        else
            echo -e "${RED}Please enter a number between $min and $max${NC}"
        fi
    done
}

ask_string() {
    local question="$1"
    local default="$2"
    
    read -p "$(echo -e ${YELLOW}$question${NC}) [$default]: " answer
    echo "${answer:-$default}"
}

ask_time() {
    local question="$1"
    local default_hour="$2"
    local default_minute="$3"
    
    while true; do
        echo -e "${YELLOW}$question${NC}"
        local hour=$(ask_number "Enter hour (24-hour format)" 0 23 "$default_hour")
        local minute=$(ask_number "Enter minute" 0 59 "$default_minute")
        
        printf -v formatted_time "%02d:%02d" "$hour" "$minute"
        if ask_yes_no "Set schedule time to $formatted_time?"; then
            echo "$hour $minute"
            return
        fi
    done
}

check_prerequisites() {
    print_section "Checking Prerequisites"
    
    # Check if running on macOS
    if [[ "$(uname)" != "Darwin" ]]; then
        echo -e "${RED}Error: This script is designed for macOS only${NC}"
        exit 1
    fi
    
    # Check for required commands
    local missing_commands=()
    
    for cmd in osascript pmset system_profiler; do
        if ! command -v "$cmd" &> /dev/null; then
            missing_commands+=("$cmd")
        fi
    done
    
    if [[ ${#missing_commands[@]} -gt 0 ]]; then
        echo -e "${RED}Error: Missing required commands: ${missing_commands[*]}${NC}"
        exit 1
    fi
    
    # Check for Homebrew
    if command -v brew &> /dev/null; then
        echo -e "${GREEN}✓ Homebrew found${NC}"
    else
        echo -e "${YELLOW}! Homebrew not found - some external monitor features may not work${NC}"
    fi
    
    # Check for enhanced script
    if [[ ! -f "$ENHANCED_SCRIPT" ]]; then
        echo -e "${RED}Error: Enhanced brightness script not found at $ENHANCED_SCRIPT${NC}"
        exit 1
    fi
    
    echo -e "${GREEN}✓ Prerequisites check passed${NC}"
    echo
}

detect_system_info() {
    print_section "System Information"
    
    # Get system info
    local mac_model=$(system_profiler SPHardwareDataType | grep "Model Name" | cut -d: -f2 | xargs)
    local displays=$(system_profiler SPDisplaysDataType | grep -c "Display Type" || echo "1")
    local external_displays=$((displays - 1))
    
    echo -e "Mac Model: ${GREEN}$mac_model${NC}"
    echo -e "Total Displays: ${GREEN}$displays${NC}"
    echo -e "External Displays: ${GREEN}$external_displays${NC}"
    
    # Check for external monitor tools
    if command -v ddcctl &> /dev/null; then
        echo -e "DDC Control: ${GREEN}Available${NC}"
    else
        echo -e "DDC Control: ${YELLOW}Not installed${NC}"
    fi
    
    echo
}

configure_brightness() {
    print_section "Brightness Settings"
    
    BRIGHTNESS_LEVEL=$(ask_number "Brightness level (0-100)" 0 100 100)
    BRIGHTNESS_KEY_PRESSES=$(ask_number "Number of brightness key presses for safety" 10 50 25)
    
    USE_DDC_CONTROL=$(ask_yes_no "Use DDC control for external monitors?" "y")
    USE_KEYBOARD_SIMULATION=$(ask_yes_no "Use keyboard brightness simulation?" "y")
    WAKE_DISPLAYS=$(ask_yes_no "Wake up displays before brightness adjustment?" "y")
}

configure_schedule() {
    print_section "Schedule Configuration"
    
    echo "Current schedule time: 8:50 AM"
    if ask_yes_no "Change the schedule time?"; then
        local time_result=$(ask_time "When should the brightness control run?" 8 50)
        SCHEDULE_HOUR=$(echo "$time_result" | cut -d' ' -f1)
        SCHEDULE_MINUTE=$(echo "$time_result" | cut -d' ' -f2)
    else
        SCHEDULE_HOUR=8
        SCHEDULE_MINUTE=50
    fi
    
    printf -v schedule_display "%02d:%02d" "$SCHEDULE_HOUR" "$SCHEDULE_MINUTE"
    echo -e "Schedule set to: ${GREEN}$schedule_display${NC}"
}

configure_morning_routine() {
    print_section "Morning Routine Features"
    
    DISABLE_DARK_MODE=$(ask_yes_no "Turn off Dark Mode?" "y")
    
    if ask_yes_no "Adjust system volume?"; then
        SYSTEM_VOLUME=$(ask_number "System volume (0-100)" 0 100 50)
    else
        SYSTEM_VOLUME=-1
    fi
    
    ENABLE_DND=$(ask_yes_no "Enable Do Not Disturb mode?")
    
    # Application management
    if ask_yes_no "Open specific applications in the morning?"; then
        echo "Enter comma-separated app names (e.g., Calendar,Mail,Music):"
        OPEN_APPS=$(ask_string "Applications to open" "")
    else
        OPEN_APPS=""
    fi
    
    if ask_yes_no "Close specific applications?"; then
        echo "Enter comma-separated app names (e.g., Slack,Discord):"
        CLOSE_APPS=$(ask_string "Applications to close" "")
    else
        CLOSE_APPS=""
    fi
}

configure_advanced() {
    print_section "Advanced Settings"
    
    VERBOSE_LOGGING=$(ask_yes_no "Enable verbose logging?" "y")
    SHOW_NOTIFICATIONS=$(ask_yes_no "Show desktop notifications?" "y")
    PLAY_SOUND=$(ask_yes_no "Play sound when complete?")
    CHECK_UPDATES=$(ask_yes_no "Check for system updates?")
    SKIP_ON_BATTERY=$(ask_yes_no "Skip brightness control when on battery power?")
    
    MAX_EXECUTION_TIME=$(ask_number "Maximum execution time (seconds)" 30 300 60)
    
    if ask_yes_no "Enable weather information? (requires API key)"; then
        SHOW_WEATHER=true
        WEATHER_CITY=$(ask_string "Your city" "Seoul")
        echo -e "${YELLOW}To get weather, sign up at openweathermap.org for a free API key${NC}"
        WEATHER_API_KEY=$(ask_string "Weather API key (leave empty to skip)" "")
    else
        SHOW_WEATHER=false
        WEATHER_API_KEY=""
        WEATHER_CITY="Seoul"
    fi
    
    CUSTOM_MESSAGE=$(ask_string "Custom notification message" "Good morning! Your displays are ready ☀️")
    SHOW_GREETING=$(ask_yes_no "Show morning greeting?" "y")
}

write_configuration() {
    print_section "Writing Configuration"
    
    cat > "$CONFIG_FILE" << EOF
# Enhanced Brightness Control Configuration
# Generated by setup wizard on $(date)

# === BRIGHTNESS SETTINGS ===
BRIGHTNESS_LEVEL=$BRIGHTNESS_LEVEL
BRIGHTNESS_KEY_PRESSES=$BRIGHTNESS_KEY_PRESSES

# === TIMING SETTINGS ===
SCHEDULE_HOUR=$SCHEDULE_HOUR
SCHEDULE_MINUTE=$SCHEDULE_MINUTE
ACTION_DELAY=0.5

# === DISPLAY SETTINGS ===
WAKE_DISPLAYS=$WAKE_DISPLAYS
USE_DDC_CONTROL=$USE_DDC_CONTROL
USE_KEYBOARD_SIMULATION=$USE_KEYBOARD_SIMULATION

# === MORNING ROUTINE FEATURES ===
DISABLE_DARK_MODE=$DISABLE_DARK_MODE
SYSTEM_VOLUME=$SYSTEM_VOLUME
ENABLE_DND=$ENABLE_DND

# === APPLICATION MANAGEMENT ===
OPEN_APPS="$OPEN_APPS"
CLOSE_APPS="$CLOSE_APPS"

# === ADVANCED SETTINGS ===
VERBOSE_LOGGING=$VERBOSE_LOGGING
SHOW_NOTIFICATIONS=$SHOW_NOTIFICATIONS
PLAY_SOUND=$PLAY_SOUND
CHECK_UPDATES=$CHECK_UPDATES
EXTERNAL_MONITOR_TOOL=auto
SKIP_ON_BATTERY=$SKIP_ON_BATTERY
MAX_EXECUTION_TIME=$MAX_EXECUTION_TIME

# === WEATHER INTEGRATION ===
SHOW_WEATHER=$SHOW_WEATHER
WEATHER_API_KEY="$WEATHER_API_KEY"
WEATHER_CITY="$WEATHER_CITY"

# === CUSTOMIZATION ===
CUSTOM_MESSAGE="$CUSTOM_MESSAGE"
SHOW_GREETING=$SHOW_GREETING
EOF

    echo -e "${GREEN}✓ Configuration written to $CONFIG_FILE${NC}"
}

create_launchd_plist() {
    print_section "Creating Scheduled Task"
    
    # Ensure LaunchAgents directory exists
    mkdir -p "$HOME/Library/LaunchAgents"
    
    cat > "$PLIST_FILE" << EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>Label</key>
    <string>com.user.brightness.enhanced</string>
    
    <key>ProgramArguments</key>
    <array>
        <string>/bin/bash</string>
        <string>$ENHANCED_SCRIPT</string>
    </array>
    
    <key>StartCalendarInterval</key>
    <dict>
        <key>Hour</key>
        <integer>$SCHEDULE_HOUR</integer>
        <key>Minute</key>
        <integer>$SCHEDULE_MINUTE</integer>
    </dict>
    
    <key>RunAtLoad</key>
    <false/>
    
    <key>KeepAlive</key>
    <false/>
    
    <key>StandardOutPath</key>
    <string>$HOME/brightness_enhanced_stdout.log</string>
    
    <key>StandardErrorPath</key>
    <string>$HOME/brightness_enhanced_stderr.log</string>
    
    <key>WorkingDirectory</key>
    <string>$HOME</string>
    
    <key>EnvironmentVariables</key>
    <dict>
        <key>PATH</key>
        <string>/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin:/opt/homebrew/bin</string>
        <key>HOME</key>
        <string>$HOME</string>
    </dict>
</dict>
</plist>
EOF

    echo -e "${GREEN}✓ Launchd plist created at $PLIST_FILE${NC}"
}

install_scheduled_task() {
    print_section "Installing Scheduled Task"
    
    # Unload existing task if it exists
    launchctl unload "$PLIST_FILE" 2>/dev/null || true
    
    # Remove old task if it exists
    local old_plist="$HOME/Library/LaunchAgents/com.user.brightness.plist"
    if [[ -f "$old_plist" ]]; then
        launchctl unload "$old_plist" 2>/dev/null || true
        rm -f "$old_plist"
        echo -e "${YELLOW}✓ Removed old brightness task${NC}"
    fi
    
    # Load the new task
    launchctl load "$PLIST_FILE"
    
    if launchctl list | grep -q "com.user.brightness.enhanced"; then
        echo -e "${GREEN}✓ Scheduled task installed successfully${NC}"
        
        printf -v next_run "%02d:%02d" "$SCHEDULE_HOUR" "$SCHEDULE_MINUTE"
        echo -e "Next run: ${GREEN}$next_run daily${NC}"
    else
        echo -e "${RED}Error: Failed to install scheduled task${NC}"
        return 1
    fi
}

run_test() {
    print_section "Testing Configuration"
    
    if ask_yes_no "Run a test of the brightness control now?"; then
        echo -e "${YELLOW}Running test...${NC}"
        "$ENHANCED_SCRIPT" || {
            echo -e "${RED}Test failed. Check the logs for details.${NC}"
            return 1
        }
        
        echo -e "${GREEN}✓ Test completed successfully!${NC}"
        
        if ask_yes_no "View the log file?"; then
            if [[ -f "$HOME/brightness_enhanced.log" ]]; then
                tail -20 "$HOME/brightness_enhanced.log"
            fi
        fi
    fi
}

show_summary() {
    print_section "Setup Complete!"
    
    printf -v schedule_time "%02d:%02d" "$SCHEDULE_HOUR" "$SCHEDULE_MINUTE"
    
    echo -e "${GREEN}Your enhanced brightness control system is now configured!${NC}"
    echo
    echo "📅 Schedule: $schedule_time daily"
    echo "💡 Brightness Level: $BRIGHTNESS_LEVEL%"
    echo "🌙 Dark Mode: $([ "$DISABLE_DARK_MODE" == "true" ] && echo "Will be disabled" || echo "No change")"
    echo "🔊 Volume: $([ "$SYSTEM_VOLUME" != "-1" ] && echo "${SYSTEM_VOLUME}%" || echo "No change")"
    echo "📱 Apps to Open: ${OPEN_APPS:-"None"}"
    echo "❌ Apps to Close: ${CLOSE_APPS:-"None"}"
    echo "🌤️  Weather: $([ "$SHOW_WEATHER" == "true" ] && echo "Enabled" || echo "Disabled")"
    echo
    echo -e "${CYAN}Configuration file: $CONFIG_FILE${NC}"
    echo -e "${CYAN}Enhanced script: $ENHANCED_SCRIPT${NC}"
    echo -e "${CYAN}Log files: ~/brightness_enhanced*.log${NC}"
    echo
    echo -e "${YELLOW}To modify settings later, edit the configuration file or run this wizard again.${NC}"
    echo -e "${YELLOW}To test manually: $ENHANCED_SCRIPT${NC}"
    echo
    echo -e "${GREEN}Have a bright day! ☀️${NC}"
}

# Main execution
main() {
    print_header
    
    echo -e "${BLUE}This wizard will help you configure an advanced morning brightness control system.${NC}"
    echo -e "${BLUE}The system can control monitor brightness, manage applications, adjust system settings,${NC}"
    echo -e "${BLUE}and provide weather information as part of your daily morning routine.${NC}"
    echo
    
    if ! ask_yes_no "Continue with setup?"; then
        echo "Setup cancelled."
        exit 0
    fi
    
    echo
    
    check_prerequisites
    detect_system_info
    configure_brightness
    configure_schedule
    configure_morning_routine
    configure_advanced
    
    echo
    print_section "Review Configuration"
    printf -v schedule_display "%02d:%02d" "$SCHEDULE_HOUR" "$SCHEDULE_MINUTE"
    echo "Schedule: $schedule_display"
    echo "Brightness: $BRIGHTNESS_LEVEL%"
    echo "Dark Mode: $([ "$DISABLE_DARK_MODE" == "true" ] && echo "Disable" || echo "No change")"
    echo "Volume: $([ "$SYSTEM_VOLUME" != "-1" ] && echo "${SYSTEM_VOLUME}%" || echo "No change")"
    echo "Open Apps: ${OPEN_APPS:-"None"}"
    echo "Close Apps: ${CLOSE_APPS:-"None"}"
    echo "Weather: $([ "$SHOW_WEATHER" == "true" ] && echo "Enabled" || echo "Disabled")"
    
    echo
    if ! ask_yes_no "Save this configuration?"; then
        echo "Setup cancelled."
        exit 0
    fi
    
    write_configuration
    create_launchd_plist
    install_scheduled_task
    run_test
    show_summary
}

# Run the wizard
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi