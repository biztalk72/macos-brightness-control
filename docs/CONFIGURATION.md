# ⚙️ Configuration Guide

## Overview

The Enhanced macOS Brightness Control system uses a simple configuration file (`.brightness_config`) to customize its behavior. This guide explains all available options and provides examples for different use cases.

## Configuration File Location

The configuration file should be placed at: `~/.brightness_config`

## Configuration Options

### Brightness Settings

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| `BRIGHTNESS_LEVEL` | Integer (0-100) | 100 | Target brightness level |
| `BRIGHTNESS_KEY_PRESSES` | Integer (10-50) | 25 | Number of brightness key presses for safety |
| `USE_DDC_CONTROL` | Boolean | true | Enable DDC control for external monitors |
| `USE_KEYBOARD_SIMULATION` | Boolean | true | Enable keyboard brightness simulation |
| `WAKE_DISPLAYS` | Boolean | true | Wake up displays before adjustment |

### Scheduling

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| `SCHEDULE_HOUR` | Integer (0-23) | 8 | Hour to run (24-hour format) |
| `SCHEDULE_MINUTE` | Integer (0-59) | 50 | Minute to run |
| `ACTION_DELAY` | Float | 0.5 | Delay between actions (seconds) |

### Morning Routine Features

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| `DISABLE_DARK_MODE` | Boolean | true | Switch to light mode |
| `SYSTEM_VOLUME` | Integer (-1, 0-100) | 50 | Set system volume (-1 to skip) |
| `ENABLE_DND` | Boolean | false | Enable Do Not Disturb mode |
| `OPEN_APPS` | String | "" | Comma-separated apps to open |
| `CLOSE_APPS` | String | "" | Comma-separated apps to close |

### Advanced Options

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| `VERBOSE_LOGGING` | Boolean | true | Enable detailed logging |
| `SHOW_NOTIFICATIONS` | Boolean | true | Show desktop notifications |
| `PLAY_SOUND` | Boolean | false | Play sound when complete |
| `CHECK_UPDATES` | Boolean | false | Check for system updates |
| `SKIP_ON_BATTERY` | Boolean | false | Skip when on battery power |
| `MAX_EXECUTION_TIME` | Integer (30-300) | 60 | Maximum execution time (seconds) |
| `EXTERNAL_MONITOR_TOOL` | String | auto | External monitor tool (ddcctl, m1ddc, auto) |

### Weather Integration

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| `SHOW_WEATHER` | Boolean | false | Display weather information |
| `WEATHER_API_KEY` | String | "" | OpenWeatherMap API key |
| `WEATHER_CITY` | String | "Seoul" | City for weather |

### Customization

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| `CUSTOM_MESSAGE` | String | "Good morning! Your displays are ready ☀️" | Custom notification message |
| `SHOW_GREETING` | Boolean | true | Show morning greeting |

## Configuration Examples

### 1. Developer Setup

Perfect for developers who want to start their day with the right environment:

```bash
# === BRIGHTNESS SETTINGS ===
BRIGHTNESS_LEVEL=100
BRIGHTNESS_KEY_PRESSES=30

# === TIMING SETTINGS ===
SCHEDULE_HOUR=7
SCHEDULE_MINUTE=30

# === MORNING ROUTINE FEATURES ===
DISABLE_DARK_MODE=true
SYSTEM_VOLUME=30
ENABLE_DND=false

# === APPLICATION MANAGEMENT ===
OPEN_APPS="Visual Studio Code,Terminal,Slack,Spotify"
CLOSE_APPS="Safari,Twitter"

# === ADVANCED SETTINGS ===
VERBOSE_LOGGING=true
SHOW_NOTIFICATIONS=true
PLAY_SOUND=true
SHOW_WEATHER=true
WEATHER_CITY="San Francisco"

# === CUSTOMIZATION ===
CUSTOM_MESSAGE="Ready to code! Have a productive day 💻"
```

### 2. Content Creator Setup

Optimized for video/photo editing with maximum brightness and specific apps:

```bash
# === BRIGHTNESS SETTINGS ===
BRIGHTNESS_LEVEL=100
BRIGHTNESS_KEY_PRESSES=35
USE_DDC_CONTROL=true

# === TIMING SETTINGS ===
SCHEDULE_HOUR=9
SCHEDULE_MINUTE=0

# === MORNING ROUTINE FEATURES ===
DISABLE_DARK_MODE=true
SYSTEM_VOLUME=25
ENABLE_DND=true

# === APPLICATION MANAGEMENT ===
OPEN_APPS="Adobe Photoshop,Final Cut Pro,Adobe Lightroom,Music"
CLOSE_APPS="Mail,Messages"

# === ADVANCED SETTINGS ===
SKIP_ON_BATTERY=true
SHOW_WEATHER=false

# === CUSTOMIZATION ===
CUSTOM_MESSAGE="Creative workspace ready! Time to create ✨"
```

### 3. Minimalist Setup

Simple brightness control without extra features:

```bash
# === BRIGHTNESS SETTINGS ===
BRIGHTNESS_LEVEL=90
BRIGHTNESS_KEY_PRESSES=20

# === TIMING SETTINGS ===
SCHEDULE_HOUR=8
SCHEDULE_MINUTE=0

# === MORNING ROUTINE FEATURES ===
DISABLE_DARK_MODE=false
SYSTEM_VOLUME=-1
ENABLE_DND=false

# === APPLICATION MANAGEMENT ===
OPEN_APPS=""
CLOSE_APPS=""

# === ADVANCED SETTINGS ===
VERBOSE_LOGGING=false
SHOW_NOTIFICATIONS=false
PLAY_SOUND=false
SHOW_WEATHER=false

# === CUSTOMIZATION ===
SHOW_GREETING=false
```

### 4. Home Office Setup

For remote workers with calendar integration and focus mode:

```bash
# === BRIGHTNESS SETTINGS ===
BRIGHTNESS_LEVEL=85
BRIGHTNESS_KEY_PRESSES=25

# === TIMING SETTINGS ===
SCHEDULE_HOUR=8
SCHEDULE_MINUTE=45

# === MORNING ROUTINE FEATURES ===
DISABLE_DARK_MODE=true
SYSTEM_VOLUME=40
ENABLE_DND=false

# === APPLICATION MANAGEMENT ===
OPEN_APPS="Calendar,Mail,Slack,Zoom"
CLOSE_APPS="TikTok,Instagram,Twitter"

# === ADVANCED SETTINGS ===
SHOW_WEATHER=true
WEATHER_CITY="New York"
SKIP_ON_BATTERY=true

# === CUSTOMIZATION ===
CUSTOM_MESSAGE="Good morning! Ready for another productive day from home 🏠"
```

### 5. Night Shift Worker Setup

For those working non-traditional hours:

```bash
# === BRIGHTNESS SETTINGS ===
BRIGHTNESS_LEVEL=60
BRIGHTNESS_KEY_PRESSES=15

# === TIMING SETTINGS ===
SCHEDULE_HOUR=22
SCHEDULE_MINUTE=0

# === MORNING ROUTINE FEATURES ===
DISABLE_DARK_MODE=false
SYSTEM_VOLUME=20
ENABLE_DND=true

# === APPLICATION MANAGEMENT ===
OPEN_APPS="Terminal,Music"
CLOSE_APPS=""

# === ADVANCED SETTINGS ===
SHOW_WEATHER=false
PLAY_SOUND=false

# === CUSTOMIZATION ===
CUSTOM_MESSAGE="Night shift ready! Stay focused 🌙"
```

## Tips and Best Practices

### 1. Testing Configuration Changes
Always test your configuration after making changes:
```bash
./brightness_control_enhanced.sh
```

### 2. Application Names
Use exact application names as they appear in Applications folder:
- ✅ "Visual Studio Code"
- ❌ "vscode" or "VS Code"
- ✅ "Adobe Photoshop"
- ❌ "photoshop"

### 3. Volume Levels
- Use `-1` to skip volume adjustment
- Volume range is 0-100
- Consider your typical listening environment

### 4. Weather API Setup
1. Sign up at [OpenWeatherMap](https://openweathermap.org/api)
2. Get your free API key
3. Add it to `WEATHER_API_KEY`

### 5. External Monitor Compatibility
- `ddcctl` works with most external monitors
- Some monitors need DDC/CI enabled in their settings
- Try `MonitorControl` app as an alternative

### 6. Battery Awareness
Set `SKIP_ON_BATTERY=true` to preserve laptop battery when unplugged.

### 7. Logging
Keep `VERBOSE_LOGGING=true` initially to debug any issues, then set to `false` for cleaner logs.

## Troubleshooting Configuration

### Configuration Not Loading
1. Check file location: `~/.brightness_config`
2. Verify file permissions: `chmod 644 ~/.brightness_config`
3. Check syntax (no spaces around `=`)

### Apps Not Opening/Closing
1. Use exact application names
2. Check Application folder names
3. Verify app permissions in Privacy settings

### External Monitors Not Responding
1. Enable DDC/CI in monitor settings
2. Try different `EXTERNAL_MONITOR_TOOL` values
3. Install additional tools: `brew install m1ddc`

### Schedule Not Working
1. Verify launchd task: `launchctl list | grep brightness`
2. Check system date/time
3. Reload task: `launchctl unload && launchctl load`

## Advanced Customization

For advanced users, you can modify the main script to add custom functionality:

1. Add custom functions before the `main()` function
2. Call them in the appropriate section of `main()`
3. Add corresponding configuration options

Example:
```bash
# Custom function
set_desktop_wallpaper() {
    if [[ "$CHANGE_WALLPAPER" == "true" ]]; then
        osascript -e "tell application \"System Events\" to tell every desktop to set picture to \"$WALLPAPER_PATH\""
    fi
}

# Add to configuration
CHANGE_WALLPAPER=true
WALLPAPER_PATH="/Users/$(whoami)/Pictures/morning-wallpaper.jpg"
```