## Cloud Native | Week 4 | Task 1

[Start](https://github.com/AFC-AI2C-Cohort-04/coleman-code/blob/main/cloud_native/week_4/start.md)    Task 1    [Task 2](https://github.com/AFC-AI2C-Cohort-04/coleman-code/blob/main/cloud_native/week_4/task_2.md)    [Task 3](https://github.com/AFC-AI2C-Cohort-04/coleman-code/blob/main/cloud_native/week_4/task_3.md)    [Task 4](https://github.com/AFC-AI2C-Cohort-04/coleman-code/blob/main/cloud_native/week_4/task_4.md)

[Flask Tutorial](https://github.com/AFC-AI2C-Cohort-04/coleman-code/blob/main/tutorials/flask.md)

---

0a.   activate python virtual environment
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

MODEL_PATH = \"../src/tinyllama-1.1b-chat-v1.0.Q2_K.gguf\"
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

3a.   run app service with waitress
``` bash
cd ~/llmservice-handout/worker/src/
waitress-serve simplellm:app &
```

3b.   test healthcheck (returns 'OK')
``` bash
curl http://localhost:8080/healthcheck
```

3c.   test api (returns JSON response after a few seconds)
``` bash
curl -G --data-urlencode message="what is TinyLlama?" http://localhost:8080/api
```

*.   stop all jobs
```
kill $(jobs -p)
```

---

4a.   create Dockerfile
``` bash
cd ~/llmservice-handout/worker/
echo -e "FROM python:3.9-alpine3.13
WORKDIR /app/simplellm/

COPY src/pyproject.toml src/pyproject.toml
COPY dist/simplellm-1.0.0-py2.py3-none-any.whl dist/simplellm-1.0.0-py2.py3-none-any.whl
COPY src/tinyllama-1.1b-chat-v1.0.Q2_K.gguf src/tinyllama-1.1b-chat-v1.0.Q2_K.gguf

RUN apk update && \\
    apk add gcc libc-dev g++ linux-headers musl-dev python3-dev && \\
    pip install --upgrade pip && \\
    pip install flask llama-cpp-python locust waitress wonderwords

RUN pip install dist/simplellm-1.0.0-py2.py3-none-any.whl

CMD ["waitress-serve", "simplellm:app"]" > docker/Dockerfile
```

4b.   build docker image from Dockerfile
``` bash
cd ~/llmservice-handout/worker/
dockerfile_path=docker/Dockerfile
image_name=simplellm
version=latest
container_name=$image_name:$version
build_path=./
# --rm removes previous version
docker build --rm -f $dockerfile_path -t $container_name $build_path
```

4c.   run docker image in container
``` bash
host_port=8080
cont_port=8080
docker run -d -p $host_port:$cont_port $container_name
```

4d.   test connection
``` bash
my_ip=$(curl ip.me)
curl $my_ip:$host_port
```



docker run --name demo -d -p 8080:8080 griffin/simplellm:v1.0.0

---

*.   run llm in background
``` bash
cd ~/llmservice-handout/worker/src/ && \
flask --app simplellm run --debug &
```

---

[<< Start](https://github.com/AFC-AI2C-Cohort-04/coleman-code/blob/main/cloud_native/week_4/start.md)    [Task 2 >>](https://github.com/AFC-AI2C-Cohort-04/coleman-code/blob/main/cloud_native/week_4/task_2.md)
