#!/bin/bash

# Exit on any error
set -eo pipefail

# Function to display usage
display_help() {
    echo "Usage: $0"
    echo "This script allows you to update the assignment name in the configuration."
    echo "It will prompt for a new assignment name and update config/config.env"
    echo "Then it will run the application to check submissions for the new assignment."
}

# Check for help flag only if arguments are provided
if [[ $# -gt 0 ]]; then
    if [[ "$1" == "--help" ]] || [[ "$1" == "-h" ]]; then
        display_help
        exit 0
    fi
fi

# Check if we're in the correct directory structure
if [[ ! -d "config" ]] || [[ ! -d "app" ]] || [[ ! -d "assets" ]]; then
    echo "Error: This script must be run from the root of the submission_reminder application directory."
    echo "Current directory: $(pwd)"
    echo "Required structure: ./config/config.env, ./app/reminder.sh, ./assets/submissions.txt"
    exit 1
fi

CONFIG_FILE="config/config.env"

# Check if config file exists
if [[ ! -f "$CONFIG_FILE" ]]; then
    echo "Error: Config file not found at $CONFIG_FILE"
    echo "Please make sure you're in the correct directory and the environment is properly set up."
    exit 1
fi

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
else
    echo "Warning: startup.sh not found or not executable."
    echo "Attempting to run app/reminder.sh directly..."
    if [[ -f "app/reminder.sh" ]] && [[ -x "app/reminder.sh" ]]; then
        ./app/reminder.sh
    else
        echo "Error: Could not find an executable application script."
        exit 1
    fi
fi
