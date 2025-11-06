# Brightness Control Schedule

## ✅ Setup Complete

Your brightness control script is now scheduled to run **every day at 8:40 AM**.

## How It Works

### 1. **Toggle Feature**
- If brightness is **0-9%** → switches to **100%**
- If brightness is **90-100%** → switches to **0%**
- Otherwise → uses configured brightness level (default: 100%)

### 2. **Multi-Monitor Support**
- Automatically detects all external displays
- Controls brightness on **all monitors simultaneously**
- Works with both built-in and external displays

## Scheduled Automation

**Service:** `com.brightness.control`  
**Schedule:** Daily at 8:40 AM  
**Configuration:** `~/Library/LaunchAgents/com.brightness.control.plist`

## Manual Control

Run the script manually anytime:
```bash
~/macos-brightness-control/brightness_control_enhanced.sh
```

## Management Commands

### Check if the service is running:
```bash
launchctl list | grep brightness
```

### Stop the scheduled task:
```bash
launchctl unload ~/Library/LaunchAgents/com.brightness.control.plist
```

### Start the scheduled task:
```bash
launchctl load ~/Library/LaunchAgents/com.brightness.control.plist
```

### View logs:
```bash
# Main log
tail -f ~/brightness_enhanced.log

# Scheduled run logs
tail -f ~/brightness_launchd.log

# Errors
tail -f ~/brightness_launchd_error.log
```

## Configuration

Edit settings in: `~/.brightness_config`

Key options:
- `BRIGHTNESS_LEVEL=100` - Default brightness when not toggling
- `ENABLE_TOGGLE_MODE=true` - Enable 0↔100 toggle feature
- `USE_DDC_CONTROL=true` - Control external monitors via DDC
- `DISABLE_DARK_MODE=true` - Disable macOS dark mode
- `SYSTEM_VOLUME=50` - Set system volume (or -1 to skip)

## Notes

- **Keyboard brightness control** ✅ Working
- **External monitor control** ⚠️ May require MonitorControl.app permissions
- The script works even if ddcctl has permission issues
- Logs are stored in `~/brightness_enhanced.log`

## Troubleshooting

If the script doesn't run at the scheduled time:
1. Check logs: `cat ~/brightness_launchd_error.log`
2. Verify service is loaded: `launchctl list | grep brightness`
3. Test manually first: `~/macos-brightness-control/brightness_control_enhanced.sh`
4. Ensure the script has execute permissions: `chmod +x ~/macos-brightness-control/brightness_control_enhanced.sh`
