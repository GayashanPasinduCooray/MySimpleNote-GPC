// note.dart
class Note {
  final int? id;
  final String content;

  // Constructor
  Note({
    this.id,
    required this.content,
  });

  // Convert a Note object into a Map for database storage
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'content': content,
    };
  }

  // Factory constructor to create a Note object from a map
  factory Note.fromMap(Map<String, dynamic> map) {
    return Note(
      id: map['id'],
      content: map['content'],
    );
  }

  // Optional: A method to return the note's content as a string
  @override
  String toString() {
    return 'Note{id: $id, content: $content}';
  }
}
