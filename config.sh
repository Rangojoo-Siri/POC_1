#!/bin/bash

# Configuration for folder creation and permissions
BASE_PATH="/home/shared"
FOLDER_NAME="TowerFolder"

# Permissions mapping - associative array
# Format: "group:permission_type"
declare -A PERMISSIONS_MAP=(
    ["users"]="ReadOnly"
    ["administrators"]="FullControl"
    ["sksre"]="ReadWrite"
)

# Export variables for use in other scripts
export BASE_PATH
export FOLDER_NAME
