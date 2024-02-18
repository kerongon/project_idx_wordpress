#!/usr/bin/env bash

# Exit script on first error
set -e

# Function to check dependencies
check_dependencies() {
    command -v php >/dev/null 2>&1 || { echo >&2 "I require php but it's not installed.  Aborting."; exit 1; }
    command -v git >/dev/null 2>&1 || { echo >&2 "I require git but it's not installed.  Aborting."; exit 1; }
    command -v wget >/dev/null 2>&1 || { echo >&2 "I require wget but it's not installed.  Aborting."; exit 1; }
    command -v unzip >/dev/null 2>&1 || { echo >&2 "I require unzip but it's not installed.  Aborting."; exit 1; }
}

# Function to check if directory exists
check_directory() {
    if [ ! -d "$1" ]; then
        echo "Directory $1 does not exist. Creating now..."
        mkdir -p "$1"
    fi
}

# Main script function
main() {
    # Get start time
    local start_time=$(date +%s)

    # Check if directory exists
    check_directory "$HOME/project_idx_wordpress/www"

    # Change to project directory
    echo "Changing to project directory..."
    cd "$HOME/project_idx_wordpress/www"

    # Download WordPress
    echo "Downloading WordPress..."
    wget -q https://wordpress.org/latest.zip

    # Unzip WordPress
    echo "Unzipping WordPress..."
    unzip -q latest.zip
    mv wordpress/* .
    rm -r wordpress latest.zip

    # Initialize a new Git repository
    echo "Initializing a new Git repository..."
    git init --initial-branch=main > /dev/null

    # Add all files to Git and commit
    echo "Adding all files to Git and committing..."
    git add . > /dev/null
    git commit -m "Initial Commit" > /dev/null

    # Get end time and calculate duration
    local end_time=$(date +%s)
    local duration=$((end_time - start_time))

    echo "Script completed in $duration seconds."

    # Remove this script
    # echo "Removing this script..."
    # rm -- "$0"
}

# Check dependencies before running script
check_dependencies

# Run main script function
main