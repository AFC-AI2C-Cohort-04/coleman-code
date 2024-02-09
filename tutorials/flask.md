## Flask Tutorial

0a.   create vm, open port 80, and login with password
``` bash
az group create --name flask_rg --location eastus && \
az vm create \
  --resource-group flask_rg \
  --name flask_vm \
  --image Ubuntu2204 \
  --size Standard_B1s \
  --admin-username azureuser \
  --admin-password <PASSWORD> && \
az vm open-port \
  --resource-group flask_rg \
  --name flask_vm \
  --port 80 \
  --priority 1002 && \
PUBLIC_IP=$(az vm show -d -g flask_rg -n flask_vm --query publicIps -o tsv) && \
ssh azureuser@$PUBLIC_IP
```

0b.   make directory, and create python virtual environment
``` bash
cd ~ && \
sudo apt update && \
sudo apt upgrade -y && \
sudo apt install python3 python3-pip python3-venv nginx uuid -y && \
mkdir my_flask_api && \
cd my_flask_api && \
python3 -m venv env && \
source env/bin/activate
```

0c.   get flask
``` bash
pip install Flask
pip freeze > requirements.txt
echo -e "importlib-metadata==7.0.1
zipp==3.17.0" >> requirements.txt
```

0d.   create quotes.json
``` bash
echo -e "[
  {\"content\": \"The only limit to our realization of tomorrow will be our doubts of today.\", \"author\": \"Franklin D. Roosevelt\"},
  {\"content\": \"In three words I can sum up everything I've learned about life: it goes on.\", \"author\": \"Robert Frost\"},
  {\"content\": \"Do not dwell in the past, do not dream of the future, concentrate the mind on the present moment.\", \"author\": \"Buddha\"},
  {\"content\": \"Success is not final, failure is not fatal: It is the courage to continue that counts.\", \"author\": \"Winston Churchill\"},
  {\"content\": \"The only way to do great work is to love what you do.\", \"author\": \"Steve Jobs\"},
  {\"content\": \"Believe you can and you're halfway there.\", \"author\": \"Theodore Roosevelt\"},
  {\"content\": \"It always seems impossible until it's done.\", \"author\": \"Nelson Mandela\"},
  {\"content\": \"Life is what happens when you're busy making other plans.\", \"author\": \"John Lennon\"},
  {\"content\": \"The future belongs to those who believe in the beauty of their dreams.\", \"author\": \"Eleanor Roosevelt\"},
  {\"content\": \"The purpose of our lives is to be happy.\", \"author\": \"Dalai Lama\"},
  {\"content\": \"The best way to predict the future is to create it.\", \"author\": \"Peter Drucker\"},
  {\"content\": \"Happiness is not by chance, but by choice.\", \"author\": \"Jim Rohn\"},
  {\"content\": \"Success usually comes to those who are too busy to be looking for it.\", \"author\": \"Henry David Thoreau\"},
  {\"content\": \"Your time is limited, don't waste it living someone else's life.\", \"author\": \"Steve Jobs\"}
]" > quotes.json
```

0e.   create app.py
``` bash
echo -e "from flask import Flask, jsonify
import random
import json

app = Flask(__name__)

# Read quotes from the JSON file
with open('quotes.json', 'r') as file:
    quotes = json.load(file)

@app.route('/random-quote', methods=['GET'])
def get_random_quote():
    # Randomly pick a quote from the list
    random_quote = random.choice(quotes)

    # Return the randomly picked quote as JSON
    return jsonify(random_quote)

if __name__ == '__main__':
    app.run(debug=True)" > app.py
```

---

1a.   run app.py in background
``` bash
nohup python app.py &
```

1b.   test and close application
``` bash
curl http://127.0.0.1:5000/random-quote && \
kill $(jobs -p)
```

---

2a.   get gunicorn
``` bash
pip install gunicorn
```

2b.   create service file
``` bash
echo -e "[Unit]
Description=Gunicorn instance to serve my_flask_api
After=network.target

[Service]
User=$(whoami)
Group=$(whoami)
WorkingDirectory=/home/$(whoami)/my_flask_api
ExecStart=/home/$(whoami)/my_flask_api/venv/bin/gunicorn -w 4 -b 0.0.0.0:5000 app:app

[Install]
WantedBy=multi-user.target" | sudo tee /etc/systemd/system/my_flask_api.service
```

2c.   enable and start app service
``` bash
sudo systemctl enable my_flask_api && \
sudo systemctl start my_flask_api
```

---

3a.   login to azure cli
``` bash
curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash && \
az login --use-device
```

3b.   deploy app service
``` bash
export MY_UUID=$(uuid | cut -c1-8) && \
az appservice plan create \
  --name flask_plan_$MY_UUID \
  --resource-group flask_rg \
  --sku B1 \
  --is-linux && \
az webapp create \
  --resource-group flask_rg \
  --plan flask_plan_$MY_UUID \
  --name flask-app-$MY_UUID \
  --runtime "PYTHON|3.10" && \
az webapp up \
  --resource-group flask_rg \
  --name flask-app-$MY_UUID
```

3c.   create nginx server block
```
echo -e "server {
    listen 80;
    server_name flask-app-$MY_UUID.azurewebsites.net;

    location / {
        proxy_pass http://127.0.0.1:5000;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
    }
}" | sudo tee /etc/nginx/sites-available/my_flask_api
```

3d.   create nginx symlink and test connection
``` bash
sudo ln -s /etc/nginx/sites-available/my_flask_api /etc/nginx/sites-enabled && \
sudo nginx -t && \
sudo systemctl restart nginx && \
echo "go to: flask-app-$MY_UUID.azurewebsites.net/random-quote"
```
