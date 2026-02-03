#!/usr/bin/env just --justfile

default:
  just --list

# Render resources for a specific configuration
test-config +CONFIG:
    @echo "Testing {{CONFIG}} config..."
    docker run --rm -e CONFIG_NAME={{CONFIG}} ghcr.io/cznewt/monitor-tools:latest test-render-lint
