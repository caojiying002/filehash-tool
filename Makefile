# Makefile for filehash tool

# Compiler and flags
CC = gcc
CFLAGS = -Wall -Wextra -O2 -std=c99
LDFLAGS = -lssl -lcrypto

# Directories
SRCDIR = src
BUILDDIR = build
BINDIR = $(BUILDDIR)/bin
OBJDIR = $(BUILDDIR)/obj

# Target binary
TARGET = filehash
BINARY = $(BINDIR)/$(TARGET)

# Source files
SOURCES = $(wildcard $(SRCDIR)/*.c)
OBJECTS = $(SOURCES:$(SRCDIR)/%.c=$(OBJDIR)/%.o)

# Installation directories
PREFIX = /usr/local
BININSTALL = $(PREFIX)/bin
MANINSTALL = $(PREFIX)/share/man/man1

# Default target
all: $(BINARY)

# Create directories
$(OBJDIR):
	mkdir -p $(OBJDIR)

$(BINDIR):
	mkdir -p $(BINDIR)

# Compile object files
$(OBJDIR)/%.o: $(SRCDIR)/%.c | $(OBJDIR)
	$(CC) $(CFLAGS) -c $< -o $@

# Link binary
$(BINARY): $(OBJECTS) | $(BINDIR)
	$(CC) $(OBJECTS) -o $@ $(LDFLAGS)

# Install target
install: $(BINARY)
	install -d $(BININSTALL)
	install -m 755 $(BINARY) $(BININSTALL)/$(TARGET)
	@if [ -f docs/$(TARGET).1 ]; then \
		install -d $(MANINSTALL); \
		install -m 644 docs/$(TARGET).1 $(MANINSTALL)/$(TARGET).1; \
		echo "Manual page installed to $(MANINSTALL)/$(TARGET).1"; \
	fi
	@echo "$(TARGET) installed to $(BININSTALL)/$(TARGET)"

# Uninstall target
uninstall:
	rm -f $(BININSTALL)/$(TARGET)
	rm -f $(MANINSTALL)/$(TARGET).1
	@echo "$(TARGET) uninstalled"

# Clean build files
clean:
	rm -rf $(BUILDDIR)
	@echo "Build directory cleaned"

# Test target
test: $(BINARY)
	@echo "Running basic tests..."
	@if [ -f tests/run-tests.sh ]; then \
		cd tests && ./run-tests.sh; \
	else \
		echo "Creating test file..."; \
		echo "Hello, World!" > /tmp/test-filehash.txt; \
		echo "Testing MD5:"; \
		$(BINARY) -m /tmp/test-filehash.txt; \
		echo "Testing SHA1:"; \
		$(BINARY) -s /tmp/test-filehash.txt; \
		echo "Testing SHA256:"; \
		$(BINARY) -S /tmp/test-filehash.txt; \
		echo "Testing all hashes:"; \
		$(BINARY) -a /tmp/test-filehash.txt; \
		rm -f /tmp/test-filehash.txt; \
	fi

# Debug build
debug: CFLAGS += -g -DDEBUG
debug: $(BINARY)

# Check dependencies
check-deps:
	@echo "Checking dependencies..."
	@pkg-config --exists openssl || (echo "Error: OpenSSL development libraries not found. Install with: sudo apt-get install libssl-dev" && exit 1)
	@echo "Dependencies OK"

# Show help
help:
	@echo "Available targets:"
	@echo "  all        - Build the filehash binary (default)"
	@echo "  install    - Install filehash to $(PREFIX)"
	@echo "  uninstall  - Remove filehash from system"
	@echo "  clean      - Remove build files"
	@echo "  test       - Run basic tests"
	@echo "  debug      - Build with debug symbols"
	@echo "  check-deps - Check if dependencies are installed"
	@echo "  help       - Show this help message"

# Declare phony targets
.PHONY: all install uninstall clean test debug check-deps help