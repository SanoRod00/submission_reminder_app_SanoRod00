#!/bin/bash
# Script: create_environment.sh
# Purpose: Set up the submission reminder app environment

# Prompt for user name
read -p "Enter your name: " username

# Define main directory
main_dir="submission_reminder_app_${username}"

# Create directory structure
mkdir -p ${main_dir}/{app,modules,assets,config}

# Create and populate reminder.sh
cat << 'EOF' > ${main_dir}/app/reminder.sh
#!/bin/bash
# Loads config and runs reminder logic
source ../config/config.env
source ../modules/functions.sh
submissions_file="../assets/submissions.txt"

echo "Running reminder for assignment: $ASSIGNMENT"
check_submissions "$submissions_file"
EOF

# Create and populate functions.sh
cat << 'EOF' > ${main_dir}/modules/functions.sh
#!/bin/bash
# Reads submissions and alerts students who haven't submitted
function check_submissions {
    local submissions_file=$1
    echo "Checking submissions in $submissions_file"

    while IFS=, read -r student assignment status; do
        student=$(echo "$student" | xargs)
        assignment=$(echo "$assignment" | xargs)
        status=$(echo "$status" | xargs)

        if [[ "$assignment" == "$ASSIGNMENT" && "$status" == "not submitted" ]]; then
            echo "Reminder: $student has not submitted the $ASSIGNMENT assignment!"
        fi
    done < <(tail -n +2 "$submissions_file")
}
EOF

# Create and populate config.env
cat << 'EOF' > ${main_dir}/config/config.env
# This is the config file
ASSIGNMENT="Shell Navigation"
DAYS_REMAINING=2
EOF

# Create and populate submissions.txt with extra students
cat << 'EOF' > ${main_dir}/assets/submissions.txt
student, assignment, submission status
Chinemerem, Shell Navigation, not submitted
Chiagoziem, Git, submitted
Divine, Shell Navigation, not submitted
Anissa, Shell Basics, submitted
Mutemura, Shell Navigation, submitted
Macaire, Shell Navigation, not submitted
Swish, Git, not submitted
Kabayiza, Shell Navigation, not submitted
Billy, Shell Basics, submitted
Mic, Shell Navigation, not submitted
EOF

# Create startup.sh
cat << 'EOF' > ${main_dir}/startup.sh
#!/bin/bash
# Starts the reminder app
cd app || exit
echo "Starting Submission Reminder App..."
./reminder.sh
EOF

# Make all shell scripts executable
find ${main_dir} -type f -name "*.sh" -exec chmod +x {} \;

echo "Environment setup complete!"
echo "Navigate into $main_dir and run ./startup.sh to start the app."
