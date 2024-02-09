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

1a.   create simplellm.py file
``` bash
cd ~/llmservice-handout/worker/src && \
echo -e "from llama_cpp import Llama
from flask import Flask
from flask import request

MODEL_PATH = \"..src/tinyllama-1.1b-chat-v1.0.Q2_K.gguf\"
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

1b.   create pyproject.toml file
``` bash
cd ~/llmservice-handout/worker/src && \
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

1c.   get model
```
cd ~/llmservice-handout/worker/src && \
wget https://huggingface.co/TheBloke/TinyLlama-1.1B-Chat-v1.0-GGUF/resolve/main/tinyllama-1.1b-chat-v1.0.Q2_K.gguf
```

---

2a.   package with wheel and install
``` bash
cd ~/llmservice-handout/worker && \
make wheel # creates dist/ directory && \
python3 -m pip install dist/simplellm-1.0.0-py2.py3-none-any.whl
```

2b.   run app service with waitress
``` bash
cd ~/llmservice-handout/worker/src && \
waitress-serve simplellm:app &
```

2c.   test endpoints
``` bash
curl http://localhost:8080/healthcheck
curl -G --data-urlencode message="what is TinyLlama?" http://localhost:8080/api
```

---

*.   run llm in background
``` bash
cd ~/llmservice-handout/worker/src && \
flask --app simplellm run --debug &
```

---

[<< Start](https://github.com/AFC-AI2C-Cohort-04/coleman-code/blob/main/cloud_native/week_4/start.md)    [Task 2 >>](https://github.com/AFC-AI2C-Cohort-04/coleman-code/blob/main/cloud_native/week_4/task_2.md)
