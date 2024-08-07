class Book {
  final int id;
  final String coverUrl;
  final String title;
  final String author;
  final int year;
  final String publisher;

  Book({
    required this.id,
    required this.coverUrl,
    required this.title,
    required this.author,
    required this.year,
    required this.publisher,
  });

  factory Book.fromJson(Map<String, dynamic> json) {
    return Book(
      id: json['id'],
      coverUrl: json['cover_url'],
      title: json['title'],
      author: json['author'],
      year: json['year'],
      publisher: json['publisher'],
    );
  }
}
