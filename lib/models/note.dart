class Note {
  Note({
    this.noteId,
    required this.userId,
    required this.title,
    required this.content,
    required this.contentJson,
    required this.dateCreated,
    required this.dateModified,
    required this.tags,
  });

  String? noteId;
  final String userId;
  final String? title;
  final String? content;
  final String contentJson;
  final int dateCreated;
  final int dateModified;
  final List<String>? tags;

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'title': title,
      'content': content,
      'contentJson': contentJson,
      'dateCreated': dateCreated,
      'dateModified': dateModified,
      'tags': tags != null ? tags!.join(',') : null,
    };
  }

  factory Note.fromMap(Map<String, dynamic> map, String documentId) {
    return Note(
      noteId: documentId,
      userId: map['userId'],
      title: map['title'],
      content: map['content'],
      contentJson: map['contentJson'],
      dateCreated: map['dateCreated'],
      dateModified: map['dateModified'],
      tags: map['tags'] != null ? (map['tags'] as String).split(',') : null,
    );
  }
}
