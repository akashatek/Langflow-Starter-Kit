# Langflow Starter Kit

Reference: 
 * [author](https://akashatek.infinityfreeapp.com/authors/alvin-heib/)
 * [blog.akashatek.com](https://akashatek.infinityfreeapp.com/langflow-starter-kit-2.html)

Table Of Content:
* [Description](#Description)
* [Requirements](#Requirements)
* [Reference](#Reference)
* [Deployment](#Deployment)
* [Qdrant](#Qdrant)
* [Ollama](#Ollama)
* [Postgres](#Postgres)
* [LangFlow](#LangFlow)

<a id="Description"></a>
## Description
 
The next wave of AI innovation won't be powered by single, proprietary systems, but by flexible, open-source stacks that give you total control. To prove this, I'm introducing the `Langflow Starter Kit (OLQP)`. This powerful combination of `Ollama` (for the LLM), `Langflow` (for flow management), `Qdrant` (for vector search), and `Postgres` (for database) provides the foundation you need to build scalable, production-ready AI applications.


<a id="Requirements"></a>
## Requirements

Before you begin, ensure your system is properly configured:

 * `Docker Desktop`: This is a required application that includes Docker Engine and Docker Compose. You can download it for macOS from the Docker Desktop website.

 * `Git`: Make sure Git is configured on your machine. You can verify this by running git --version in your terminal.

System Specifications:

 * `CPU`: 8 or more cores/threads.

 * `RAM`: 16 GB or more.

I am currently using `Mac Mini` (Apple M4, 24 GB RAM) meets and exceeds all these requirements. Other configurations has not been tested.

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
> git clone https://github.com/akashatek/Langflow-Starter-Kit
```

Copy your either **prod.env**, or **dev.env** into a new secret file **.env**.  
And update the user / password variables as needed.
```
# LOCALHOST
LOCAL_HOST=localhost

# POSTGRES
POSTGRES_HOST=postgres
POSTGRES_USER=postgres
POSTGRES_PASSWORD=postgres
POSTGRES_DB=postgres
POSTGRES_URL=postgresql://${POSTGRES_USER}:${POSTGRES_PASSWORD}@${LOCAL_HOST}:5432/${POSTGRES_DB}

# OLLAMA
OLLAMA_HOST=ollama
OLLAMA_BASE_URL=http://${LOCAL_HOST}:11434

# QDRANT
QDRANT_HOST=qdrant
QDRANT_BASE_URL=http://${LOCAL_HOST}:6333

# LANGFLOW
LANGFLOW_DATABASE_URL=postgresql://langflow:langflow@${LOCAL_HOST}:5432/langflow
LANGFLOW_CONFIG_DIR=/app/langflow
```

Deploy all containers.
```
> docker-compose up -d

[+] Running 9/9
 ✔ Network olqp               Created                                                                        0.0s 
 ✔ Volume olqp_langflow_data  Created                                                                        0.0s 
 ✔ Volume olqp_postgres_data  Created                                                                        0.0s 
 ✔ Volume olqp_qdrant_data    Created                                                                        0.0s 
 ✔ Volume olqp_ollama_data    Created                                                                        0.0s 
 ✔ Container olqp-postgres-1  Started                                                                        0.1s 
 ✔ Container olqp-ollama-1    Started                                                                        0.2s 
 ✔ Container olqp-qdrant-1    Started                                                                        0.2s 
 ✔ Container olqp-langflow-1  Started                                                                        0.2s 
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
   "prompt":"What is the capital of France?",
   "stream": false
}' | jq .response

"The capital of France is Paris."
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
      ...
       0.021249613,
      0.02600838,
      0.039708924
    ]
  ],
  "total_duration": 54320875,
  "load_duration": 10221250,
  "prompt_eval_count": 10
}
```

Manually pull a model
```
> curl -X POST http://localhost:11434/api/pull -d '{
  "name": "tinyllama:1.1b"
}'

{"status":"pulling manifest"}
{"status":"pulling 2af3b81862c6","digest":"sha256:2af3b81862c6be03c769683af18efdadb2c33f60ff32ab6f83e42c043d6c7816","total":637699456}
...
{"status":"pulling 6331358be52a","digest":"sha256:6331358be52a6ebc2fd0755a51ad1175734fd17a628ab5ea6897109396245362","total":483,"completed":483}
{"status":"verifying sha256 digest"}
{"status":"writing manifest"}
{"status":"success"}

> curl -s http://localhost:11434/api/tags | jq  '.models[].model'

"tinyllama:1.1b"
"mxbai-embed-large:latest"
"llama3.2:1b"
```

<a id="Postgres"></a>
## Postgres

Test your Postgres Database.
```
# so that you can call the services locally with localhost
> source dev.env
> psql $POSTGRES_URL

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

For tutorial and flow import ,please reach out to blog [blog.akashatek.com](http://blog.akashatek.com)