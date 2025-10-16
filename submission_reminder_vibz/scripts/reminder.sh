#!/bin/bash
# Reminder script to notify students who haven't submitted the assignment

source ../functions.sh

# Call the function to check submissions
check_submissions "../submissions.txt"
