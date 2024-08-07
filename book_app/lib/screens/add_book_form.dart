import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../services/api_service.dart';
import '../models/book_model.dart';

class AddBookForm extends StatefulWidget {
  final VoidCallback onBookAdded;

  AddBookForm({required this.onBookAdded});

  @override
  _AddBookFormState createState() => _AddBookFormState();
}

class _AddBookFormState extends State<AddBookForm> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _authorController = TextEditingController();
  final _yearController = TextEditingController();
  final _publisherController = TextEditingController();
  File? _image;

  Future<void> _getImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path); // Menggunakan File secara langsung
      });
    }
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      final book = Book(
        id: 0,
        coverUrl: '',
        title: _titleController.text,
        author: _authorController.text,
        year: int.parse(_yearController.text),
        publisher: _publisherController.text,
      );

      try {
        await ApiService()
            .addBook(book, _image); // Mengirim gambar dan data buku
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Book added successfully')),
        );
        widget.onBookAdded(); // Refresh the book list
        Navigator.pop(context); // Go back to the previous screen
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to add book: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add New Book'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: <Widget>[
              TextFormField(
                controller: _titleController,
                decoration: InputDecoration(labelText: 'Title'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a title';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _authorController,
                decoration: InputDecoration(labelText: 'Author'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter an author';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _yearController,
                decoration: InputDecoration(labelText: 'Year'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a year';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _publisherController,
                decoration: InputDecoration(labelText: 'Publisher'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a publisher';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),
              _image != null
                  ? Image.file(File(_image!.path))
                  : Text('No image selected'),
              ElevatedButton(
                onPressed: _getImage,
                child: Text('Pick Image'),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _submitForm,
                child: Text('Submit'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
