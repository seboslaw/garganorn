#!/bin/bash

set -e  # Exit on any error

# Check if database exists
if [ ! -f "db/fsq-osp.duckdb" ]; then
    echo "Database not found. Initializing database..."
    
    # Create database directory if it doesn't exist
    mkdir -p db
    
    # Create the places table
    echo "Running import-fsq-osp.sql..."
    duckdb db/fsq-osp.duckdb < scripts/import-fsq-osp.sql
    
    # Verify Foursquare data
    echo "Verifying Foursquare data..."
    COUNT=$(duckdb db/fsq-osp.duckdb "SELECT COUNT(*) FROM places;")
    echo "Found $COUNT places in Foursquare database"
    
    if [ "$COUNT" -eq 0 ]; then
        echo "Error: Foursquare places table is empty"
        exit 1
    fi
    
    echo "Database initialization complete."
else
    echo "Database already exists, skipping initialization."
fi

# Start the server
echo "Starting server on port 5001..."
FLASK_RUN_PORT=5001 python -m garganorn.server 