#!/bin/bash

# Exit on any error
set -eo pipefail

# Function to display usage
display_help() {
    echo "Usage: $0 [application_directory]"
    echo "This script allows you to update the assignment name in the configuration."
    echo "It can automatically find and use submission_reminder application directories."
    echo ""
    echo "Options:"
    echo "  [application_directory]  Optional path to specific application directory"
    echo "  --help, -h               Show this help message"
    echo ""
    echo "Examples:"
    echo "  $0                                  # Auto-detect application directory"
    echo "  $0 submission_reminder_SanoRodrigue # Use specific directory"
    echo "  $0 /path/to/application             # Use absolute path"
}

# Function to find application directories
find_app_directories() {
    local current_dir="$1"
    local found_dirs=()
    
    # Look for submission_reminder_* patterns in current directory
    for dir in "$current_dir"/submission_reminder_*; do
        if [[ -d "$dir" ]] && [[ -f "$dir/config/config.env" ]] && [[ -f "$dir/app/reminder.sh" ]] && [[ -f "$dir/assets/submissions.txt" ]]; then
            found_dirs+=("$dir")
        fi
    done
    
    # Also check current directory itself
    if [[ -d "config" ]] && [[ -f "config/config.env" ]] && [[ -d "app" ]] && [[ -f "app/reminder.sh" ]] && [[ -d "assets" ]] && [[ -f "assets/submissions.txt" ]]; then
        found_dirs+=("$current_dir")
    fi
    
    printf '%s\n' "${found_dirs[@]}"
}

# Check for help flag
if [[ $# -gt 0 ]]; then
    case "$1" in
        "--help"|"-h")
            display_help
            exit 0
            ;;
    esac
fi

# Determine the application directory
APP_DIR=""
CURRENT_DIR="$(pwd)"

if [[ $# -eq 1 ]] && [[ "$1" != "--help" ]]; then
    # Use provided directory
    if [[ -d "$1" ]]; then
        APP_DIR="$1"
    else
        echo "Error: Directory '$1' not found."
        exit 1
    fi
else
    # Auto-detect: Check if we're already in an app directory
    if [[ -d "config" ]] && [[ -f "config/config.env" ]] && [[ -d "app" ]] && [[ -f "app/reminder.sh" ]] && [[ -d "assets" ]] && [[ -f "assets/submissions.txt" ]]; then
        APP_DIR="."
        echo "✓ Found application in current directory"
    else
        # Look for application directories
        echo "Searching for submission reminder applications..."
        mapfile -t APP_DIRS < <(find_app_directories "$CURRENT_DIR")
        
        if [[ ${#APP_DIRS[@]} -eq 0 ]]; then
            echo "Error: No submission reminder application found."
            echo ""
            echo "Please either:"
            echo "1. Run this script from inside an application directory"
            echo "2. Specify the application directory as an argument:"
            echo "   $0 /path/to/submission_reminder_directory"
            echo "3. First create an environment using: ./create_environment.sh"
            exit 1
        elif [[ ${#APP_DIRS[@]} -eq 1 ]]; then
            APP_DIR="${APP_DIRS[0]}"
            echo "✓ Found application: $APP_DIR"
        else
            echo "Multiple applications found. Please choose one:"
            echo ""
            for i in "${!APP_DIRS[@]}"; do
                echo "  $((i+1))) ${APP_DIRS[$i]}"
            done
            echo ""
            read -p "Enter your choice (1-${#APP_DIRS[@]}): " choice
            
            if [[ "$choice" =~ ^[0-9]+$ ]] && [[ "$choice" -ge 1 ]] && [[ "$choice" -le ${#APP_DIRS[@]} ]]; then
                APP_DIR="${APP_DIRS[$((choice-1))]}"
            else
                echo "Invalid choice. Exiting."
                exit 1
            fi
        fi
    fi
fi

# Validate application directory structure
if [[ ! -f "$APP_DIR/config/config.env" ]]; then
    echo "Error: Config file not found at $APP_DIR/config/config.env"
    exit 1
fi

if [[ ! -f "$APP_DIR/app/reminder.sh" ]]; then
    echo "Error: Main application script not found at $APP_DIR/app/reminder.sh"
    exit 1
fi

if [[ ! -f "$APP_DIR/assets/submissions.txt" ]]; then
    echo "Error: Submissions file not found at $APP_DIR/assets/submissions.txt"
    exit 1
fi

echo "Using application: $(cd "$APP_DIR" && pwd)"
echo ""

# Store original directory to return later
ORIGINAL_DIR="$(pwd)"

# Change to application directory
cd "$APP_DIR"

CONFIG_FILE="config/config.env"

# Display current assignment
echo "Current configuration:"
echo "----------------------"
grep -E "^(ASSIGNMENT|DAYS_REMAINING)" "$CONFIG_FILE"
echo

# Get new assignment name
read -p "Enter the new assignment name: " NEW_ASSIGN

# Validate input
if [[ -z "$NEW_ASSIGN" ]]; then
    echo "Error: Assignment name cannot be empty. Exiting."
    cd "$ORIGINAL_DIR"
    exit 1
fi

# Create backup of config file
BACKUP_FILE="${CONFIG_FILE}.backup.$(date +%Y%m%d_%H%M%S)"
cp "$CONFIG_FILE" "$BACKUP_FILE"
echo "✓ Backup created: $BACKUP_FILE"

# Update the assignment in config file
if sed -i "s/^ASSIGNMENT=.*/ASSIGNMENT=\"$NEW_ASSIGN\"/" "$CONFIG_FILE"; then
    echo "✓ Assignment updated to: $NEW_ASSIGN"
else
    echo "Error: Failed to update assignment in config file."
    echo "Restoring from backup..."
    cp "$BACKUP_FILE" "$CONFIG_FILE"
    cd "$ORIGINAL_DIR"
    exit 1
fi

# Verify the change was made
echo
echo "Updated configuration:"
echo "----------------------"
grep -E "^(ASSIGNMENT|DAYS_REMAINING)" "$CONFIG_FILE"

# Run the application
echo
echo "Running submission check for the new assignment..."
echo "=================================================="

if [[ -f "startup.sh" ]] && [[ -x "startup.sh" ]]; then
    ./startup.sh
elif [[ -f "startup.sh" ]]; then
    chmod +x startup.sh
    ./startup.sh
else
    echo "Warning: startup.sh not found."
    echo "Attempting to run app/reminder.sh directly..."
    if [[ -f "app/reminder.sh" ]] && [[ -x "app/reminder.sh" ]]; then
        ./app/reminder.sh
    elif [[ -f "app/reminder.sh" ]]; then
        chmod +x app/reminder.sh
        ./app/reminder.sh
    else
        echo "Error: Could not find an executable application script."
        cd "$ORIGINAL_DIR"
        exit 1
    fi
fi

# Return to original directory
cd "$ORIGINAL_DIR"
