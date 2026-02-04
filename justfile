#!/usr/bin/env just --justfile

default:
  just --list

# Test rendering and linting for a specific configuration
test-config +CONFIG:
    @echo "Testing {{CONFIG}} config..."
    docker run --rm -e CONFIG_NAME={{CONFIG}} ghcr.io/cznewt/monitor-tools:latest test-render-lint

# Run container
run-container:
    @echo "Running container..."
    docker run --rm -it ghcr.io/cznewt/monitor-tools:latest
