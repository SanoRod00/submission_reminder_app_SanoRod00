#!/bin/bash

# Load environment variables
source "$(dirname "$0")/../config/config.env"

# Run the reminder script
bash "$(dirname "$0")/reminder.sh"
