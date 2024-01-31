## Data Engineering | Week 3 | Task 2

[Start](https://github.com/AFC-AI2C-Cohort-04/coleman-code/blob/main/data_engineering/week_3/start.md)    [Task 1](https://github.com/AFC-AI2C-Cohort-04/coleman-code/blob/main/data_engineering/week_3/task_1.md)    Task 2

---

0a.   login to azure cli and enable ports
```
sudo apt install -y azure-cli && \
az login --use-device && \
az vm open-port \
  --port 3306 \
  --resource-group relational-databases \
  --name dataengg2
```

0b.   install mySQL server
```
sudo apt update && \
sudo apt install -y mysql-server && \
```

0c.   create mySQL user, login, and create security_db
```
sudo mysql
use mysql;
CREATE USER 'clouduser'@'localhost' IDENTIFIED BY 'dbroot';                                   
GRANT ALL PRIVILEGES ON *.* TO 'clouduser'@'localhost' WITH GRANT OPTION;
CREATE USER 'clouduser'@'%' IDENTIFIED BY 'dbroot';                                   
GRANT ALL PRIVILEGES ON *.* TO 'clouduser'@'%' WITH GRANT OPTION;
FLUSH PRIVILEGES;
SELECT host,user FROM user;
exit;
mysql -u clouduser -pdbroot
source create_security_database.sql
use security_db;
show tables;
exit;
```

0d.   load csv data to security_db
```
sudo chmod 666 /etc/mysql/mysql.conf.d/mysqld.cnf
echo -e "local_infile=1\n[client]\nlocal_infile=1" >> "/etc/mysql/mysql.conf.d/mysqld.cnf"
sudo chmod 644 /etc/mysql/mysql.conf.d/mysqld.cnf
set global local-infile=1
sudo service mysql restart
mysql -u clouduser -pdbroot
source load_tickerInfo_time_series.sql
```

0e.   wait and verify
```
USE security_db;
select count(*) from ticker_info;
select count(*) from time_series;
```

---

1.   a
```

```

---

[<< Task 1](https://github.com/AFC-AI2C-Cohort-04/coleman-code/blob/main/data_engineering/week_3/task_1.md)
