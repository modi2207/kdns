# Define variables
CC = gcc
CFLAGS = -Wall -Werror
BUILD_DIR = build
LIB_NAME = libkdns.a

SRCDIR=/app/kdns/core

DEPDIR = $(SRCDIR)/../deps

INCLUDE += -I$(DEPDIR)/libjansson/src

# Source files
SRCS = dns.c domain_store.c packet.c query.c radtree.c util.c view.c zone.c

# Object files
OBJS = $(patsubst %.c, $(BUILD_DIR)/%.o, $(SRCS))

# Target: library and build directory
all: $(BUILD_DIR) $(BUILD_DIR)/$(LIB_NAME)

# Create the build directory
$(BUILD_DIR):
	mkdir -p $(BUILD_DIR)

CFLAGS += $(INCLUDE)

# Compile each .c file to an object file in the build directory
$(BUILD_DIR)/%.o: %.c
	$(CC) $(CFLAGS) -c $< -o $@

# Create the static library from object files
$(BUILD_DIR)/$(LIB_NAME): $(OBJS)
	ar rcs $@ $(OBJS)

# Clean up build artifacts
clean:
	rm -rf $(BUILD_DIR)

# Phony targets
.PHONY: all clean
