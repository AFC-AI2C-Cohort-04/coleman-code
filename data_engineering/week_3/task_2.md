## Data Engineering | Week 3 | Task 2

[Start](https://github.com/AFC-AI2C-Cohort-04/coleman-code/blob/main/data_engineering/week_3/start.md)    Task 1

---

0.   login to azure cli and enable ports
```
sudo apt install -y azure-cli && \
az login --use-device
```





 az vm open-port \
     --port 3306 \
     --resource-group relational-databases \
     --name dataengg2
