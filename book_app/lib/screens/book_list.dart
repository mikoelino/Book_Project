import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/book_model.dart';
import '../screens/edit_book_form.dart';
import '../screens/add_book_form.dart';

class BookListScreen extends StatefulWidget {
  @override
  _BookListScreenState createState() => _BookListScreenState();
}

class _BookListScreenState extends State<BookListScreen> {
  late Future<List<Book>> futureBooks;

  @override
  void initState() {
    super.initState();
    futureBooks = ApiService().fetchBooks();
  }

  void _refreshBooks() {
    setState(() {
      futureBooks = ApiService().fetchBooks();
    });
  }

  Future<void> _deleteBook(int id) async {
    try {
      await ApiService().deleteBook(id);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Book deleted successfully')),
      );
      _refreshBooks(); // Refresh the book list
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to delete book: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Book List'),
      ),
      body: FutureBuilder<List<Book>>(
        future: futureBooks,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No books available'));
          } else {
            final books = snapshot.data!;
            return ListView.builder(
              padding: EdgeInsets.all(8.0),
              itemCount: books.length,
              itemBuilder: (context, index) {
                final book = books[index];
                return Card(
                  margin: EdgeInsets.symmetric(vertical: 8.0),
                  elevation: 5,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Header image
                      book.coverUrl.isNotEmpty
                          ? Image.network(book.coverUrl,
                              height: 200, fit: BoxFit.cover)
                          : Container(
                              height: 200,
                              color: Colors.grey[200],
                              child: Center(
                                child: Icon(Icons.image,
                                    color: Colors.white, size: 50),
                              ),
                            ),
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(book.title,
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 18)),
                            SizedBox(height: 8),
                            Text('${book.author}, ${book.year}',
                                style: TextStyle(color: Colors.grey[600])),
                            SizedBox(height: 8),
                            Text(book.publisher),
                          ],
                        ),
                      ),
                      ButtonBar(
                        children: [
                          TextButton(
                            onPressed: () => _deleteBook(book.id),
                            child: Text('Delete'),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => EditBookForm(
                                    book: book,
                                    onBookUpdated: _refreshBooks,
                                  ),
                                ),
                              );
                            },
                            child: Text('Edit'),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            );
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AddBookForm(
                onBookAdded: _refreshBooks,
              ),
            ),
          );
        },
        child: Icon(Icons.add),
        tooltip: 'Add Book',
      ),
    );
  }
}
