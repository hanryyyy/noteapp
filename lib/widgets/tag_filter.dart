import '../models/note.dart';

class TagFilter {
  List<Note> filterByTags(List<Note> notes, List<String> tags) {
    if (tags.isEmpty) {
      return notes;
    } else {
      return notes.where((note) {
        return note.tags != null && note.tags!.any((tag) => tags.contains(tag));
      }).toList();
    }
  }
}
