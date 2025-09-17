#!/bin/bash

# Define the YAML files to be used
PERSISTENT_YAML="ollama-persistent.yaml"
NON_PERSISTENT_YAML="ollama-non-persistent.yaml"

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

# Define functions for each command
deploy() {
    echo "▶️ Deploying Ollama persistent resources from $PERSISTENT_YAML..."
    kubectl apply -f "$SCRIPT_DIR/$PERSISTENT_YAML"
    echo "✅ Persistent resources deployed."

    echo "▶️ Deploying Ollama non-persistent resources from $NON_PERSISTENT_YAML..."
    kubectl apply -f "$SCRIPT_DIR/$NON_PERSISTENT_YAML"
    echo "✅ Non-persistent resources deployed."
    echo "✅ Full deployment complete."
}

start() {
    echo "▶️ Deploying Ollama non-persistent resources from $NON_PERSISTENT_YAML..."
    kubectl apply -f "$SCRIPT_DIR/$NON_PERSISTENT_YAML"
    echo "✅ Non-persistent resources deployed."
}

stop() {
    echo "▶️ Deleting Ollama non-persistent resources from $NON_PERSISTENT_YAML..."
    kubectl delete -f "$SCRIPT_DIR/$NON_PERSISTENT_YAML"
    echo "✅ Non-persistent resources deleted."
}

delete() {
    echo "▶️ Deleting all Ollama resources..."
    # It's best to delete the dependent (non-persistent) resources first
    echo "▶️ Deleting non-persistent resources from $NON_PERSISTENT_YAML..."
    kubectl delete -f "$SCRIPT_DIR/$NON_PERSISTENT_YAML"
    echo "✅ Non-persistent resources deleted."

    # Then delete the persistent resources
    echo "▶️ Deleting persistent resources from $PERSISTENT_YAML..."
    kubectl delete -f "$SCRIPT_DIR/$PERSISTENT_YAML"
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