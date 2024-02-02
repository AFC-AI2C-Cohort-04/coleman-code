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
sudo mysql
```

0c.   create mySQL user
```
USE mysql;
CREATE USER 'clouduser'@'localhost' IDENTIFIED BY 'dbroot';                                   
GRANT ALL PRIVILEGES ON *.* TO 'clouduser'@'localhost' WITH GRANT OPTION;
CREATE USER 'clouduser'@'%' IDENTIFIED BY 'dbroot';                                   
GRANT ALL PRIVILEGES ON *.* TO 'clouduser'@'%' WITH GRANT OPTION;
FLUSH PRIVILEGES;
SELECT host,user FROM user;
EXIT;
```

0d.   login to mysql
```
mysql -u clouduser -pdbroot
```

0e.   create security_db
```
SOURCE create_security_database.sql;
USE security_db;
SHOW TABLES;
EXIT;
```

0f.   configure mysqld.cnf file
```
sudo chmod 666 /etc/mysql/mysql.conf.d/mysqld.cnf
sudo sed -i 's/^bind-address/# bind-address/' /etc/mysql/mysql.conf.d/mysqld.cnf
echo -e "local_infile=1\n[client]\nlocal_infile=1" >> "/etc/mysql/mysql.conf.d/mysqld.cnf"
sudo chmod 644 /etc/mysql/mysql.conf.d/mysqld.cnf
set global local-infile=1
sudo service mysql restart
export DB_VM_IP=$(curl ip.me) && \
export DB_PASSWORD=dbroot && \
mysql -u clouduser -pdbroot -h $DB_VM_IP
```

0g.   load csv data into security_db
```
SOURCE load_tickerInfo_time_series.sql;
```


0h.   wait and verify
```
USE security_db;
SELECT COUNT(*) FROM ticker_info; # ticker_info COUNT(*) = 8507
SELECT COUNT(*) FROM time_series; # time_series COUNT(*) = 17453243
EXIT;
```

---

1a.   update q6.sql
```
cd ~/relational-databases-1/
echo -e "USE security_db;

-- NASDAQ INFO
DROP TABLE nasdaq_info;
CREATE TABLE nasdaq_info (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    symbol VARCHAR(14),
    security_name VARCHAR(255),
    market_category ENUM('Q','G','S'),
    test_issue ENUM('Y','N'),
    financial_status ENUM('D','E','Q','N','G','H','J','K'),
    round_lot_size INT,
    etf ENUM('Y','N'),
    next_shares ENUM('Y','N'));
LOAD DATA LOCAL infile 'nasdaqlistedMod.txt'
    INTO TABLE nasdaq_info
    FIELDS TERMINATED BY '|'
    ENCLOSED BY ''
    LINES TERMINATED BY '\n'
    IGNORE 1 ROWS
    (symbol, security_name, market_category, test_issue, financial_status, round_lot_size, etf, next_shares)
    SET id=null;

-- drop test_issue column
ALTER TABLE nasdaq_info
    DROP COLUMN test_issue;

-- OTHER EXCHANGE INFO
DROP TABLE other_exchange_info;
CREATE TABLE other_exchange_info (
    id INT AUTO_INCREMENT PRIMARY KEY,
    act_symbol VARCHAR(14),
    security_name VARCHAR(255),
    exchange enum('A','N','P','Q', 'Z', 'V'),
    cqs_symbol VARCHAR(14),
    etf ENUM('Y','N'),
    round_lot_size INT,
    test_issue ENUM('Y','N'),
    nasdaq_symbol VARCHAR(14));
LOAD DATA LOCAL INFILE 'otherlistedMod.txt'
    INTO TABLE other_exchange_info
    FIELDS TERMINATED BY '|'
    ENCLOSED BY ''
    LINES TERMINATED BY '\n'
    IGNORE 1 ROWS
    (act_symbol, security_name, exchange, cqs_symbol, etf, round_lot_size, test_issue, nasdaq_symbol)
    SET id=null;

-- delete 'Z' and 'V' from exchange column
DELETE FROM other_exchange_info
  WHERE exchange IN ('Z', 'V');

-- delete 'Y' from test_issue column
DELETE FROM other_exchange_info WHERE test_issue='Y';

-- drop test_issue column
ALTER TABLE other_exchange_info
    DROP COLUMN test_issue;" > q6.sql
```

1b.   load nasdaq and other listed data to security_db
```
mysql -u clouduser -pdbroot -h $DB_VM_IP
SOURCE q6.sql;
EXIT;
```

---

2a.   update q7.sql
```
cd ~/relational-databases-1/
echo -e "USE security_db;
ALTER TABLE time_series DROP COLUMN open_int;" > q7.sql
```

2b.   drop open_int column from time_series
```
mysql -u clouduser -pdbroot -h $DB_VM_IP
SOURCE q7.sql;
EXIT;
```

---

3a.   update q8.sql
```
cd ~/relational-databases-1/
echo -e "USE security_db;
-- DELETE FROM other_exchange_info
--   WHERE exchange IN ('Z', 'V');" > q8.sql
```

3b.   drop BATS and IEXG records
```
mysql -u clouduser -pdbroot -h $DB_VM_IP
SOURCE q8.sql;
EXIT;
```

---

4a.   update q9.sql
```
cd ~/relational-databases-1/
echo -e "USE security_db;
ALTER TABLE nasdaq_info
  ADD COLUMN exchange
  ENUM('A', 'N', 'P', 'Q') DEFAULT 'Q';" > q9.sql
```

4b.   add exchange column to nasdaq_info
```
mysql -u clouduser -pdbroot -h $DB_VM_IP
SOURCE q9.sql;
EXIT;
```

---

5a.   update q10.sql
```
cd ~/relational-databases-1/
echo -e "USE security_db;

-- NASDAQ INFO
DROP TABLE nasdaq_info;
CREATE TABLE nasdaq_info (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    symbol VARCHAR(14),
    security_name VARCHAR(255),
    market_category ENUM('Q','G','S'),
    test_issue ENUM('Y','N'),
    financial_status ENUM('D','E','Q','N','G','H','J','K'),
    round_lot_size INT,
    etf ENUM('Y','N'),
    next_shares ENUM('Y','N'));
LOAD DATA LOCAL infile 'nasdaqlistedMod.txt'
    INTO TABLE nasdaq_info
    FIELDS TERMINATED BY '|'
    ENCLOSED BY ''
    LINES TERMINATED BY '\n'
    IGNORE 1 ROWS
    (symbol, security_name, market_category, test_issue, financial_status, round_lot_size, etf, next_shares)
    SET id=null;

-- delete 'Y' from test_issue column
DELETE FROM nasdaq_info WHERE test_issue='Y';

-- drop test_issue column
ALTER TABLE nasdaq_info DROP COLUMN test_issue;

-- add exchange column to nasdaq_info
ALTER TABLE nasdaq_info
  ADD COLUMN exchange
  ENUM('A', 'N', 'P', 'Q') DEFAULT 'Q';

-- OTHER EXCHANGE INFO
DROP TABLE other_exchange_info;
CREATE TABLE other_exchange_info (
    id INT AUTO_INCREMENT PRIMARY KEY,
    act_symbol VARCHAR(14),
    security_name VARCHAR(255),
    exchange enum('A','N','P','Q', 'Z', 'V'),
    cqs_symbol VARCHAR(14),
    etf ENUM('Y','N'),
    round_lot_size INT,
    test_issue ENUM('Y','N'),
    nasdaq_symbol VARCHAR(14));
LOAD DATA LOCAL INFILE 'otherlistedMod.txt'
    INTO TABLE other_exchange_info
    FIELDS TERMINATED BY '|'
    ENCLOSED BY ''
    LINES TERMINATED BY '\n'
    IGNORE 1 ROWS
    (act_symbol, security_name, exchange, cqs_symbol, etf, round_lot_size, test_issue, nasdaq_symbol)
    SET id=null;

-- delete 'Y' from test_issue column
DELETE FROM other_exchange_info WHERE test_issue='Y';

-- drop test_issue column
ALTER TABLE other_exchange_info DROP COLUMN test_issue;

-- delete 'Z' and 'V' from exchange column
DELETE FROM other_exchange_info
  WHERE exchange IN ('Z', 'V');

-- merge nasdaq_info and other_exchange_info
INSERT INTO nasdaq_info (symbol, security_name, market_category, financial_status, round_lot_size, etf, next_shares, exchange)
  SELECT nasdaq_symbol, security_name, null, null, round_lot_size, etf, null, exchange
  FROM other_exchange_info;" > q10.sql
```

5b.   merge tables and drop
```
mysql -u clouduser -pdbroot -h $DB_VM_IP
SOURCE q10.sql;
EXIT;
```

---

6.   submit (grading is messed-up)
```
export SUBMISSION_USERNAME=<USERNAME>
export SUBMISSION_PASSWORD=<PASSWORD>
cd ~/relational-databases-1
./submitter -t 2
```

[<< Task 1](https://github.com/AFC-AI2C-Cohort-04/coleman-code/blob/main/data_engineering/week_3/task_1.md)
