#!/bin/bash

# Function to read submissions file and output students who have not submitted
function check_submissions {
    local submissions_file=$1
    # Read the current assignment from environment
    local current_assignment=$(grep "^ASSIGNMENT=" ../config/config.env | cut -d'=' -f2 | tr -d '"')
    echo "Checking submissions for assignment: $current_assignment"

    # Skip header and process each line
    tail -n +2 "$submissions_file" | while IFS=, read -r student assignment status; do
        student=$(echo "$student" | xargs)
        assignment=$(echo "$assignment" | xargs)
        status=$(echo "$status" | xargs)

        if [[ "$assignment" == "$current_assignment" && "$status" == "not submitted" ]]; then
            echo "Reminder: $student has not submitted the $current_assignment assignment!"
        fi
    done
}
