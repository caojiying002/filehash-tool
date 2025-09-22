#!/bin/bash

# FilehHash Test Suite
# Comprehensive testing script for filehash functionality

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Test configuration
TEST_DIR="$(dirname "$0")"
PROJECT_ROOT="$(dirname "$TEST_DIR")"
BINARY="$PROJECT_ROOT/build/bin/filehash"
TEST_FILES_DIR="$TEST_DIR/test-files"
TEMP_DIR="/tmp/filehash-tests"

# Counters
tests_run=0
tests_passed=0
tests_failed=0

print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[PASS]${NC} $1"
}

print_error() {
    echo -e "${RED}[FAIL]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

# Test helper functions
run_test() {
    local test_name="$1"
    local test_command="$2"
    local expected_exit_code="${3:-0}"

    tests_run=$((tests_run + 1))

    print_status "Running: $test_name"

    if eval "$test_command" >/dev/null 2>&1; then
        actual_exit_code=0
    else
        actual_exit_code=$?
    fi

    if [ "$actual_exit_code" = "$expected_exit_code" ]; then
        print_success "$test_name"
        tests_passed=$((tests_passed + 1))
        return 0
    else
        print_error "$test_name (expected exit code $expected_exit_code, got $actual_exit_code)"
        tests_failed=$((tests_failed + 1))
        return 1
    fi
}

# Setup test environment
setup_tests() {
    print_status "Setting up test environment..."

    # Create temp directory
    mkdir -p "$TEMP_DIR"

    # Check if binary exists
    if [ ! -f "$BINARY" ]; then
        print_error "Binary not found at $BINARY"
        print_status "Please build the project first: make"
        exit 1
    fi

    # Create test files with known content
    echo -n "" > "$TEMP_DIR/empty.txt"
    echo -n "hello" > "$TEMP_DIR/hello.txt"
    echo -n "test content for hashing" > "$TEMP_DIR/test.txt"

    # Create binary test file
    printf "\x00\x01\x02\x03\x04\x05" > "$TEMP_DIR/binary.dat"

    print_success "Test environment ready"
}

# Cleanup test environment
cleanup_tests() {
    print_status "Cleaning up test environment..."
    rm -rf "$TEMP_DIR"
}

# Basic functionality tests
test_basic_functionality() {
    print_status "=== Basic Functionality Tests ==="

    # Test help option
    run_test "Help option (--help)" "$BINARY --help"
    run_test "Help option (-h)" "$BINARY -h"

    # Test version option
    run_test "Version option (--version)" "$BINARY --version"
    run_test "Version option (-v)" "$BINARY -v"

    # Test no arguments (should fail)
    run_test "No arguments" "$BINARY" 1
}

# Hash calculation tests
test_hash_calculations() {
    print_status "=== Hash Calculation Tests ==="

    # MD5 tests
    run_test "MD5 hash of empty file" "$BINARY $TEMP_DIR/empty.txt"
    run_test "MD5 hash with -m option" "$BINARY -m $TEMP_DIR/hello.txt"
    run_test "MD5 hash with --md5 option" "$BINARY --md5 $TEMP_DIR/hello.txt"

    # SHA1 tests
    run_test "SHA1 hash with -s option" "$BINARY -s $TEMP_DIR/hello.txt"
    run_test "SHA1 hash with --sha1 option" "$BINARY --sha1 $TEMP_DIR/hello.txt"

    # SHA256 tests
    run_test "SHA256 hash with -S option" "$BINARY -S $TEMP_DIR/hello.txt"
    run_test "SHA256 hash with --sha256 option" "$BINARY --sha256 $TEMP_DIR/hello.txt"

    # All algorithms test
    run_test "All algorithms with -a option" "$BINARY -a $TEMP_DIR/hello.txt"
    run_test "All algorithms with --all option" "$BINARY --all $TEMP_DIR/hello.txt"
}

# Multiple files tests
test_multiple_files() {
    print_status "=== Multiple Files Tests ==="

    run_test "Multiple files" "$BINARY $TEMP_DIR/empty.txt $TEMP_DIR/hello.txt $TEMP_DIR/test.txt"
    run_test "Multiple files with SHA256" "$BINARY -S $TEMP_DIR/empty.txt $TEMP_DIR/hello.txt"
}

# Error handling tests
test_error_handling() {
    print_status "=== Error Handling Tests ==="

    # Test nonexistent file
    run_test "Nonexistent file" "$BINARY /nonexistent/file.txt" 1

    # Test invalid option
    run_test "Invalid option" "$BINARY --invalid-option" 1

    # Test directory instead of file
    run_test "Directory as input" "$BINARY $TEMP_DIR" 1
}

# Known hash verification tests
test_known_hashes() {
    print_status "=== Known Hash Verification Tests ==="

    # Test empty file hashes (known values)
    local empty_md5_output=$($BINARY $TEMP_DIR/empty.txt)
    if echo "$empty_md5_output" | grep -q "d41d8cd98f00b204e9800998ecf8427e"; then
        print_success "Empty file MD5 hash verification"
        tests_passed=$((tests_passed + 1))
    else
        print_error "Empty file MD5 hash verification"
        tests_failed=$((tests_failed + 1))
    fi
    tests_run=$((tests_run + 1))

    # Test "hello" string hashes
    local hello_md5_output=$($BINARY $TEMP_DIR/hello.txt)
    if echo "$hello_md5_output" | grep -q "5d41402abc4b2a76b9719d911017c592"; then
        print_success "Hello file MD5 hash verification"
        tests_passed=$((tests_passed + 1))
    else
        print_error "Hello file MD5 hash verification"
        tests_failed=$((tests_failed + 1))
    fi
    tests_run=$((tests_run + 1))
}

# Binary file tests
test_binary_files() {
    print_status "=== Binary File Tests ==="

    run_test "Binary file MD5" "$BINARY $TEMP_DIR/binary.dat"
    run_test "Binary file SHA256" "$BINARY -S $TEMP_DIR/binary.dat"
}

# Performance tests (optional)
test_performance() {
    print_status "=== Performance Tests ==="

    # Create a larger test file
    dd if=/dev/zero of="$TEMP_DIR/large.dat" bs=1M count=1 >/dev/null 2>&1

    run_test "Large file (1MB) MD5" "timeout 30 $BINARY $TEMP_DIR/large.dat"
    run_test "Large file (1MB) SHA256" "timeout 30 $BINARY -S $TEMP_DIR/large.dat"

    rm -f "$TEMP_DIR/large.dat"
}

# Show test results
show_results() {
    echo
    print_status "=== Test Results ==="
    echo "Tests run: $tests_run"
    echo "Tests passed: $tests_passed"
    echo "Tests failed: $tests_failed"

    if [ $tests_failed -eq 0 ]; then
        print_success "All tests passed!"
        return 0
    else
        print_error "$tests_failed test(s) failed"
        return 1
    fi
}

# Main test execution
main() {
    echo "FilehHash Test Suite"
    echo "=================="
    echo

    # Setup
    setup_tests

    # Run test suites
    test_basic_functionality
    test_hash_calculations
    test_multiple_files
    test_error_handling
    test_known_hashes
    test_binary_files

    # Optional performance tests
    if [ "${1:-}" = "--performance" ]; then
        test_performance
    fi

    # Show results
    show_results
    local exit_code=$?

    # Cleanup
    cleanup_tests

    exit $exit_code
}

# Handle arguments
case "${1:-}" in
    --help|-h)
        echo "Usage: $0 [--performance] [--help]"
        echo "Run filehash test suite"
        echo
        echo "Options:"
        echo "  --performance    Include performance tests"
        echo "  --help, -h       Show this help"
        exit 0
        ;;
esac

main "$@"