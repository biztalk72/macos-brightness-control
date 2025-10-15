# 🚀 Quick Installation Guide

## Prerequisites

- macOS (tested on macOS 14+ Sonoma/Sequoia)
- Homebrew (for external monitor tools)
- Terminal with Full Disk Access permissions

## One-Command Installation

```bash
# Download and run the setup wizard
curl -fsSL https://raw.githubusercontent.com/YOUR_USERNAME/macos-brightness-control/main/install.sh | bash
```

## Manual Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/YOUR_USERNAME/macos-brightness-control.git
   cd macos-brightness-control
   ```

2. **Make scripts executable**
   ```bash
   chmod +x brightness_control_enhanced.sh setup_wizard.sh
   ```

3. **Run the interactive setup**
   ```bash
   ./setup_wizard.sh
   ```

4. **Test the installation**
   ```bash
   ./brightness_control_enhanced.sh
   ```

## Quick Setup

1. **Copy configuration template**
   ```bash
   cp brightness_config.example ~/.brightness_config
   ```

2. **Edit configuration** (optional)
   ```bash
   nano ~/.brightness_config
   ```

3. **Install the scheduled task**
   ```bash
   ./setup_wizard.sh
   ```

## Permissions Required

The system needs the following macOS permissions:

- **Accessibility**: For controlling brightness keys and system preferences
- **Automation**: For opening/closing applications
- **Full Disk Access**: For reading system information

Grant these in: **System Preferences → Security & Privacy → Privacy**

## Troubleshooting

- **External monitors not working?** Install ddcctl: `brew install ddcctl`
- **Permissions issues?** Check Privacy settings in System Preferences
- **Script not running?** Verify launchd task: `launchctl list | grep brightness`

## Support

- 📖 [Full Documentation](README.md)
- 🐛 [Report Issues](https://github.com/YOUR_USERNAME/macos-brightness-control/issues)
- 💡 [Feature Requests](https://github.com/YOUR_USERNAME/macos-brightness-control/discussions)