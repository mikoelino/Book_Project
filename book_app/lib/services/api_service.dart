import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../models/book_model.dart';
import '../models/member_model.dart';

class ApiService {
  final String baseUrl =
      'http://192.168.1.20:5000'; // Ganti dengan IP atau domain server Flask Anda

  Future<List<Book>> fetchBooks() async {
    final response = await http.get(Uri.parse('$baseUrl/books'));

    if (response.statusCode == 200) {
      List<dynamic> json = jsonDecode(response.body);
      return json.map((e) => Book.fromJson(e)).toList();
    } else {
      throw Exception('Failed to load books');
    }
  }

  Future<List<Member>> fetchMembers() async {
    final response = await http.get(Uri.parse('$baseUrl/members'));

    if (response.statusCode == 200) {
      List<dynamic> json = jsonDecode(response.body);
      return json.map((e) => Member.fromJson(e)).toList();
    } else {
      throw Exception('Failed to load members');
    }
  }

  Future<void> addBook(Book book, File? image) async {
    final request = http.MultipartRequest('POST', Uri.parse('$baseUrl/books'));
    request.fields['title'] = book.title;
    request.fields['author'] = book.author;
    request.fields['year'] = book.year.toString();
    request.fields['publisher'] = book.publisher;

    if (image != null) {
      request.files.add(await http.MultipartFile.fromPath('cover', image.path));
    }

    final response = await request.send();

    if (response.statusCode != 201) {
      throw Exception('Failed to add book');
    }
  }

  Future<void> deleteBook(int id) async {
    final response = await http.delete(Uri.parse('$baseUrl/books/$id'));

    if (response.statusCode != 200) {
      throw Exception('Failed to delete book');
    }
  }

  Future<void> updateBook(Book book, File? image) async {
    var request =
        http.MultipartRequest('PUT', Uri.parse('$baseUrl/books/${book.id}'));

    request.fields['title'] = book.title;
    request.fields['author'] = book.author;
    request.fields['year'] = book.year.toString();
    request.fields['publisher'] = book.publisher;

    if (image != null) {
      request.files.add(await http.MultipartFile.fromPath('cover', image.path));
    }

    var response = await request.send();
    if (response.statusCode != 200) {
      throw Exception('Failed to update book');
    }
  }
}
