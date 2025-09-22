#!/bin/bash

# FilehHash Dependencies Installation Script
# This script installs all required dependencies for building filehash

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Detect OS
detect_os() {
    if [ -f /etc/os-release ]; then
        . /etc/os-release
        OS=$ID
        VERSION=$VERSION_ID

        # Handle specific distributions first
        case $OS in
            ubuntu|debian)
                # Keep original OS
                ;;
            zorin|linuxmint|elementary|pop)
                # Ubuntu-based distributions
                if [ -n "$ID_LIKE" ] && echo "$ID_LIKE" | grep -q "ubuntu"; then
                    OS="ubuntu"
                fi
                ;;
            *)
                # For other distributions, check ID_LIKE
                if [ -n "$ID_LIKE" ]; then
                    if echo "$ID_LIKE" | grep -q "ubuntu"; then
                        OS="ubuntu"
                    elif echo "$ID_LIKE" | grep -q "debian"; then
                        OS="debian"
                    fi
                fi
                ;;
        esac
    else
        print_error "Cannot detect OS"
        exit 1
    fi
}

# Install dependencies for Debian/Ubuntu
install_debian_deps() {
    print_status "Installing dependencies for Debian/Ubuntu..."

    # Update package list
    sudo apt-get update

    # Install build essentials
    sudo apt-get install -y build-essential

    # Install OpenSSL development libraries
    sudo apt-get install -y libssl-dev

    # Install pkg-config
    sudo apt-get install -y pkg-config

    # Install packaging tools (optional)
    if [ "${1:-}" = "--packaging" ]; then
        sudo apt-get install -y debhelper devscripts
    fi

    print_success "Dependencies installed successfully"
}

# Main function
main() {
    echo "FilehHash Dependencies Installer"
    echo "==============================="
    echo

    detect_os

    case $OS in
        ubuntu|debian)
            install_debian_deps "$@"
            ;;
        *)
            print_error "Unsupported OS: $OS"
            print_status "Please install manually:"
            echo "  - build-essential (gcc, make)"
            echo "  - libssl-dev (OpenSSL development libraries)"
            echo "  - pkg-config"
            exit 1
            ;;
    esac

    print_success "All dependencies installed!"
}

main "$@"