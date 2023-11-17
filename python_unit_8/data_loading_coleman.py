import mysql.connector, csv, pymongo, json

def setup_sql_table(user, password, host, new_db, new_table):
    CONNECT = mysql.connector.connect(
        host=host,
        user=user,
        password=password
    )
    CURSOR = CONNECT.cursor()
    CURSOR.execute(f'DROP DATABASE IF EXISTS {new_db};')
    CURSOR.execute(f'CREATE DATABASE {new_db};')
    CURSOR.execute(f'USE {new_db};')
    CURSOR.execute(f'''
        CREATE TABLE {new_db}.{new_table} (
            id VARCHAR(255) NOT NULL PRIMARY KEY,
            title VARCHAR(1024),
            authors VARCHAR(1024),
            average_rating FLOAT(9,2),
            isbn VARCHAR(255),
            isbn13 VARCHAR(255),
            language_code VARCHAR(255),
            num_pages int,
            ratings_count int,
            text_reviews_count int,
            publication_date VARCHAR(255),
            publisher VARCHAR(255)
        );
    ''')
    CONNECT.commit()
    CURSOR.close()
    CONNECT.close()

def load_to_sql(user, password, host, db, table, csv_in):
    CONNECT = mysql.connector.connect(
        host=host,
        user=user,
        password=password,
        database=db
    )
    CURSOR = CONNECT.cursor()
    csv_file = open(csv_in, 'r')
    csv_reader = csv.reader(csv_file)
    next(csv_reader) # skip header
    for row in csv_reader:
        INSERT = f'''
            INSERT INTO {db}.{table}
            VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s);
        '''
        CURSOR.execute(INSERT, row)
    csv_file.close()
    CONNECT.commit()
    CURSOR.close()
    CONNECT.close()

def load_to_mongodb(db, coll, json_in):
    json_file = open(json_in, 'r')
    json_reader = json.load(json_file)
    CLIENT = pymongo.MongoClient()
    CLIENT.drop_database(db)
    for book in json_reader:
        book['average_rating'] = float(book['average_rating'])
        book['ratings_count'] = int(book['ratings_count'])
        book['num_pages'] = int(book['num_pages'])
        book['text_reviews_count'] = int(book['text_reviews_count'])
    CLIENT[db][coll].insert_many(json_reader)
    json_file.close()
