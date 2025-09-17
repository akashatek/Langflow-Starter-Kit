# OLLAMA

Start
```
% ./manage-ollama.sh 
Usage: ./manage-ollama.sh {deploy|start|stop|min|run|delete}
  deploy: Creates or updates all resources defined in ollama.yaml.
  start:  Scales the deployment to 1 replica.
  stop:   Scales the deployment to 0 replicas.
  min:    Scales the deployment to 1 replica.
  delete: Deletes all resources.
```

Test
```
# Check all available models
> curl -s http://localhost:11434/api/tags | jq -r '.models[].model'
llama3.2:1b
tinyllama:1.1b        

# Pull tinylama:1.1b
> curl -X POST http://localhost:11434/api/pull -d '{ "name": "tinyllama:1.1b" }'
{"status":"pulling manifest"}

# Test tinylama:1.1b
> curl -s -X POST http://localhost:11434/api/generate \
  -H "Content-Type: application/json" \
  -d '{
    "model": "tinyllama:1.1b",
    "prompt": "What is the capital of France?",
    "stream": false
  }' | jq .response
"The capital of France is Paris, located in Ile-de-France region. It is also known as \"City of Light\" and \"Paris 20th century\"."

# Pull Llama3.2:1b
> curl -X POST http://localhost:11434/api/pull -s -d '{ "name": "llama3.2:1b", "stream": true }'

# Test Llama3.2:1b
> curl http://localhost:11434/api/generate -s -d '{ "model": "llama3.2:1b", "prompt": "What is the capital of France?" }' | jq .response
> curl -s -X POST http://localhost:11434/api/generate \
  -H "Content-Type: application/json" \
  -d '{
    "model": "llama3.2:1b",
    "prompt": "What is the capital of France?",
    "stream": false
  }' | jq .response
"The capital of France is Paris."
```
