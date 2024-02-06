## Flask Tutorial

0a.   create vm and login with password
``` bash
az group create --name flask_rg --location eastus && \
az vm create \
  --resource-group flask_rg \
  --name flask_vm \
  --image Ubuntu2204 \
  --size Standard_B1s \
  --admin-username azureuser \
  --admin-password <PASSWORD> && \
PUBLIC_IP=$(az vm show -d -g flask_rg -n flask_vm --query publicIps -o tsv) && \
ssh azureuser@$PUBLIC_IP
```

0b.   make directory, and create python virtual environment
``` bash
cd ~ && \
sudo apt-get update && \
sudo apt-get install python3.10-venv -y && \
mkdir my_flask_api && \
cd my_flask_api && \
python3 -m venv env && \
source env/bin/activate
```

0c.   get flask
``` bash
pip install Flask
pip freeze > requirements.txt
cat requirements.txt
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

1a.   run app.py in the background
``` bash
nohop python app.py &
```
