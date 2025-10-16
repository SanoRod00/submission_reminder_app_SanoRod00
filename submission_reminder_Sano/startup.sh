#!/bin/bash

# Get the root directory of the application
APP_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "==========================================="
echo "  Submission Reminder Application"
echo "==========================================="
echo "Starting application from: $APP_ROOT"
echo

# Change to application root directory
cd "$APP_ROOT"

# Run the main reminder script
if [[ -f "./app/reminder.sh" ]]; then
    ./app/reminder.sh
else
    echo "Error: Main application script not found!"
    exit 1
fi

echo
echo "==========================================="
echo "  Application completed successfully"
echo "==========================================="
