#!/bin/bash

# CS Plugins Installer for Claude Code
# Automatically installs to ~/.claude/plugins/marketplaces/

set -e

PLUGIN_NAME="cs_plugins"
REPO_URL="https://github.com/intenet1001-commits/cs_plugins"
INSTALL_DIR="$HOME/.claude/plugins/marketplaces/$PLUGIN_NAME"

echo "Installing CS Plugins for Claude Code..."

# Create marketplaces directory if it doesn't exist
mkdir -p "$HOME/.claude/plugins/marketplaces"

# Check if already installed
if [ -d "$INSTALL_DIR" ]; then
    echo "CS Plugins already installed. Updating..."
    cd "$INSTALL_DIR"
    git pull origin main
    echo "Updated successfully!"
else
    echo "Cloning repository..."
    git clone "$REPO_URL" "$INSTALL_DIR"
    echo "Installed successfully!"
fi

echo ""
echo "Installation complete!"
echo "Location: $INSTALL_DIR"
echo ""
echo "Please restart Claude Code to load the new plugins."
echo ""
echo "Available skills:"
echo "  - playwright-test: Multi-agent web testing"
echo "  - report-writer: Korean business report generation"
