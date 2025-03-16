class LessonNote {
  final String? id;
  final String title;
  final String content;
  final String authorId;
  final String authorName;
  final DateTime createdAt;
  final List<String> tags;
  final bool isPublic;

  LessonNote({
    this.id,
    required this.title,
    required this.content,
    required this.authorId,
    required this.authorName,
    DateTime? createdAt,
    this.tags = const [],
    this.isPublic = false,
  }) : this.createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'authorId': authorId,
      'authorName': authorName,
      'createdAt': createdAt.toIso8601String(),
      'tags': tags,
      'isPublic': isPublic,
    };
  }

  factory LessonNote.fromJson(Map<String, dynamic> json) {
    return LessonNote(
      id: json['id'],
      title: json['title'],
      content: json['content'],
      authorId: json['authorId'],
      authorName: json['authorName'],
      createdAt: DateTime.parse(json['createdAt']),
      tags: List<String>.from(json['tags'] ?? []),
      isPublic: json['isPublic'] ?? false,
    );
  }
}