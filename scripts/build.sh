#!/bin/bash

# FilehHash General Build Script
# This script provides a simple interface for building the project

set -e  # Exit on any error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Script configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
BUILD_TYPE="release"
VERBOSE=false
INSTALL_AFTER_BUILD=false
RUN_TESTS=false

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

# Function to show usage
show_usage() {
    cat << EOF
Usage: $0 [OPTIONS]

FilehHash Build Script - Build the filehash binary

OPTIONS:
    -h, --help          Show this help message
    -d, --debug         Build with debug symbols
    -r, --release       Build optimized release version (default)
    -c, --clean         Clean build artifacts before building
    -i, --install       Install after successful build
    -t, --test          Run tests after build
    -v, --verbose       Enable verbose output
    --check-deps        Check dependencies only
    --clean-only        Clean build artifacts and exit

EXAMPLES:
    $0                  # Build release version
    $0 -d               # Build debug version
    $0 -c -r            # Clean and build release
    $0 -r -i -t         # Build, install, and test
    $0 --check-deps     # Check if dependencies are available

EOF
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
    if ! command_exists gcc; then
        print_error "gcc not found. Install with: sudo apt-get install build-essential"
        deps_missing=true
    fi

    if ! command_exists make; then
        print_error "make not found. Install with: sudo apt-get install build-essential"
        deps_missing=true
    fi

    # Check for pkg-config
    if ! command_exists pkg-config; then
        print_error "pkg-config not found. Install with: sudo apt-get install pkg-config"
        deps_missing=true
    fi

    # Check for OpenSSL development libraries
    if ! pkg-config --exists openssl; then
        print_error "OpenSSL development libraries not found."
        print_error "Install with: sudo apt-get install libssl-dev"
        deps_missing=true
    fi

    if [ "$deps_missing" = true ]; then
        print_error "Missing required dependencies. Please install them and try again."
        return 1
    fi

    print_success "All build dependencies are available"

    # Show versions if verbose
    if [ "$VERBOSE" = true ]; then
        print_status "Dependency versions:"
        gcc --version | head -1
        make --version | head -1
        pkg-config --version
        pkg-config --modversion openssl
    fi

    return 0
}

# Function to clean build artifacts
clean_build() {
    print_status "Cleaning build artifacts..."

    cd "$PROJECT_ROOT"

    if [ -f Makefile ]; then
        if [ "$VERBOSE" = true ]; then
            make clean
        else
            make clean >/dev/null 2>&1
        fi
    fi

    # Additional cleanup
    rm -rf build/
    find . -name "*.o" -delete 2>/dev/null || true
    find . -name "*.so" -delete 2>/dev/null || true
    find . -name "*.a" -delete 2>/dev/null || true

    print_success "Build artifacts cleaned"
}

# Function to build the project
build_project() {
    print_status "Building filehash ($BUILD_TYPE mode)..."

    cd "$PROJECT_ROOT"

    # Determine build target
    local make_target="all"
    if [ "$BUILD_TYPE" = "debug" ]; then
        make_target="debug"
    fi

    # Build the project
    if [ "$VERBOSE" = true ]; then
        make "$make_target"
    else
        if ! make "$make_target" >/dev/null 2>&1; then
            print_error "Build failed. Try running with --verbose for more details."
            return 1
        fi
    fi

    # Verify build output
    if [ ! -f "build/bin/filehash" ]; then
        print_error "Build completed but binary not found at build/bin/filehash"
        return 1
    fi

    print_success "Build completed successfully"

    # Show binary info
    local binary_size=$(stat -c%s "build/bin/filehash" 2>/dev/null || echo "unknown")
    print_status "Binary size: $binary_size bytes"

    if [ "$VERBOSE" = true ]; then
        print_status "Binary info:"
        file build/bin/filehash
        ldd build/bin/filehash 2>/dev/null || print_warning "ldd info not available"
    fi
}

# Function to run basic tests
run_basic_tests() {
    print_status "Running basic functionality tests..."

    cd "$PROJECT_ROOT"

    if [ ! -f "build/bin/filehash" ]; then
        print_error "Binary not found. Build first."
        return 1
    fi

    # Test 1: Help option
    print_status "Testing help option..."
    if ! ./build/bin/filehash --help >/dev/null 2>&1; then
        print_error "Help option test failed"
        return 1
    fi

    # Test 2: Version option
    print_status "Testing version option..."
    if ! ./build/bin/filehash --version >/dev/null 2>&1; then
        print_error "Version option test failed"
        return 1
    fi

    # Test 3: Basic hash calculation
    print_status "Testing hash calculation..."
    echo "test content" > /tmp/filehash_build_test.txt

    local md5_result=$(./build/bin/filehash /tmp/filehash_build_test.txt 2>/dev/null)
    if [ $? -ne 0 ] || [ -z "$md5_result" ]; then
        print_error "Basic hash calculation test failed"
        rm -f /tmp/filehash_build_test.txt
        return 1
    fi

    # Test 4: Different algorithms
    if ! ./build/bin/filehash -s /tmp/filehash_build_test.txt >/dev/null 2>&1; then
        print_error "SHA1 test failed"
        rm -f /tmp/filehash_build_test.txt
        return 1
    fi

    if ! ./build/bin/filehash -S /tmp/filehash_build_test.txt >/dev/null 2>&1; then
        print_error "SHA256 test failed"
        rm -f /tmp/filehash_build_test.txt
        return 1
    fi

    rm -f /tmp/filehash_build_test.txt

    print_success "All basic tests passed"

    if [ "$VERBOSE" = true ]; then
        print_status "Sample output:"
        echo "test content" > /tmp/filehash_build_test.txt
        ./build/bin/filehash -a /tmp/filehash_build_test.txt
        rm -f /tmp/filehash_build_test.txt
    fi
}

# Function to install the binary
install_binary() {
    print_status "Installing filehash..."

    cd "$PROJECT_ROOT"

    if [ ! -f "build/bin/filehash" ]; then
        print_error "Binary not found. Build first."
        return 1
    fi

    # Use make install if available, otherwise manual install
    if grep -q "^install:" Makefile 2>/dev/null; then
        if [ "$VERBOSE" = true ]; then
            sudo make install
        else
            sudo make install >/dev/null 2>&1
        fi
    else
        # Manual installation
        sudo install -d /usr/local/bin
        sudo install -m 755 build/bin/filehash /usr/local/bin/

        # Install man page if available
        if [ -f "docs/filehash.1" ]; then
            sudo install -d /usr/local/share/man/man1
            sudo install -m 644 docs/filehash.1 /usr/local/share/man/man1/
        fi
    fi

    print_success "Installation completed"

    # Verify installation
    if command_exists filehash; then
        print_status "Verification: filehash is available in PATH"
        if [ "$VERBOSE" = true ]; then
            filehash --version
        fi
    else
        print_warning "filehash not found in PATH after installation"
    fi
}

# Function to show build results
show_results() {
    print_status "Build Summary"
    echo "=============="

    if [ -f "$PROJECT_ROOT/build/bin/filehash" ]; then
        echo " Binary: $PROJECT_ROOT/build/bin/filehash"
        echo " Size: $(stat -c%s "$PROJECT_ROOT/build/bin/filehash" 2>/dev/null || echo "unknown") bytes"
    else
        echo " Binary: Not found"
    fi

    if command_exists filehash; then
        echo " Installed: $(which filehash)"
    else
        echo "Ë Installed: No"
    fi

    echo
    print_status "To run the program:"
    echo "  $PROJECT_ROOT/build/bin/filehash --help"

    if command_exists filehash; then
        echo "  filehash --help"
    fi

    echo
    print_status "To install system-wide:"
    echo "  sudo make install"
    echo "  # or"
    echo "  $0 --install"
}

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        -h|--help)
            show_usage
            exit 0
            ;;
        -d|--debug)
            BUILD_TYPE="debug"
            shift
            ;;
        -r|--release)
            BUILD_TYPE="release"
            shift
            ;;
        -c|--clean)
            clean_build
            shift
            ;;
        -i|--install)
            INSTALL_AFTER_BUILD=true
            shift
            ;;
        -t|--test)
            RUN_TESTS=true
            shift
            ;;
        -v|--verbose)
            VERBOSE=true
            shift
            ;;
        --check-deps)
            check_dependencies
            exit $?
            ;;
        --clean-only)
            clean_build
            exit 0
            ;;
        *)
            print_error "Unknown option: $1"
            show_usage
            exit 1
            ;;
    esac
done

# Main execution
main() {
    echo "FilehHash Build Script"
    echo "====================="
    echo

    # Ensure we're in the right directory
    if [ ! -f "$PROJECT_ROOT/src/filehash.c" ] || [ ! -f "$PROJECT_ROOT/Makefile" ]; then
        print_error "Project files not found. Please run from project directory."
        exit 1
    fi

    # Execute build steps
    check_dependencies || exit 1
    build_project || exit 1

    if [ "$RUN_TESTS" = true ]; then
        run_basic_tests || exit 1
    fi

    if [ "$INSTALL_AFTER_BUILD" = true ]; then
        install_binary || exit 1
    fi

    show_results
    print_success "Build process completed!"
}

# Run main function
main "$@"