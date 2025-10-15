#!/bin/bash

# macOS Brightness Control - One-Command Installer
# Enhanced Morning Routine Automation System

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Configuration
REPO_URL="https://github.com/YOUR_USERNAME/macos-brightness-control.git"
INSTALL_DIR="$HOME/macos-brightness-control"
SCRIPT_NAME="brightness_control_enhanced.sh"
WIZARD_NAME="setup_wizard.sh"

print_header() {
    echo -e "${CYAN}"
    echo "╔══════════════════════════════════════════════════════════════╗"
    echo "║            macOS Brightness Control Installer               ║"
    echo "║              Enhanced Morning Automation                     ║"
    echo "╚══════════════════════════════════════════════════════════════╝"
    echo -e "${NC}"
}

check_prerequisites() {
    echo -e "${BLUE}🔍 Checking prerequisites...${NC}"
    
    # Check macOS
    if [[ "$(uname)" != "Darwin" ]]; then
        echo -e "${RED}❌ Error: This installer is for macOS only${NC}"
        exit 1
    fi
    
    # Check for required commands
    local missing_commands=()
    for cmd in git curl osascript; do
        if ! command -v "$cmd" &> /dev/null; then
            missing_commands+=("$cmd")
        fi
    done
    
    if [[ ${#missing_commands[@]} -gt 0 ]]; then
        echo -e "${RED}❌ Missing required commands: ${missing_commands[*]}${NC}"
        exit 1
    fi
    
    # Check/Install Homebrew
    if ! command -v brew &> /dev/null; then
        echo -e "${YELLOW}📦 Installing Homebrew...${NC}"
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    fi
    
    echo -e "${GREEN}✅ Prerequisites check passed${NC}"
}

install_system() {
    echo -e "${BLUE}📥 Installing brightness control system...${NC}"
    
    # Remove existing installation if it exists
    if [[ -d "$INSTALL_DIR" ]]; then
        echo -e "${YELLOW}⚠️  Removing existing installation...${NC}"
        rm -rf "$INSTALL_DIR"
    fi
    
    # Clone repository
    echo -e "${BLUE}📦 Downloading latest version...${NC}"
    git clone "$REPO_URL" "$INSTALL_DIR" || {
        echo -e "${RED}❌ Failed to clone repository${NC}"
        exit 1
    }
    
    # Navigate to installation directory
    cd "$INSTALL_DIR"
    
    # Make scripts executable
    chmod +x "$SCRIPT_NAME" "$WIZARD_NAME" 2>/dev/null || {
        echo -e "${RED}❌ Failed to make scripts executable${NC}"
        exit 1
    }
    
    # Install external tools
    echo -e "${BLUE}🛠️  Installing external monitor tools...${NC}"
    brew install ddcctl 2>/dev/null || echo -e "${YELLOW}⚠️  Could not install ddcctl (optional)${NC}"
    
    echo -e "${GREEN}✅ Installation completed${NC}"
}

setup_configuration() {
    echo -e "${BLUE}⚙️  Setting up configuration...${NC}"
    
    # Copy example configuration
    if [[ -f "brightness_config.example" ]]; then
        cp brightness_config.example "$HOME/.brightness_config"
        echo -e "${GREEN}✅ Configuration template copied${NC}"
    fi
    
    echo -e "${BLUE}🎯 Running interactive setup wizard...${NC}"
    echo -e "${YELLOW}Follow the prompts to customize your morning routine${NC}"
    echo
    
    # Run setup wizard
    "./$WIZARD_NAME" || {
        echo -e "${RED}❌ Setup wizard failed${NC}"
        exit 1
    }
}

test_installation() {
    echo -e "${BLUE}🧪 Testing installation...${NC}"
    
    # Test the main script
    if "./$SCRIPT_NAME"; then
        echo -e "${GREEN}✅ Test completed successfully!${NC}"
    else
        echo -e "${YELLOW}⚠️  Test completed with some issues (check logs)${NC}"
    fi
}

show_completion_message() {
    echo
    echo -e "${CYAN}╔══════════════════════════════════════════════════════════════╗"
    echo -e "║                    🎉 Installation Complete!                ║"
    echo -e "╚══════════════════════════════════════════════════════════════╝${NC}"
    echo
    echo -e "${GREEN}Your enhanced brightness control system is now installed!${NC}"
    echo
    echo -e "${YELLOW}📁 Installation directory: $INSTALL_DIR${NC}"
    echo -e "${YELLOW}⚙️  Configuration file: ~/.brightness_config${NC}"
    echo -e "${YELLOW}📋 Full documentation: $INSTALL_DIR/README.md${NC}"
    echo
    echo -e "${BLUE}🚀 Next steps:${NC}"
    echo "   • The system will run automatically every morning at your configured time"
    echo "   • Test manually: cd $INSTALL_DIR && ./$SCRIPT_NAME"
    echo "   • Modify settings: cd $INSTALL_DIR && ./$WIZARD_NAME"
    echo "   • View logs: tail -f ~/brightness_enhanced.log"
    echo
    echo -e "${GREEN}Have a bright day! ☀️${NC}"
}

# Main execution
main() {
    print_header
    
    echo -e "${BLUE}This installer will set up an enhanced morning brightness control system${NC}"
    echo -e "${BLUE}that automatically manages your display brightness and morning routine.${NC}"
    echo
    
    read -p "$(echo -e ${YELLOW}Continue with installation? [y/N]: ${NC})" -n 1 -r
    echo
    
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo "Installation cancelled."
        exit 0
    fi
    
    check_prerequisites
    install_system
    setup_configuration
    test_installation
    show_completion_message
}

# Run installer
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi