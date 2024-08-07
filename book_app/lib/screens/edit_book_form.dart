import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../services/api_service.dart';
import '../models/book_model.dart';

class EditBookForm extends StatefulWidget {
  final Book book;
  final VoidCallback onBookUpdated;

  EditBookForm({required this.book, required this.onBookUpdated});

  @override
  _EditBookFormState createState() => _EditBookFormState();
}

class _EditBookFormState extends State<EditBookForm> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _authorController;
  late TextEditingController _yearController;
  late TextEditingController _publisherController;
  File? _image;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.book.title);
    _authorController = TextEditingController(text: widget.book.author);
    _yearController = TextEditingController(text: widget.book.year.toString());
    _publisherController = TextEditingController(text: widget.book.publisher);
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      final updatedBook = Book(
        id: widget.book.id,
        coverUrl: _image?.path ??
            widget.book.coverUrl, // Use existing cover URL if no new image
        title: _titleController.text,
        author: _authorController.text,
        year: int.parse(_yearController.text),
        publisher: _publisherController.text,
      );

      try {
        await ApiService().updateBook(updatedBook, _image);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Book updated successfully')),
        );
        widget.onBookUpdated(); // Refresh the book list
        Navigator.pop(context); // Go back to the previous screen
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update book')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Book'),
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
              ElevatedButton(
                onPressed: _pickImage,
                child: Text('Pick Image'),
              ),
              SizedBox(height: 20),
              _image != null
                  ? Image.file(_image!, height: 200)
                  : widget.book.coverUrl.isNotEmpty
                      ? Image.network(widget.book.coverUrl, height: 200)
                      : Text('No image selected'),
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
