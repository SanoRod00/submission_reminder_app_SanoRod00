#!/bin/bash
# Script: copilot_shell_script.sh
# Purpose: Update assignment name in config file and rerun the app

read -p "Enter your name (to locate your app folder): " username
app_dir="submission_reminder_app_${SanoRod00}"

# Check if directory exists
if [ ! -d "$app_dir" ]; then
    echo "Error: $app_dir not found!"
    exit 1
fi

# Prompt for new assignment name
read -p "Enter new assignment name: " new_assignment

config_file="$app_dir/config/config.env"

# Replace ASSIGNMENT value
sed -i "s/^ASSIGNMENT=.*/ASSIGNMENT=\"${new_assignment}\"/" "$config_file"

echo "Assignment updated to '$new_assignment' in config.env"

# Restart the app
echo "Restarting the reminder app..."
bash "$app_dir/startup.sh"
