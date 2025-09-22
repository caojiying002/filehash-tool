#!/bin/bash

# FilehHash Debian Package Build Script
# This script automates the process of building a .deb package

set -e  # Exit on any error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
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

# Function to check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Function to check dependencies
check_dependencies() {
    print_status "Checking build dependencies..."

    local deps_missing=false

    # Check for essential build tools
    if ! command_exists dpkg-buildpackage; then
        print_error "dpkg-buildpackage not found. Install with: sudo apt-get install devscripts"
        deps_missing=true
    fi

    if ! command_exists debuild; then
        print_warning "debuild not found. Installing devscripts is recommended."
    fi

    if ! command_exists gcc; then
        print_error "gcc not found. Install with: sudo apt-get install build-essential"
        deps_missing=true
    fi

    # Check for OpenSSL development libraries
    if ! pkg-config --exists openssl; then
        print_error "OpenSSL development libraries not found. Install with: sudo apt-get install libssl-dev"
        deps_missing=true
    fi

    if [ "$deps_missing" = true ]; then
        print_error "Missing required dependencies. Please install them and try again."
        exit 1
    fi

    print_success "All dependencies are available"
}

# Function to clean previous builds
clean_previous_builds() {
    print_status "Cleaning previous builds..."

    # Clean make artifacts
    if [ -f Makefile ]; then
        make clean >/dev/null 2>&1 || true
    fi

    # Clean debian artifacts
    if [ -d debian/.debhelper ]; then
        rm -rf debian/.debhelper
    fi

    if [ -f debian/files ]; then
        rm -f debian/files
    fi

    if [ -f debian/debhelper-build-stamp ]; then
        rm -f debian/debhelper-build-stamp
    fi

    # Clean parent directory artifacts
    rm -f ../filehash_*.deb ../filehash_*.changes ../filehash_*.buildinfo ../filehash_*.dsc ../filehash_*.tar.gz ../filehash_*.ddeb >/dev/null 2>&1 || true

    print_success "Cleaned previous builds"
}

# Function to verify source files
verify_source_files() {
    print_status "Verifying source files..."

    # Check essential source files
    if [ ! -f src/filehash.c ]; then
        print_error "Missing source file: src/filehash.c"
        exit 1
    fi

    if [ ! -f src/filehash.h ]; then
        print_error "Missing header file: src/filehash.h"
        exit 1
    fi

    if [ ! -f Makefile ]; then
        print_error "Missing Makefile"
        exit 1
    fi

    # Check debian packaging files
    local debian_files=("control" "rules" "changelog" "compat" "copyright")
    for file in "${debian_files[@]}"; do
        if [ ! -f "debian/$file" ]; then
            print_error "Missing debian file: debian/$file"
            exit 1
        fi
    done

    # Check if debian/rules is executable
    if [ ! -x debian/rules ]; then
        print_warning "debian/rules is not executable, fixing..."
        chmod +x debian/rules
    fi

    print_success "All source files verified"
}

# Function to run pre-build tests
run_prebuild_tests() {
    print_status "Running pre-build tests..."

    # Test compilation
    if ! make all >/dev/null 2>&1; then
        print_error "Source code compilation failed"
        exit 1
    fi

    # Test basic functionality
    if [ -f build/bin/filehash ]; then
        echo "test" > /tmp/filehash_test.txt
        if ! ./build/bin/filehash /tmp/filehash_test.txt >/dev/null 2>&1; then
            print_error "Basic functionality test failed"
            rm -f /tmp/filehash_test.txt
            exit 1
        fi
        rm -f /tmp/filehash_test.txt
    fi

    # Clean after test
    make clean >/dev/null 2>&1

    print_success "Pre-build tests passed"
}

# Function to build the package
build_package() {
    print_status "Building Debian package..."

    # Build the package (unsigned)
    if dpkg-buildpackage -us -uc -b; then
        print_success "Package built successfully"
    else
        print_error "Package build failed"
        exit 1
    fi
}

# Function to verify built packages
verify_packages() {
    print_status "Verifying built packages..."

    # Check if .deb file was created
    local deb_file=$(ls ../filehash_*.deb 2>/dev/null | head -n1)
    if [ -z "$deb_file" ]; then
        print_error "No .deb file found"
        exit 1
    fi

    print_success "Found package: $(basename "$deb_file")"

    # Check package info
    print_status "Package information:"
    dpkg -I "$deb_file" | head -20

    # Check package contents
    print_status "Package contents:"
    dpkg -c "$deb_file"

    # Test package installation (dry run)
    print_status "Testing package installation (dry run)..."
    if dpkg --dry-run -i "$deb_file" >/dev/null 2>&1; then
        print_success "Package installation test passed"
    else
        print_warning "Package installation test failed (may require dependencies)"
    fi
}

# Function to show final results
show_results() {
    print_status "Build completed successfully!"
    echo
    print_status "Generated files:"
    ls -la ../filehash_* 2>/dev/null || print_warning "No package files found in parent directory"

    echo
    print_status "To install the package, run:"
    echo "  sudo dpkg -i ../filehash_*.deb"
    echo "  sudo apt-get install -f  # if there are dependency issues"

    echo
    print_status "To uninstall later, run:"
    echo "  sudo dpkg -r filehash"
}

# Main execution
main() {
    echo "FilehHash Debian Package Builder"
    echo "================================"
    echo

    # Change to script directory
    cd "$(dirname "$0")/.."

    # Check if we're in the right directory
    if [ ! -f "src/filehash.c" ] || [ ! -d "debian" ]; then
        print_error "Please run this script from the project root directory"
        exit 1
    fi

    # Execute build steps
    check_dependencies
    clean_previous_builds
    verify_source_files
    run_prebuild_tests
    build_package
    verify_packages
    show_results

    print_success "All done!"
}

# Handle script arguments
case "${1:-}" in
    --help|-h)
        echo "Usage: $0 [options]"
        echo
        echo "Options:"
        echo "  --help, -h     Show this help message"
        echo "  --clean-only   Only clean previous builds"
        echo "  --no-tests     Skip pre-build tests"
        echo
        exit 0
        ;;
    --clean-only)
        cd "$(dirname "$0")/.."
        clean_previous_builds
        exit 0
        ;;
    --no-tests)
        # Redefine function to skip tests
        run_prebuild_tests() {
            print_warning "Skipping pre-build tests"
        }
        ;;
esac

# Run main function
main "$@"