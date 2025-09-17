#!/bin/bash

# Define the YAML files to be used
PERSISTENT_YAML="postgres-persistent.yaml"
NON_PERSISTENT_YAML="postgres-non-persistent.yaml"

# Get the current directory of the script
SCRIPT_DIR=$(dirname "$(readlink -f "$0")")

# Check if the YAML template files exist
if [ ! -f "$SCRIPT_DIR/$PERSISTENT_YAML" ]; then
    echo "Error: The file '$PERSISTENT_YAML' was not found in the script's directory."
    exit 1
fi
if [ ! -f "$SCRIPT_DIR/$NON_PERSISTENT_YAML" ]; then
    echo "Error: The file '$NON_PERSISTENT_YAML' was not found in the script's directory."
    exit 1
fi

# Function to load environment variables from the .env file
load_env_vars() {
    echo "Loading environment variables from .env file..."
    ENV_FILE="$SCRIPT_DIR/../../.env"
    if [ -f "$ENV_FILE" ]; then
        export $(cat "$ENV_FILE" | xargs)
        # Check if variables are set
        if [ -z "$POSTGRES_DB" ] || [ -z "$POSTGRES_USER" ] || [ -z "$POSTGRES_PASSWORD" ]; then
            echo "Error: One or more required variables (POSTGRES_DB, POSTGRES_USER, POSTGRES_PASSWORD) are not set in the .env file."
            exit 1
        fi
    else
        echo "Error: .env file not found at $ENV_FILE."
        exit 1
    fi
}

# Define functions for each command
deploy() {
    load_env_vars
    echo "▶️ Processing YAML and deploying persistent resources..."
    # Process and apply the persistent YAML file
    envsubst < "$SCRIPT_DIR/$PERSISTENT_YAML" | kubectl apply -f -
    echo "✅ Persistent resources deployed."

    echo "▶️ Processing YAML and deploying non-persistent resources..."
    # Process and apply the non-persistent YAML file
    envsubst < "$SCRIPT_DIR/$NON_PERSISTENT_YAML" | kubectl apply -f -
    echo "✅ Non-persistent resources deployed."
    echo "✅ Full deployment complete."
}

start() {
    load_env_vars
    echo "▶️ Deploying non-persistent resources..."
    # Apply the non-persistent YAML file
    envsubst < "$SCRIPT_DIR/$NON_PERSISTENT_YAML" | kubectl apply -f -
    echo "✅ Non-persistent resources deployed."
}

stop() {
    load_env_vars
    echo "▶️ Deleting non-persistent resources..."
    # Delete the non-persistent YAML file
    envsubst < "$SCRIPT_DIR/$NON_PERSISTENT_YAML" | kubectl delete -f -
    echo "✅ Non-persistent resources deleted."
}

delete() {
    load_env_vars
    echo "▶️ Deleting all resources..."
    # It's best to delete the dependent (non-persistent) resources first
    echo "▶️ Deleting non-persistent resources..."
    envsubst < "$SCRIPT_DIR/$NON_PERSISTENT_YAML" | kubectl delete -f -
    echo "✅ Non-persistent resources deleted."

    # Then delete the persistent resources
    echo "▶️ Deleting persistent resources..."
    envsubst < "$SCRIPT_DIR/$PERSISTENT_YAML" | kubectl delete -f -
    echo "✅ Persistent resources deleted."
    echo "✅ Full deletion complete."
}

# Main script logic to handle arguments
case "$1" in
    deploy)
        deploy
        ;;
    start)
        start
        ;;
    stop)
        stop
        ;;
    delete)
        delete
        ;;
    *)
        echo "Usage: $0 {deploy|start|stop|delete}"
        echo "  deploy: Creates or updates all resources."
        echo "  start:  Deploys the non-persistent components (Deployment and Service)."
        echo "  stop:   Deletes the non-persistent components (Deployment and Service)."
        echo "  delete: Deletes all resources, both persistent and non-persistent."
        exit 1
        ;;
esac