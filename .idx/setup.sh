#!/usr/bin/env bash

# Exit script on first error
set -e

# Function to check dependencies
check_dependencies() {
    command -v php >/dev/null 2>&1 || { echo >&2 "I require php but it's not installed.  Aborting."; exit 1; }
    command -v git >/dev/null 2>&1 || { echo >&2 "I require git but it's not installed.  Aborting."; exit 1; }
    command -v wget >/dev/null 2>&1 || { echo >&2 "I require wget but it's not installed.  Aborting."; exit 1; }
    command -v unzip >/dev/null 2>&1 || { echo >&2 "I require unzip but it's not installed.  Aborting."; exit 1; }
    command -v docker >/dev/null 2>&1 || { echo >&2 "I require docker but it's not installed.  Aborting."; exit 1; }
    command -v docker-compose >/dev/null 2>&1 || { echo >&2 "I require docker-compose but it's not installed.  Aborting."; exit 1; }
}

# Variables
PROJECT_TYPE="wordpress"
MAIN_FOLDER="project_idx_wordpress"

# Function to check if directory exists
check_directory() {
    if [ ! -d "$1" ]; then
        echo "Directory $1 does not exist. Creating now..."
        mkdir -p "$1"
    fi
}

# Function to cleanup on error
cleanup() {
    echo "An error occurred. Cleaning up and removing www..."
    rm -rf "$HOME/project_idx_wordpress/www"
    echo "Stopping and removing Docker containers, networks, images, and volumes..."
    cd "$HOME/project_idx_wordpress/.idx" && docker-compose down --rmi all --volumes
}


# Main script function
main() {
     # Set a trap to cleanup on error
    trap cleanup ERR
    # Get start time
    local start_time=$(date +%s)

    # Check if directory exists
    check_directory "$HOME/$MAIN_FOLDER/www"

    # Change to project directory
    echo "Changing to project directory..."
    cd "$HOME/$MAIN_FOLDER/www"

    # Download WordPress
    echo "Downloading WordPress..."
    wget -q https://wordpress.org/latest.zip

    # Unzip WordPress
    echo "Unzipping WordPress..."
    unzip -q latest.zip
    mv wordpress/* .
    rm -r wordpress latest.zip

    # Copy wp-config-sample.php to wp-config.php
    echo "Copying wp-config.php..."
    cp wp-config-sample.php wp-config.php

    # Update database settings
    echo "Updating database settings..."
    sed -i "s/'DB_NAME', 'database_name_here'/'DB_NAME', '$PROJECT_TYPE'/g" wp-config.php
    sed -i "s/'DB_USER', 'username_here'/'DB_USER', 'root'/g" wp-config.php
    sed -i "s/'DB_PASSWORD', 'password_here'/'DB_PASSWORD', 'root'/g" wp-config.php
    sed -i "s/'DB_HOST', 'localhost'/'DB_HOST', '127.0.0.1'/g" wp-config.php

    # Initialize a new Git repository
    echo "Initializing a new Git repository..."
    git init --initial-branch=main > /dev/null

    # Add all files to Git and commit
    echo "Adding all files to Git and committing..."
    git add . > /dev/null
    git commit -m "Initial Commit" > /dev/null

    # Change to Docker Compose directory
    echo "Changing to Docker Compose directory..."
    cd "$HOME/$MAIN_FOLDER/.idx"

    # Start Docker Compose
    echo "Starting Docker Compose..."
    docker-compose up -d

    # Start Docker container
    echo "Starting Docker container..."
    docker start idx-db-1

    # Wait for MariaDB to be ready (Takes about 10 seconds)
    until docker exec idx-db-1 mariadb -u root -proot -e "SELECT 1" >/dev/null 2>&1; do
        echo "Waiting for MariaDB server to accept connections..."
        sleep 5
    done


    # Create database in Docker container
    echo "Creating database in Docker container..."
    docker exec -it idx-db-1 mariadb -u root -proot -e "CREATE DATABASE wordpress;"

    #Display DB information
    echo "Database Information:"
    echo "DB_USER: root"
    echo "DB_PASSWORD: root"
    echo "DB_HOST: 127.0.0.1"
    echo "DB_NAME: $PROJECT_TYPE"

    # Get end time and calculate duration
    local end_time=$(date +%s)
    local duration=$((end_time - start_time))

    echo "Script completed in $duration seconds."
}

# Check dependencies before running script
check_dependencies

# Run main script function
main