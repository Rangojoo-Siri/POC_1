#!/bin/bash

# Source configuration
source "$(dirname "$0")/config.sh"

# Function to create a folder at the specified path
# Returns 0 if successful, 1 if failed
# Prints status messages for folder creation or existence
create_folder() {
    local base_path="$1"
    local folder_name="$2"
    local folder_path="${base_path}/${folder_name}"
    
    if [ ! -d "$folder_path" ]; then
        if mkdir -p "$folder_path" 2>/dev/null; then
            echo "Folder created: $folder_path"
            return 0
        else
            echo "Failed to create folder: $folder_path" >&2
            return 1
        fi
    else
        echo "Folder already exists: $folder_path"
        return 0
    fi
}

# Function to set Linux permissions and ACLs on a folder for a given group
# permission_type: 'FullControl', 'ReadWrite', or 'ReadOnly'
# Uses standard Linux permissions and ACLs for fine-grained control
# Prints status messages for success or failure
set_permissions() {
    local folder_path="$1"
    local group="$2"
    local permission_type="$3"
    
    # Check if ACL tools are available
    if ! command -v setfacl >/dev/null 2>&1; then
        echo "Warning: setfacl not found. Install acl package for advanced permissions."
        echo "Using basic chmod permissions instead."
        use_basic_permissions=true
    else
        use_basic_permissions=false
    fi
    
    # Check if group exists
    if ! getent group "$group" >/dev/null 2>&1; then
        echo "Warning: Group '$group' does not exist on this system."
        echo "Skipping permission assignment for $group"
        return 1
    fi
    
    case "$permission_type" in
        "FullControl")
            if [ "$use_basic_permissions" = true ]; then
                # Basic permissions: read, write, execute for group
                chmod g+rwx "$folder_path" 2>/dev/null
                chgrp "$group" "$folder_path" 2>/dev/null
            else
                # ACL: full control
                setfacl -m "g:${group}:rwx" "$folder_path" 2>/dev/null
                setfacl -d -m "g:${group}:rwx" "$folder_path" 2>/dev/null  # Default ACL for new files
            fi
            ;;
        "ReadWrite")
            if [ "$use_basic_permissions" = true ]; then
                # Basic permissions: read, write for group
                chmod g+rw "$folder_path" 2>/dev/null
                chgrp "$group" "$folder_path" 2>/dev/null
            else
                # ACL: read and write
                setfacl -m "g:${group}:rw-" "$folder_path" 2>/dev/null
                setfacl -d -m "g:${group}:rw-" "$folder_path" 2>/dev/null
            fi
            ;;
        "ReadOnly")
            if [ "$use_basic_permissions" = true ]; then
                # Basic permissions: read only for group
                chmod g+r "$folder_path" 2>/dev/null
                chgrp "$group" "$folder_path" 2>/dev/null
            else
                # ACL: read only
                setfacl -m "g:${group}:r--" "$folder_path" 2>/dev/null
                setfacl -d -m "g:${group}:r--" "$folder_path" 2>/dev/null
            fi
            ;;
        *)
            echo "Unsupported permission: $permission_type for group $group" >&2
            return 1
            ;;
    esac
    
    if [ $? -eq 0 ]; then
        echo "Permission '$permission_type' applied to group: $group"
        return 0
    else
        echo "Failed to set permissions for $group" >&2
        return 1
    fi
}

# Function to verify permissions are set correctly
verify_permissions() {
    local folder_path="$1"
    
    echo "Current permissions for $folder_path:"
    ls -ld "$folder_path"
    
    if command -v getfacl >/dev/null 2>&1; then
        echo "ACL permissions:"
        getfacl "$folder_path" 2>/dev/null
    fi
}

# Main function to create the folder and set permissions for each group
# Takes base_path, folder_name, and permissions_map as arguments
main() {
    local base_path="$1"
    local folder_name="$2"
    local folder_path="${base_path}/${folder_name}"
    
    # Create the folder
    if create_folder "$base_path" "$folder_name"; then
        echo "Setting permissions for folder: $folder_path"
        
        # Apply permissions for each group
        for group in "${!PERMISSIONS_MAP[@]}"; do
            permission="${PERMISSIONS_MAP[$group]}"
            set_permissions "$folder_path" "$group" "$permission"
        done
        
        echo ""
        verify_permissions "$folder_path"
    else
        echo "Failed to create folder. Exiting." >&2
        exit 1
    fi
}

# Entry point for script execution
# Uses configuration from config.sh
# Calls main() to perform folder creation and permission assignment
if [ "${BASH_SOURCE[0]}" = "${0}" ]; then
    echo "Starting folder automation script..."
    echo "Base path: $BASE_PATH"
    echo "Folder name: $FOLDER_NAME"
    echo ""
    
    main "$BASE_PATH" "$FOLDER_NAME"
    
    echo ""
    echo "Script execution completed."
fi
