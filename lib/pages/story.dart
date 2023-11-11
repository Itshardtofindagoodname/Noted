class Story {
  final String id;
  String title;
  final List<String> sentences;

  Story({required this.id, required this.title, required this.sentences});

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'sentences': sentences,
    };
  }

  factory Story.fromMap(Map<String, dynamic> map) {
    return Story(
      id: map['id'],
      title: map['title'],
      sentences: List<String>.from(map['sentences']),
    );
  }
}
