import os
import subprocess
import grp
from config_linux import BASE_PATH, FOLDER_NAME, PERMISSIONS_MAP

# Function to create a folder at the specified path
# Returns the full folder path if successful, otherwise None
# Prints status messages for folder creation or existence

def create_folder(base_path, folder_name):
    folder_path = os.path.join(base_path, folder_name)
    try:
        if not os.path.exists(folder_path):
            os.makedirs(folder_path, mode=0o755)
            print(f"Folder created: {folder_path}")
        else:
            print(f"Folder already exists: {folder_path}")
        return folder_path
    except Exception as e:
        print(f"Failed to create folder: {e}")
        return None

# Function to check if group exists on the system
def group_exists(groupname):
    try:
        grp.getgrnam(groupname)
        return True
    except KeyError:
        print(f"Group '{groupname}' does not exist on the system")
        return False

# Function to set Linux permissions on a folder for a given group
# permission_type: 'FullControl', 'ReadWrite', or 'ReadOnly'
# Uses chmod and chgrp commands to apply group permissions
# Prints status messages for success or failure

def set_group_permission(folder_path, group_name, permission_type):
    try:
        if not group_exists(group_name):
            return

        # Map permission types for group-based access
        if permission_type == "ReadOnly":
            mode = 0o754  # Owner: rwx, Group: r-x, Others: r--
        elif permission_type == "ReadWrite":
            mode = 0o774  # Owner: rwx, Group: rwx, Others: r--
        elif permission_type == "FullControl":
            mode = 0o775  # Owner: rwx, Group: rwx, Others: r-x
        else:
            print(f"Unsupported permission: {permission_type} for group {group_name}")
            return

        # Change group ownership
        subprocess.run(['chgrp', group_name, folder_path], check=True)
        
        # Set permissions
        os.chmod(folder_path, mode)
        print(f"Group permission '{permission_type}' ({oct(mode)}) applied to group {group_name}")
        
    except subprocess.CalledProcessError as e:
        print(f"Failed to set group permissions for {group_name}: {e}")
    except Exception as e:
        print(f"Error setting group permissions: {e}")

# Main function to create the folder and set permissions for each group
# permissions_map: dict of {group_name: permission_type}

def main(base_path, folder_name, permissions_map):
    folder_path = create_folder(base_path, folder_name)
    if folder_path:
        print(f"\nApplying GROUP-based permissions...")
        for group_name, perm in permissions_map.items():
            set_group_permission(folder_path, group_name, perm)
            print("-" * 50)

# Entry point for script execution
# Defines path, folder name, and group permissions
# Calls main() to perform folder creation and permission assignment

if __name__ == "__main__":
    main(BASE_PATH, FOLDER_NAME, PERMISSIONS_MAP)
