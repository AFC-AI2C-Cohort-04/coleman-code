## Cloud Native | Week 4 | Task 1

[Start](https://github.com/AFC-AI2C-Cohort-04/coleman-code/blob/main/cloud_native/week_4/start.md)    Task 1    [Task 2](https://github.com/AFC-AI2C-Cohort-04/coleman-code/blob/main/cloud_native/week_4/task_2.md)    [Task 3](https://github.com/AFC-AI2C-Cohort-04/coleman-code/blob/main/cloud_native/week_4/task_3.md)    [Task 4](https://github.com/AFC-AI2C-Cohort-04/coleman-code/blob/main/cloud_native/week_4/task_4.md)

[Flask Tutorial](https://github.com/AFC-AI2C-Cohort-04/coleman-code/blob/main/tutorials/flask.md)

---

0a.   activate python virtual environment (don't actually do this, because then you can't get points through the submitter)
``` bash
cd ~/llmservice-handout/ && \
python3 -m venv venv && \
source venv/bin/activate
```

0b.   get flask and llama
``` bash
pip install flask
pip install tinyllama
pip install scipy
pip install llama-cpp-python
```

---

1a.   create pyproject.toml file
``` bash
cd ~/llmservice-handout/worker/src/ && \
echo -e "[project]
name = \"simplellm\"
version = \"1.0.0\"
description = \"description\"
dependencies = [
    \"flask\",
    \"llama-cpp-python\",
    \"waitress\"
]

[build-system]
requires = [\"flit_core<4\"]
build-backend = \"flit_core.buildapi\"

[tool.distutils.bdist_wheel]
universal = true" > pyproject.toml
```

1b.   create simplellm.py file
``` bash
cd ~/llmservice-handout/worker/src/ && \
echo -e "from llama_cpp import Llama
from flask import Flask
from flask import request

MODEL_PATH = \"tinyllama-1.1b-chat-v1.0.Q2_K.gguf\"
N_CTX = 512
N_BATCH = 1
TEMPERATURE = 0.0
MAX_TOKENS = None

llm = Llama(model_path=MODEL_PATH, n_ctx=N_CTX, n_batch=N_BATCH)
app = Flask(__name__)

@app.route(\"/healthcheck\")
def healthcheck():
    return \"OK\"

@app.route(\"/api\")
def api():
    model_description = \"You are an assistant.\"
    user_prompt = request.args.get(\"message\")
    template = f\"<|system|>\\\n{model_description}</s>\\\n<|user|>{user_prompt}</s><|assistant|>\"
    return llm(template, temperature=TEMPERATURE, max_tokens=MAX_TOKENS)" > simplellm.py
```

1c.   get model
```
cd ~/llmservice-handout/worker/src/ && \
wget https://huggingface.co/TheBloke/TinyLlama-1.1B-Chat-v1.0-GGUF/resolve/main/tinyllama-1.1b-chat-v1.0.Q2_K.gguf
```

---

2a.   package llm with wheel
``` bash
cd ~/llmservice-handout/worker/
make wheel
```

2b.   install wheel file
``` bash
cd ~/llmservice-handout/worker/dist/
python3 -m pip install simplellm-1.0.0-py2.py3-none-any.whl
```

2c.   copy files
``` bash
cd ~/llmservice-handout/worker/
mkdir files/
cp src/* files/
cp dist/simplellm-1.0.0-py2.py3-none-any.whl files/simplellm-1.0.0-py2.py3-none-any.whl
```

---

3a.   run app service with waitress
``` bash
cd ~/llmservice-handout/worker/files/
waitress-serve simplellm:app &
```

3b.   app test
``` bash
curl http://localhost:8080/healthcheck && \
curl -G --data-urlencode message="what is TinyLlama?" http://localhost:8080/api
```

3c.   stop all jobs
```
kill $(jobs -p)
```

---

4a.   create Dockerfile
``` bash
cd ~/llmservice-handout/worker/files/
echo -e "FROM python:3.9-alpine3.13
WORKDIR /app/simplellm/

COPY pyproject.toml pyproject.toml
COPY simplellm-1.0.0-py2.py3-none-any.whl simplellm-1.0.0-py2.py3-none-any.whl
COPY tinyllama-1.1b-chat-v1.0.Q2_K.gguf tinyllama-1.1b-chat-v1.0.Q2_K.gguf

RUN apk update && \\
    apk add gcc libc-dev g++ linux-headers musl-dev python3-dev && \\
    pip install --upgrade pip && \\
    pip install flask llama-cpp-python locust waitress wonderwords && \\
    pip install simplellm-1.0.0-py2.py3-none-any.whl

CMD [\"waitress-serve\", \"simplellm:app\"]" > Dockerfile
```

4b.   build docker image from Dockerfile
``` bash
cd ~/llmservice-handout/worker/files/
dockerfile_path=Dockerfile
image_name=simplellm
version=v1.0.0
container_name=$image_name:$version
build_path=./
docker build --rm -f $dockerfile_path -t $container_name $build_path
```

4c.   run docker image in container
``` bash
host_port=8080
cont_port=8080
docker run -d -p $host_port:$cont_port $container_name
```

4d.   test container
``` bash
curl http://localhost:8080/healthcheck && \
curl -G --data-urlencode message="what is TinyLlama?" http://localhost:8080/api
```

4e.   stop process
``` bash
docker stop $(docker ps -aq) && \
docker rm $(docker ps -aq)
```

---

5a.   create acr
``` bash
cd ~/
export acr_name=acr$(uuid | cut -c1-8)
az group create \
  --name project2task1 \
  --location eastus && \
az acr create \
  --resource-group project2task1 \
  --name $acr_name \
  --sku Basic
```

5b.   login to acr
``` bash
acr_name=$(az resource list -g project2task1 --output json | jq -r '.[] | select(.type == "Microsoft.ContainerRegistry/registries") | .name')
az acr update \
  --name $acr_name \
  --admin-enabled true && \
az acr login \
  --name $acr_name
```

---

6a.   tag and push container
``` bash
export acr_server=$acr_name.azurecr.io && \
docker tag $container_name $acr_server/$container_name && \
docker push $acr_server/$container_name
```

6b.   get acr service principle
``` bash
export sp_name=llama_sp && \
export acr_id=$(az acr show --name $acr_name --query "id" --output tsv) && \
export password=$(az ad sp create-for-rbac --name $sp_name --scopes $acr_id --role acrpull --query "password" --output tsv) && \
export username=$(az ad sp list --display-name $sp_name --query "[].appId" --output tsv)
```

6c.   create container instance
``` bash
export dns_name=azure-llm-$(uuid | cut -c1-8)
az container create \
  --resource-group project2task1 \
  --name llmserveraci \
  --image $acr_server/$container_name \
  --cpu 2 \
  --memory 2 \
  --registry-login-server $acr_server \
  --registry-username $username \
  --registry-password $password \
  --ip-address Public \
  --dns-name-label $dns_name \
  --ports 8080
```

---

7a.   validation healthcheck
``` bash
curl http://${dns_name}.eastus.azurecontainer.io:8080/healthcheck && \
curl http://${dns_name}.eastus.azurecontainer.io:8080/api?message=what
```

7b.   submit
``` bash
export SUBMISSION_USERNAME=<USERNAME>
export SUBMISSION_PASSWORD=<PASSWORD>
cd ~/llmservice-handout/
./submitter task1
```

---

*.   loadtester (optional)
``` bash
cd ~/llmservice-handout/worker/loadtester/
pip install -r requirements.txt && locust --headless -H http://${dns_name}.eastus.azurecontainer.io:8080
```

---

[<< Start](https://github.com/AFC-AI2C-Cohort-04/coleman-code/blob/main/cloud_native/week_4/start.md)    [Task 2 >>](https://github.com/AFC-AI2C-Cohort-04/coleman-code/blob/main/cloud_native/week_4/task_2.md)
