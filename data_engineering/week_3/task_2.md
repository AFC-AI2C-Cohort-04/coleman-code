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

1a.   q6.sql (file contents)
```
use security_db;
load data local infile 'nasdaqlistedMod.txt'
    into table nasdaq_info
    fields terminated by '|'
    enclosed by ''
    lines terminated by '\n'
    ignore 1 rows
    (symbol, security_name, market_category, test_issue, financial_status, round_lot_size, etf, next_shares)
    set id=null;
load data local infile 'otherlistedMod.txt'
    into table other_exchange_info
    fields terminated by '|'
    enclosed by ''
    lines terminated by '\n'
    ignore 1 rows
    (act_symbol, security_name, exchange, cqs_symbol, etf, round_lot_size, test_issue, nasdaq_symbol)
    set id=null;
```

1b.   load nasdaq and other listed data to security_db
```
source q6.sql
```

---

2a.   q7.sql (file contents)
```
use security_db;
ALTER TABLE time_series DROP COLUMN open_int;
```

2b.   drop open_int column from time_series
```
source q7.sql
```

---

3a.   q8.sql (file contents)
```
use security_db;
DELETE FROM other_exchange_info
  WHERE exchange IN ('Z', 'V');
```

3b.   drop BATS and IEXG records
```
source q8.sql
```

---

4a.   q9.sql (file contents)
```
use security_db;

```

4b.   d
```
source q9.sql
```

---

x.   submit
```
export SUBMISSION_USERNAME=<USERNAME>
export SUBMISSION_PASSWORD=<PASSWORD>
export DB_VM_IP=$(curl ip.me)
export DB_PASSWORD=dbroot
cd ~/relational-databases-1
./submitter -t 2
```

[<< Task 1](https://github.com/AFC-AI2C-Cohort-04/coleman-code/blob/main/data_engineering/week_3/task_1.md)
