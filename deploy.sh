#!/bin/bash

# Define the directory where your manifests are located
MANIFESTS_DIR="./Scripts"
# Define components and their corresponding manifest files
declare -A components=(
  [postgres]="postgres-deployment.yaml"
  [qdrant]="qdrant-deployment.yaml"
  [ollama]="ollama-deployment.yaml"
  [langflow]="langflow-deployment.yaml"
)

# Function to check for required files and .env
check_files() {
  if [ ! -d "$MANIFESTS_DIR" ]; then
    echo "Error: The '$MANIFESTS_DIR' directory does not exist."
    exit 1
  fi
  if [ ! -f ./.env ]; then
    echo "Error: The ./.env file does not exist."
    exit 1
  fi
}

# Function to create Kubernetes secrets for Postgres from .env file
create_postgres_secret() {
  echo "🔑 Creating Kubernetes secrets for Postgres from ./.env file..."
  
  # Check if .env file exists and source it
  if [ -f ./.env ]; then
    set -a
    source ./.env
    set +a
  else
    echo "Error: ./.env file not found."
    exit 1
  fi
  
  # Create the postgres-secrets
  echo "  Creating postgres-secrets..."
  kubectl create secret generic postgres-secrets \
    --from-literal=POSTGRES_DB="$POSTGRES_DB" \
    --from-literal=POSTGRES_USER="$POSTGRES_USER" \
    --from-literal=POSTGRES_PASSWORD="$POSTGRES_PASSWORD" \
    --dry-run=client -o yaml | kubectl apply -f -

  echo "✅ Postgres secret created."
}

# Function to create Kubernetes secrets for Langflow from .env file
create_langflow_secret() {
  echo "🔑 Creating Kubernetes secrets for Langflow from ./.env file..."
  
  # Check if .env file exists and source it
  if [ -f ./.env ]; then
    set -a
    source ./.env
    set +a
  else
    echo "Error: ./.env file not found."
    exit 1
  fi

  # Create the langflow-secrets
  echo "  Creating langflow-secrets..."
  kubectl create secret generic langflow-secrets \
    --from-literal=LANGFLOW_DATABASE_URL="$LANGFLOW_DATABASE_URL" \
    --from-literal=LANGFLOW_CONFIG_DIR="$LANGFLOW_CONFIG_DIR" \
    --dry-run=client -o yaml | kubectl apply -f -

  echo "✅ Langflow secret created."
}

# Function to deploy a specific component
deploy_component() {
  local component=$1
  echo "🚀 Deploying component: $component..."
  
  local manifests=${components[$component]}
  if [ -z "$manifests" ]; then
    echo "Error: Component '$component' is not defined."
    return 1
  fi
  
  # Special case: create secrets before deploying postgres and langflow
  case "$component" in
    postgres)
      create_postgres_secret
      ;;
    langflow)
      create_langflow_secret
      ;;
  esac

  for manifest in $manifests; do
    echo "  Applying manifest: $manifest"
    kubectl apply -f "$MANIFESTS_DIR/$manifest"
  done
  
  echo "✅ Deployment for $component complete."
}

# Function to deploy all components
deploy_all() {
  echo "🚀 Deploying all Kubernetes components..."
  create_postgres_secret
  create_langflow_secret
  for component in "${!components[@]}"; do
    deploy_component "$component"
  done
  echo "✅ All components deployed."
}

# Function to stop a specific component
stop_component() {
  local component=$1
  local deployment_name="${component}-deployment"
  echo "⏸️ Stopping deployment: $deployment_name..."
  kubectl scale deployment "$deployment_name" --replicas=0
  echo "✅ Deployment '$deployment_name' scaled to 0."
}

# Function to stop all components
stop_all() {
  echo "⏸️ Stopping all deployments..."
  kubectl scale deployment langflow-deployment --replicas=0
  kubectl scale deployment ollama-deployment --replicas=0
  kubectl scale deployment qdrant-deployment --replicas=0
  kubectl scale deployment postgres-deployment --replicas=0
  echo "✅ All deployments scaled to 0."
}

# Function to delete a specific component and its storage
delete_component() {
  local component=$1
  echo "🗑️ Deleting component: $component and its storage..."
  
  # Delete deployments and services
  kubectl delete -f "$MANIFESTS_DIR/${components[$component]}" --ignore-not-found=true

  # Delete PVCs and Secrets
  case "$component" in
    postgres)
      kubectl delete pvc postgres-pvc --ignore-not-found=true
      kubectl delete secret postgres-secrets --ignore-not-found=true
      ;;
    qdrant)
      kubectl delete pvc qdrant-pvc --ignore-not-found=true
      ;;
    ollama)
      kubectl delete pvc ollama-pvc --ignore-not-found=true
      ;;
    langflow)
      kubectl delete pvc langflow-pvc --ignore-not-found=true
      kubectl delete secret langflow-secrets --ignore-not-found=true
      ;;
  esac
  echo "✅ Deletion for $component complete."
}

# Function to delete all components and storage
delete_all() {
  echo "🗑️ Deleting all components and storage..."
  for component in "${!components[@]}"; do
    delete_component "$component"
  done
  echo "✅ Deletion complete."
}

# Main script logic
case "$1" in
  start)
    check_files
    if [ -z "$2" ]; then
      deploy_all
    else
      deploy_component "$2"
    fi
    ;;
  stop)
    if [ -z "$2" ]; then
      stop_all
    else
      stop_component "$2"
    fi
    ;;
  delete)
    check_files
    if [ -z "$2" ]; then
      delete_all
    else
      delete_component "$2"
    fi
    ;;
  *)
    echo "Usage: $0 {start|stop|delete} [component_name]"
    echo "  component_name can be one of: postgres, qdrant, ollama, langflow"
    echo ""
    echo "Examples:"
    echo "  $0 start              # Deploys all components"
    echo "  $0 start ollama       # Deploys only the ollama component"
    echo "  $0 stop               # Stops all components"
    echo "  $0 stop langflow      # Stops only the langflow component"
    echo "  $0 delete             # Deletes all components and storage"
    echo "  $0 delete postgres    # Deletes only the postgres component and storage"
    exit 1
    ;;
esac