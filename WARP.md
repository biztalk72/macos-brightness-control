# WARP.md

This file provides guidance to WARP (warp.dev) when working with code in this repository.

## Project Overview

This is a **macOS Brightness Control System** - an advanced morning routine automation tool that goes beyond simple brightness adjustment. The system automatically manages display brightness, system preferences, and application lifecycle as part of a comprehensive morning routine.

**Core Functionality:**
- Multi-method brightness control (keyboard simulation, DDC/CI for external monitors)
- Morning routine automation (dark mode, volume, app management)
- Scheduled execution via macOS LaunchAgents
- Comprehensive logging and error handling
- Weather integration and customizable notifications

## Key Commands

### Installation and Setup
```bash
# Full installation (recommended)
./install.sh

# Interactive configuration
./setup_wizard.sh

# Manual setup from config template
cp brightness_config.example ~/.brightness_config
```

### Development and Testing
```bash
# Test the main system manually
./brightness_control_enhanced.sh

# Check scheduled task status
launchctl list | grep brightness
launchctl print user/$(id -u)/com.user.brightness

# View system logs
tail -f ~/brightness_enhanced.log
tail -f ~/brightness_errors.log

# Reload scheduled task (after changes)
launchctl unload ~/Library/LaunchAgents/com.user.brightness.enhanced.plist
launchctl load ~/Library/LaunchAgents/com.user.brightness.enhanced.plist
```

### Configuration Management
```bash
# Edit configuration interactively
./setup_wizard.sh

# Edit configuration manually
nano ~/.brightness_config

# View current configuration
cat ~/.brightness_config

# Test configuration changes
./brightness_control_enhanced.sh
```

### External Dependencies
```bash
# Install external monitor tools
brew install ddcctl

# Alternative external monitor control
brew install --cask monitorcontrol

# Check tool availability
command -v ddcctl
```

## Architecture

### Main Components

1. **`brightness_control_enhanced.sh`** (462+ lines)
   - Main automation script with comprehensive error handling
   - Multiple brightness control methods with fallbacks
   - System preference management and application lifecycle control
   - Logging, notifications, and weather integration

2. **`setup_wizard.sh`** (400+ lines) 
   - Interactive configuration wizard with colorized output
   - System detection and prerequisite checking
   - LaunchAgent plist generation and installation
   - User-friendly prompts for all configuration options

3. **`install.sh`** (170+ lines)
   - One-command installation script
   - Prerequisite checking and Homebrew installation
   - Repository cloning and permission setup
   - Automated wizard execution

### Configuration System

The system uses a single configuration file (`~/.brightness_config`) with 25+ customizable options:

**Core Settings:**
- Brightness levels and control methods
- Scheduling (hour/minute)
- Display management (wake, DDC control)

**Morning Routine Features:**
- Dark mode management
- System volume control
- Do Not Disturb mode
- Application lifecycle (open/close apps)

**Advanced Options:**
- Battery-aware operation
- Timeout protection
- Weather integration
- Custom notifications
- External monitor tool selection

### Brightness Control Methods

The system implements **multiple fallback methods** for maximum compatibility:

1. **Keyboard Simulation**: Universal F1/F2 key presses via AppleScript
2. **DDC/CI Control**: Direct external monitor communication using `ddcctl`
3. **System APIs**: Native macOS brightness control
4. **Display Wake-up**: Ensures monitors are active before adjustment

### Logging Architecture

**Three-tier logging system:**
- `~/brightness_enhanced.log`: Main activity log with timestamps
- `~/brightness_errors.log`: Error-specific logging
- `~/brightness_daily_summary.txt`: Daily execution summaries

### LaunchAgent Integration

Uses macOS LaunchAgents for reliable scheduling:
- **Plist location**: `~/Library/LaunchAgents/com.user.brightness.enhanced.plist`
- **Calendar-based scheduling** (not interval-based)
- **Environment variable handling** for PATH and HOME
- **stdout/stderr redirection** for debugging

## Development Guidelines

### Code Style and Patterns
- **Bash strict mode**: `set -euo pipefail` for robust error handling
- **Comprehensive logging**: Every action logged with timestamps and severity levels
- **Graceful degradation**: Features fail independently without breaking the system
- **Configuration-driven**: All behavior controlled via external config file
- **AppleScript integration**: Heavy use of `osascript` for macOS system control

### Error Handling Strategy
- **Timeout protection**: `MAX_EXECUTION_TIME` prevents hanging processes
- **Battery awareness**: Optional skip when on battery power
- **Permission checking**: Validates accessibility permissions before execution
- **Tool availability**: Checks for external tools and provides alternatives
- **Non-blocking notifications**: Notification failures don't break the system

### External Monitor Support
- **Multiple tool support**: ddcctl, m1ddc, MonitorControl app
- **Auto-detection**: System can discover and control multiple external displays
- **Fallback methods**: If DDC fails, falls back to keyboard simulation
- **Monitor-specific settings**: Different brightness/contrast per display

### Testing Approach
- **Manual testing**: Direct script execution for immediate feedback
- **Configuration validation**: Setup wizard includes test runs
- **System integration**: LaunchAgent testing with system logs
- **Permission verification**: Automated checks for required macOS permissions

## Common Development Patterns

### Adding New Features
1. Add configuration options to `brightness_config.example`
2. Implement feature with proper error handling and logging
3. Add user-friendly prompts to `setup_wizard.sh`
4. Update documentation in `docs/CONFIGURATION.md`

### Configuration Management
- Use boolean values: `true`/`false` (not `1`/`0`)
- Numeric ranges: Include validation in setup wizard
- String lists: Comma-separated values for app names
- Special values: Use `-1` to disable numeric features

### macOS Integration
- **Accessibility permissions**: Required for keyboard simulation and app control
- **Automation permissions**: Needed for application lifecycle management
- **Full Disk Access**: Required for comprehensive system information
- **Privacy considerations**: All permissions documented in INSTALL.md

### External Tool Integration
- Check availability with `command -v tool_name`
- Provide installation instructions via Homebrew
- Implement graceful fallbacks when tools unavailable
- Log tool availability during system detection

This system demonstrates advanced macOS automation with production-ready error handling, comprehensive logging, and user-friendly configuration management.