# OLQP
Ollama, Langflow, Qdrant, and Postgres starter kit.

Table Of Content:
* [Description](#Description)
* [Reference](#Reference)
* [Deployment](#Deployment)
* [Qdrant](#Qdrant)
* [Ollama](#Ollama)
* [Postgres](#Postgres)
* [LangFlow](#LangFlow)

<a id="Description"></a>
## Description
 
Setting up a Starter Kit for Ollama, Langflow, Qdrant, and Postgres (OLQP).   
Large Language Model (LLM) will rely on Llama3.2:1b deployed using Ollama.   
SQL Database will be covered by Postgres.   
Vector Store wil be covered by Qdrant.   
Flow Manager will be covered by Langflow.   

<a id="Reference"></a>
## Reference

Dokcerhub Reference
* [Ollama](https://hub.docker.com/r/ollama/ollama)
* [Langflow](https://hub.docker.com/r/langflowai/langflow)
* [Qdrant](https://hub.docker.com/r/qdrant/qdrant)
* [Postgres](https://hub.docker.com/_/postgres)

<a id="Deployment"></a>
## Deployment

Please make sure to make a local copy of this git repo.
```
> git clone https://github.com/akashatek/OLQP
```

Copy your local file **dev.env** into a new secret file **.env**.  
And update the variables as follow.
```
# POSTGRES
POSTGRES_USER=postgres
POSTGRES_PASSWORD=postgres
POSTGRES_DB=postgres
POSTGRES_URL=postgresql://${POSTGRES_USER}:${POSTGRES_PASSWORD}@postgres:5432/${POSTGRES_DB}

# OLLAMA
OLLAMA_BASE_URL=http://ollama:11434

# QDRANT
QDRANT_BASE_URL=http://qdrant:6333

# LANGFLOW
LANGFLOW_DATABASE_URL=postgresql://langflow:langflow@postgres:5432/langflow
LANGFLOW_CONFIG_DIR=/app/langflow
```

Deploy all containers.
```
> docker-compose up -d

[+] Running 10/10
 ✔ Network olqp_default              Created                                                                                     0.0s 
 ✔ Volume "olqp_ollama_data"         Created                                                                                     0.0s 
 ✔ Volume "olqp_langflow_data"       Created                                                                                     0.0s 
 ✔ Volume "olqp_postgres_data"       Created                                                                                     0.0s 
 ✔ Volume "olqp_qdrant_data"         Created                                                                                     0.0s 
 ✔ Container olqp-ollama-1           Started                                                                                     0.3s 
 ✔ Container olqp-postgres-1         Started                                                                                     0.2s 
 ✔ Container olqp-qdrant-1           Started                                                                                     0.2s 
 ✔ Container olqp-langflow-1         Started                                                                                     0.3s 
 ✔ Container olqp-fix_permissions-1  Started                                                                                     0.5s 
 ```

Stop all containers.
```
> docker-compose down

```

If you want to delete all volumes too.
```
> docker-compose down -v
```

<a id="Qdrant"></a>
## Qdrant
 
Create collections for RAG Ollama mxbai-embed-large embedding.
```
> curl -s -X PUT "http://localhost:6333/collections/ollama-large" -H "Content-Type: application/json" -d '{"vectors": {"size": 1024, "distance": "Cosine"}}' | jq .
{
  "result": true,
  "status": "ok",
  "time": 0.03996675
}
```

<a id="Ollama"></a>
## Ollama

Ollama is automatically downloading a [llama3.2:1b](https://ollama.com/library/llama3.2) model and an [mxbai](https://ollama.com/library/mxbai-embed-large) embedding.

List of Ollama installed models
```
> curl -s http://localhost:11434/api/tags | jq  '.models[].model'

"mxbai-embed-large:latest"
"llama3.2:1b"
```

Test llama3.2:1b model
```
> curl -s -X POST http://localhost:11434/api/generate -d '{
   "model": "llama3.2:1b",
   "prompt":"Whta is the capital of France?",
   "stream": false
}' | jq .response
"The capital of France is Paris, also known as \"Capitale de France.\" It's located in the Ile-de-France region, in the northern part of the country. The current government of France and its president are located at the Elysee Palace in the heart of the city."
```

Test mxbai embedding.
```
> curl -s http://localhost:11434/api/embed -d '{
    "model": "mxbai-embed-large",
    "input": "Llamas are members of the camelid family"
}' | jq .

{
  "model": "mxbai-embed-large",
  "embeddings": [
    [
      0.032869164,
      0.06611291,
      0.036097866,
      0.04505933,
      -0.007494945,
      ...
      -0.017978853,
      0.021249613,
      0.02600838,
      0.039708924
    ]
  ],
  "total_duration": 54404417,
  "load_duration": 9895417,
  "prompt_eval_count": 10
```

Manually pull a model
```
> curl -X POST http://localhost:11434/api/pull -d '{
  "name": "tinyllama:1.1b"
}'

...
```

<a id="Postgres"></a>
## Postgres

Test your Postgres Database.
```
> psql -h localhost -U postgres
> Password for user postgres: [please enter postgres]
psql (17.6, server 17.5 (Debian 17.5-1.pgdg130+1))
Type "help" for help.

> postgres=# \dt
            List of relations
 Schema |     Name     | Type  |  Owner   
--------+--------------+-------+----------
 public | country_data | table | postgres
(1 row)

> postgres=# \du
                             List of roles
 Role name |                         Attributes                         
-----------+------------------------------------------------------------
 langflow  | Superuser
 postgres  | Superuser, Create role, Create DB, Replication, Bypass RLS

> postgres=# \q
```

<a id="LangFlow"></a>
## LangFlow
 
Reach out to langflow Service: [http://localhost:7860/](http://localhost:7860/)

### Basic Prompting

### Simple Agent

### Vector Store RAG




/!\ Langflow Bug /!\ In code edit. Force SSL deactivation by adding "https": False.
 ```
 server_kwargs = {
             "host": self.host or None,
             "port": int(self.port),  # Ensure port is an integer
             "grpc_port": int(self.grpc_port),  # Ensure grpc_port is an integer
             "api_key": self.api_key,
             "prefix": self.prefix,
             # Ensure timeout is an integer
             "timeout": int(self.timeout) if self.timeout else None,
             "path": self.path or None,
             "url": self.url or None,
             "https": False
         }
 
 ```