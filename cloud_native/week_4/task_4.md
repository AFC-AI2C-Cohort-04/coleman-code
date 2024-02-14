## Cloud Native | Week 4 | Task 4

[Start](https://github.com/AFC-AI2C-Cohort-04/coleman-code/blob/main/cloud_native/week_4/start.md)    [Task 1](https://github.com/AFC-AI2C-Cohort-04/coleman-code/blob/main/cloud_native/week_4/task_1.md)    [Task 2](https://github.com/AFC-AI2C-Cohort-04/coleman-code/blob/main/cloud_native/week_4/task_2.md)    [Task 3](https://github.com/AFC-AI2C-Cohort-04/coleman-code/blob/main/cloud_native/week_4/task_3.md)    Task 4

[can't resolve error: "worker failed to index functions"]

---

0a.   get azure function core tools
``` bash
cd ~/
curl https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > microsoft.gpg
sudo mv microsoft.gpg /etc/apt/trusted.gpg.d/microsoft.gpg
sudo sh -c 'echo "deb [arch=amd64] https://packages.microsoft.com/repos/microsoft-ubuntu-$(lsb_release -cs)-prod $(lsb_release -cs) main" > /etc/apt/sources.list.d/dotnetdev.list'
sudo apt-get update && sudo apt-get install azure-functions-core-tools-4
```

0b.   make task4 directory and get trigger (select option 1. FUNCTION)
``` bash
mkdir ~/llmservice-handout/task4/
cd ~/llmservice-handout/task4/
func init --worker-runtime python && \
func new --name api --template "HTTP trigger" --authlevel "anonymous"
```

---

1a.   update function_app.py
``` bash
cd ~/llmservice-handout/task4/
echo -e "import logging
import azure.functions as func
from llama_cpp import Llama

MODEL_PATH = 'tinyllama-1.1b-chat-v1.0.Q2_K.gguf'
N_CTX = 512
N_BATCH = 1
MODEL_DESCRIPTION = 'You are an assistant.'

app = func.FunctionApp()
model = Llama(model_path=MODEL_PATH, n_ctx=N_CTX, n_batch=N_BATCH)

@app.route(route='llm', auth_level=AuthLevel.ANONYMOUS)
def api(req: func.HttpRequest) -> func.HttpResponse:
    user_prompt = req.params.get('message')
    logging.info(f'[User] {user_prompt}')
    template = f'<|system|>\n{MODEL_DESCRIPTION}</s>\n<|user|>{user_prompt}</s><|assistant|>'
    response = str(model(template, temperature=0.0, max_tokens=None))
    logging.info(f'[Model] {response}')
    return func.HttpResponse(response)" > function_app.py
```

1b.   copy model to directory
``` bash
cp ~/llmservice-handout/worker/files/tinyllama-1.1b-chat-v1.0.Q2_K.gguf ~/llmservice-handout/task4/tinyllama-1.1b-chat-v1.0.Q2_K.gguf
```

---

2.   start function
``` bash
cd ~/llmservice-handout/task4/
func start
```

---

[<< Task 3](https://github.com/AFC-AI2C-Cohort-04/coleman-code/blob/main/cloud_native/week_4/task_3.md)
