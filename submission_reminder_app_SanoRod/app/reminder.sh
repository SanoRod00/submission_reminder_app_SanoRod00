#!/bin/bash
# Loads config and runs reminder logic
source ../config/config.env
source ../modules/functions.sh
submissions_file="../assets/submissions.txt"

echo "Running reminder for assignment: $ASSIGNMENT"
check_submissions "$submissions_file"
