#!/bin/bash

# Exit on any error
set -euo pipefail

# Function to display usage
display_help() {
    echo "Usage: $0"
    echo "This script sets up the submission reminder application environment."
    echo "It will prompt for your name and create the directory structure with all necessary files."
}

# Check for help flag
if [[ $# -gt 0 ]]; then
if [[ "$1" == "--help" ]] || [[ "$1" == "-h" ]]; then
    display_help
    exit 0
fi
fi
# Get user's name
read -p "Enter your name (used for environment folder): " CREATOR_NAME

# Validate input
if [[ -z "$CREATOR_NAME" ]]; then
    echo "Error: Name cannot be empty. Exiting."
    exit 1
fi

# Clean the name (remove special characters, replace spaces with underscores)
CLEAN_NAME=$(echo "$CREATOR_NAME" | sed 's/[^a-zA-Z0-9 ]//g' | tr ' ' '_')
ENV_DIR="submission_reminder_${CLEAN_NAME}"

# Check if directory already exists
if [[ -d "$ENV_DIR" ]]; then
    echo "Error: Directory '$ENV_DIR' already exists. Please choose a different name or remove the existing directory."
    exit 1
fi

echo "Creating application structure in '$ENV_DIR'..."

# Create main directory and subdirectories
mkdir -p "$ENV_DIR"/{app,modules,assets,config}

echo "✓ Directory structure created"

# Create config.env file
cat > "$ENV_DIR/config/config.env" << 'EOF'
# This is the config file
ASSIGNMENT="Shell Navigation"
DAYS_REMAINING=2
EOF
echo "✓ Config file created"

# Create functions.sh file
cat > "$ENV_DIR/modules/functions.sh" << 'EOF'
#!/bin/bash

# Function to read submissions file and output students who have not submitted
function check_submissions {
    local submissions_file=$1
    echo "Checking submissions in $submissions_file"

    # Skip the header and iterate through the lines
    while IFS=, read -r student assignment status; do
        # Remove leading and trailing whitespace
        student=$(echo "$student" | xargs)
        assignment=$(echo "$assignment" | xargs)
        status=$(echo "$status" | xargs)

        # Check if assignment matches and status is 'not submitted'
        if [[ "$assignment" == "$ASSIGNMENT" && "$status" == "not submitted" ]]; then
            echo "Reminder: $student has not submitted the $ASSIGNMENT assignment!"
        fi
    done < <(tail -n +2 "$submissions_file") # Skip the header
}
EOF
echo "✓ Functions file created"

# Create reminder.sh file
cat > "$ENV_DIR/app/reminder.sh" << 'EOF'
#!/bin/bash

# Source environment variables and helper functions
source ./config/config.env
source ./modules/functions.sh

# Path to the submissions file
submissions_file="./assets/submissions.txt"

# Print remaining time and run the reminder function
echo "Assignment: $ASSIGNMENT"
echo "Days remaining to submit: $DAYS_REMAINING days"
echo "--------------------------------------------"

check_submissions $submissions_file
EOF
echo "✓ Main application file created"

# Create submissions.txt with additional students
cat > "$ENV_DIR/assets/submissions.txt" << 'EOF'
student, assignment, submission status
Chinemerem, Shell Navigation, not submitted
Chiagoziem, Git, submitted
Divine, Shell Navigation, not submitted
Anissa, Shell Basics, submitted
Mutemura, Shell Navigation, not submitted
Macaire, Git, not submitted
Swish, Shell Navigation, submitted
Kabayiza, Shell Basics, not submitted
Billy, Shell Navigation, not submitted
Mic, Git, submitted
EOF
echo "✓ Submissions file created with 10 student records"

# Create startup.sh file
cat > "$ENV_DIR/startup.sh" << 'EOF'
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
EOF
echo "✓ Startup script created"

# Make all .sh files executable
echo "Setting executable permissions..."
find "$ENV_DIR" -type f -name "*.sh" -exec chmod +x {} \;
echo "✓ All shell scripts made executable"

# Display success message
echo
echo "✅ Environment created successfully in: $ENV_DIR"
echo
echo "Application structure:"
tree "$ENV_DIR"
echo
echo "To test the application, run:"
echo "  cd $ENV_DIR && ./startup.sh"
echo
echo "Files created:"
echo "  - config/config.env    : Configuration file"
echo "  - modules/functions.sh : Helper functions"
echo "  - app/reminder.sh      : Main application logic"
echo "  - assets/submissions.txt: Student submission records (10 entries)"
echo "  - startup.sh           : Application launcher"
