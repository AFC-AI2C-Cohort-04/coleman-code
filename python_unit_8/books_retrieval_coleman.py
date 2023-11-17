
import csv, json, mysql, pymongo
import xml.etree.ElementTree as ET

def retrieve_popular_books(csv_in, json_out):

    # read csv_in to data and parse into dictionary
    data = {}
    with open(csv_in, 'r') as csv_file:
        csv_reader = csv.DictReader(csv_file)
        for book in csv_reader:
            if float(book['average_rating']) > 4.5 and int(book['num_pages']) > 50 and int(book['ratings_count']) > 1000:
                data[book['bookID']] = {}
                data[book['bookID']]['info'] = {}
                for key in book:
                    if key not in ['bookID', 'average_rating', 'ratings_count', 'text_reviews_count']:
                        if key == 'num_pages': data[book['bookID']]['info'][key] = int(book[key])
                        else: data[book['bookID']]['info'][key] = book[key]
                data[book['bookID']]['rating'] = {}
                for key in book:
                    if key in ['average_rating', 'ratings_count', 'text_reviews_count']:
                        if key == 'average_rating': data[book['bookID']]['rating'][key] = float(book[key])
                        else: data[book['bookID']]['rating'][key] = int(book[key])

    # write data to json_out
    with open(json_out, 'w') as json_file:
        json_file.write('{\n')
        json_str = ''
        for book in data:
            json_str += f'    "{book}": ' + '{\n        "info": {\n'
            info_str = ''
            for key in data[book]['info']:
                info_str += f'            "{key}": '
                if isinstance(data[book]['info'][key], type(str())): info_str += f'"{data[book]["info"][key]}",\n'
                else: info_str += str(data[book]['info'][key]) + ',\n'
            json_str += info_str[:-2] + '\n        },\n        "rating": {\n'
            rating_str = ''
            for key in data[book]['rating']:
                rating_str += f'            "{key}": {str(data[book]["rating"][key])},\n'
            json_str += rating_str[:-2] + '\n        }\n    },\n'
        json_file.write(json_str[:-2] + '\n}')




def retrieve_boring_books(json_in, xml_out):

    # read json_in to data and parse into dictionary
    data = {}
    with open(json_in, 'r') as json_file:
        json_reader = json.load(json_file)
        for book in json_reader:
            if float(book['average_rating']) < 3.0 and int(book['num_pages']) > 300 and int(book['ratings_count']) > 100:
                data[book['bookID']] = {}
                data[book['bookID']]['info'] = {}
                for key in book:
                    if key not in ['bookID', 'average_rating', 'ratings_count', 'text_reviews_count']:
                        if key == 'num_pages': data[book['bookID']]['info'][key] = int(book[key])
                        else: data[book['bookID']]['info'][key] = book[key]
                data[book['bookID']]['rating'] = {}
                for key in book:
                    if key in ['average_rating', 'ratings_count', 'text_reviews_count']:
                        if key == 'average_rating': data[book['bookID']]['rating'][key] = float(book[key])
                        else: data[book['bookID']]['rating'][key] = int(book[key])

    # write data to json_out
    with open(xml_out, 'w') as xml_file:
        xml_file.write('<books>\n')
        for book in data:
            xml_file.write(f'    <book id="{book}">\n        <info>\n')
            for key in data[book]['info']:
                xml_file.write(f'            <{key}>{str(data[book]["info"][key])}</{key}>\n')
            xml_file.write('        </info>\n        <rating>\n')
            for key in data[book]['rating']:
                xml_file.write(f'            <{key}>{str(data[book]["rating"][key])}</{key}>\n')
            xml_file.write('        </rating>\n    </book>\n')
        xml_file.write('</books>')




def retrieve_wildly_popular_books(xml_in, csv_out):

    # read xml_in to data and parse into dictionary
    data = []
    with open(xml_in, 'r') as xml_file:
        tree = ET.parse(xml_file)
        root = tree.getroot()
        for book in root:
            book_obj = {}
            for child in book:
                book_obj[child.tag] = child.text
            if float(book_obj['average_rating']) > 4.0 and int(book_obj['ratings_count']) > 1000000:
                book_obj['average_rating'] = float(book_obj['average_rating'])
                for key in ['num_pages', 'ratings_count', 'text_reviews_count']: book_obj[key] = int(book_obj[key])
                data += [book_obj]

    # write data to json_out
    with open(csv_out, 'w') as csv_file:
        csv_str = 'book_id,'
        for i, key in enumerate(data[0]):
            if i != 0: csv_str += f'{key},'
        csv_file.write(f'{csv_str[:-1]}\n')
        for book in data:
            book_str = ''
            for key in book:
                book_str += f'{book[key]},'
            csv_file.write(f'{book_str[:-1]}\n')

def retrieve_long_books(user, password, host, db, table, csv_out):
    CONNECT = mysql.connector.connect(
        host=host,
        user=user,
        password=password,
        database=db
    )
    CURSOR = CONNECT.cursor()
    CURSOR.execute(f'SELECT * FROM {table} WHERE num_pages > 2000')
    csv_file = open(csv_out, 'w')
    csv_file.write('book_id,title,authors,average_rating,isbn,isbn13,language_code,num_pages,ratings_count,text_reviews_count,publication_date,publisher')
    for row in CURSOR.fetchall():
        line_str = ''
        for item in row: line_str += f',{str(item)}'
        csv_file.write(f'\n{line_str[1:]}')
    csv_file.close()
    CONNECT.commit()
    CURSOR.close()
    CONNECT.close()

def retrieve_obscure_books(db, coll, json_out):
    CLIENT = pymongo.MongoClient()
    data = list((CLIENT[db][coll]).find({"ratings_count": 1}))
    json_file = open(json_out, 'w')
    json_file.write('{\n')
    json_str = ''
    for book in data:
        json_str += f'  "{book["bookID"]}": ' + '{\n    "info": {\n'
        info_str = ''
        book['title'] = '\\"'.join(book['title'].split('"'))
        for key in book:
            if key not in ['_id', 'bookID', 'average_rating', 'ratings_count', 'text_reviews_count']:
                info_str += f'      "{key}": '
                if isinstance(book[key], type(str())): info_str += f'"{book[key]}",\n'
                else: info_str += str(book[key]) + ',\n'
        json_str += info_str[:-2] + '\n    },\n    "rating": {\n'
        rating_str = ''
        for key in book:
            if key in ['average_rating', 'ratings_count', 'text_reviews_count']:
                rating_str += f'      "{key}": {str(book[key])},\n'
        json_str += rating_str[:-2] + '\n    }\n  },\n'
    json_file.write(json_str[:-2] + '\n}')
    json_file.close()
