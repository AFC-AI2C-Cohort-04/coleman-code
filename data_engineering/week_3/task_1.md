## Data Engineering | Week 3 | Task 1

[Start](https://github.com/AFC-AI2C-Cohort-04/coleman-code/blob/main/data_engineering/week_3/start.md)    Task 1

---

0.   get securities trading data
```
cd ~/relational-databases-1 && \
wget https://principlesofcomputing.blob.core.windows.net/relational-databases-1/handout/security.zip -O security.zip && \
sudo apt install unzip && \
unzip security.zip && \
rm security.zip && \
jupyter notebook --no-browser
# follow link in terminal with following pattern http://127.0.0.1:8888/?token=<token>
```

---

1.   normalize_filename()
```
def normalize_filename(filename):
    new_label = ''
    new_label = re.sub('-ws-', '+', filename)
    new_label = re.sub('-ws', '+', new_label)
    new_label = re.sub('-cl', '*', new_label)
    new_label = re.sub('-u', '=', new_label)
    if(re.fullmatch('.*-.*', new_label)):
        new_label = re.sub('-', '.', new_label)
    elif(re.fullmatch('.*_.*', new_label)):
        new_label = re.sub('_', '-', new_label)
    return new_label.upper()
```

---

2.   file2df()
```

```

---

[<< Start](https://github.com/AFC-AI2C-Cohort-04/coleman-code/blob/main/data_engineering/week_3/start.md)
