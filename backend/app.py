from flask import Flask, jsonify, send_from_directory, request
import os
from werkzeug.utils import secure_filename
import pymysql
import uuid

app = Flask(__name__)

conn = pymysql.connect(
    host='127.0.0.1',
    user='root',
    password='root',
    database='rn_library',
    cursorclass=pymysql.cursors.DictCursor
)

UPLOAD_FOLDER = 'static/images'
app.config['UPLOAD_FOLDER'] = UPLOAD_FOLDER
app.config['MAX_CONTENT_LENGTH'] = 16 * 1024 * 1024
if not os.path.exists(UPLOAD_FOLDER):
    os.makedirs(UPLOAD_FOLDER)

@app.route('/books', methods=['GET'])
def get_books():
    with conn.cursor() as cursor:
        cursor.execute('SELECT * FROM book')
        books = cursor.fetchall()
        
        for book in books:
            if book['cover_url']:
                book['cover_url'] = f'{request.host_url}images/{os.path.basename(book["cover_url"])}'
            else:
                book['cover_url'] = None  

        return jsonify(books)

@app.route('/images/<filename>', methods=['GET'])
def get_image(filename):
    return send_from_directory(app.config['UPLOAD_FOLDER'], filename)

@app.route('/books', methods=['POST'])
def add_book():
    data = request.form
    title = data.get('title')
    author = data.get('author')
    year = data.get('year')
    publisher = data.get('publisher')
    cover = request.files.get('cover')
    cover_url = ''

    if cover:
        extension = os.path.splitext(cover.filename)[1]
        random_filename = f"{uuid.uuid4()}{extension}"
        cover_filename = os.path.join(app.config['UPLOAD_FOLDER'], secure_filename(random_filename))
        cover.save(cover_filename)
        cover_url = f'{random_filename}'

    with conn.cursor() as cursor:
        cursor.execute(
            'INSERT INTO book (title, author, year, publisher, cover_url) VALUES (%s, %s, %s, %s, %s)',
            (title, author, year, publisher, cover_url)
        )
        conn.commit()
        new_book_id = cursor.lastrowid

    return jsonify({'id': new_book_id, 'title': title, 'author': author, 'year': year, 'publisher': publisher, 'coverUrl': cover_url}), 201

@app.route('/uploads/<filename>')
def uploaded_file(filename):
    return send_from_directory(app.config['UPLOAD_FOLDER'], filename)

@app.route('/books/<int:book_id>', methods=['DELETE'])
def delete_book(book_id):
    try:
        with conn.cursor() as cursor:
            cursor.execute("SELECT * FROM book WHERE id = %s", (book_id,))
            book = cursor.fetchone()
            if not book:
                return jsonify({'message': 'Book not found'}), 404

            cursor.execute("DELETE FROM book WHERE id = %s", (book_id,))
            conn.commit()
            if book['cover_url']:
                os.remove(os.path.join(app.config['UPLOAD_FOLDER'], os.path.basename(book['cover_url'])))

            return jsonify({'message': 'Book deleted successfully'}), 200
    except Exception as e:
        return jsonify({'error': str(e)}), 500

@app.route('/books/<int:book_id>', methods=['PUT'])
def update_book(book_id):
    data = request.form
    file = request.files.get('cover')

    try:
        with conn.cursor() as cursor:
            cursor.execute("SELECT * FROM book WHERE id = %s", (book_id,))
            book = cursor.fetchone()
            if not book:
                return jsonify({'error': 'Book not found'}), 404

            update_fields = {
                'title': data['title'],
                'author': data['author'],
                'year': int(data['year']),
                'publisher': data['publisher']
            }

            if file:
                extension = os.path.splitext(file.filename)[1]
                random_filename = f"{uuid.uuid4()}{extension}"
                filepath = os.path.join(app.config['UPLOAD_FOLDER'], secure_filename(random_filename))
                file.save(filepath)
                update_fields['cover_url'] = f'{random_filename}'
                if book['cover_url']:
                    os.remove(os.path.join(app.config['UPLOAD_FOLDER'], os.path.basename(book['cover_url'])))

            update_query = "UPDATE book SET title = %(title)s, author = %(author)s, year = %(year)s, publisher = %(publisher)s"
            if file:
                update_query += ", cover_url = %(cover_url)s"
            update_query += " WHERE id = %(book_id)s"

            update_fields['book_id'] = book_id
            cursor.execute(update_query, update_fields)
            conn.commit()

        return jsonify({'message': 'Book updated successfully'}), 200
    except Exception as e:
        return jsonify({'error': str(e)}), 500

@app.route('/members', methods=['GET', 'POST'])
def manage_members():
    if request.method == 'GET':
        with conn.cursor() as cursor:
            cursor.execute('SELECT * FROM member')
            members = cursor.fetchall()
            return jsonify(members)

    if request.method == 'POST':
        data = request.json
        name = data.get('name')
        email = data.get('email')
        phone = data.get('phone')
        address = data.get('address')

        with conn.cursor() as cursor:
            cursor.execute(
                'INSERT INTO member (name, email, phone, address) VALUES (%s, %s, %s, %s)',
                (name, email, phone, address)
            )
            conn.commit()
            new_member_id = cursor.lastrowid
        return jsonify({'id': new_member_id, 'name': name, 'email': email, 'phone': phone, 'address': address}), 201

@app.route('/members/<int:member_id>', methods=['DELETE'])
def delete_member(member_id):
    try:
        with conn.cursor() as cursor:
            sql = "SELECT * FROM member WHERE id = %s"
            cursor.execute(sql, (member_id,))
            member = cursor.fetchone()
            if not member:
                return jsonify({'message': 'Member not found'}), 404

            sql = "DELETE FROM member WHERE id = %s"
            cursor.execute(sql, (member_id,))
            conn.commit()
            return jsonify({'message': 'Member deleted successfully'}), 200
    except Exception as e:
        return jsonify({'error': str(e)}), 500

@app.route('/members/<int:member_id>', methods=['PUT'])
def update_member(member_id):
    data = request.json

    try:
        with conn.cursor() as cursor:
            cursor.execute("SELECT * FROM member WHERE id = %s", (member_id,))
            member = cursor.fetchone()
            if not member:
                return jsonify({'error': 'Member not found'}), 404

            update_fields = {
                'name': data['name'],
                'email': data['email'],
                'phone': data['phone'],
                'address': data['address']
            }

            update_query = "UPDATE member SET name = %(name)s, email = %(email)s, phone = %(phone)s, address = %(address)s WHERE id = %(member_id)s"
            update_fields['member_id'] = member_id
            cursor.execute(update_query, update_fields)
            conn.commit()

        return jsonify({'message': 'Member updated successfully'}), 200
    except Exception as e:
        return jsonify({'error': str(e)}), 500

if __name__ == '__main__':
    app.run(debug=True)
