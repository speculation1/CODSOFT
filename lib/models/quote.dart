class Quote {
  final String text;
  final String author;
  late final String imageUrl;

  Quote({required this.text, required this.author, required this.imageUrl});

  Quote copyWith({String? text, String? author, String? imageUrl}) {
    return Quote(
      text: text ?? this.text,
      author: author ?? this.author,
      imageUrl: imageUrl ?? this.imageUrl,
    );
  }
}
