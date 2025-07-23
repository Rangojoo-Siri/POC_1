#!/bin/bash

# Setup script for Linux folder automation
# This script prepares the system for running the automation script

echo "Setting up Linux folder automation..."

# Make scripts executable
chmod +x "$(dirname "$0")/automation.sh"
chmod +x "$(dirname "$0")/config.sh"

echo "Scripts made executable."

# Check for required packages
echo "Checking for required packages..."

# Check if ACL tools are installed
if ! command -v setfacl >/dev/null 2>&1; then
    echo "ACL tools not found. Installing..."
    
    # Detect distribution and install ACL package
    if command -v apt-get >/dev/null 2>&1; then
        # Debian/Ubuntu
        sudo apt-get update && sudo apt-get install -y acl
    elif command -v yum >/dev/null 2>&1; then
        # CentOS/RHEL/Fedora (older)
        sudo yum install -y acl
    elif command -v dnf >/dev/null 2>&1; then
        # Fedora (newer)
        sudo dnf install -y acl
    elif command -v zypper >/dev/null 2>&1; then
        # openSUSE
        sudo zypper install -y acl
    elif command -v pacman >/dev/null 2>&1; then
        # Arch Linux
        sudo pacman -S acl
    else
        echo "Unknown package manager. Please install 'acl' package manually."
        echo "On most distributions: sudo <package-manager> install acl"
    fi
else
    echo "ACL tools are already installed."
fi

# Check if filesystem supports ACLs
echo "Checking filesystem ACL support..."
mount_point="/"
if mount | grep -E "(ext[234]|xfs|btrfs)" | grep -q "acl"; then
    echo "Filesystem ACL support detected."
elif mount | grep -E "(ext[234]|xfs|btrfs)" >/dev/null; then
    echo "Filesystem supports ACLs but may need to be remounted with 'acl' option."
    echo "Consider adding 'acl' to mount options in /etc/fstab"
else
    echo "Warning: Current filesystem may not support ACLs."
fi

echo ""
echo "Setup completed!"
echo ""
echo "Usage:"
echo "  ./automation.sh                 - Run with default config"
echo "  source config.sh && ./automation.sh  - Run with custom config"
echo ""
echo "To customize configuration, edit config.sh file."
