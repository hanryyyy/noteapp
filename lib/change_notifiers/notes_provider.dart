import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:noteapp/widgets/tag_filter.dart';

import '../enums/order_option.dart';
import '../models/note.dart';

class NotesProvider with ChangeNotifier {
  List<Note> _notes = [];
  List<Note> _filteredNotes = [];
  List<String> _selectedTags = [];
  final TagFilter _tagFilter = TagFilter();

  List<Note> get notes {
    final filteredNotes = _searchTerm.isEmpty
        ? _filteredNotes.isNotEmpty
            ? _filteredNotes
            : _notes
        : (_filteredNotes.isNotEmpty ? _filteredNotes : _notes).where((note) {
            final title = note.title?.toLowerCase() ?? '';
            final content = note.content?.toLowerCase() ?? '';
            final searchTerm = _searchTerm.toLowerCase();
            return title.contains(searchTerm) || content.contains(searchTerm);
          }).toList();

    filteredNotes.sort(_compare);
    return filteredNotes;
  }

  Future<void> fetchNotes() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      // Handle the case where the user is not authenticated
      return;
    }

    final firestore = FirebaseFirestore.instance;
    final querySnapshot = await firestore
        .collection('notes')
        .where('userId', isEqualTo: user.uid)
        .get();

    _notes = querySnapshot.docs
        .map((doc) => Note.fromMap(doc.data() as Map<String, dynamic>, doc.id))
        .toList();

    notifyListeners();
  }

  int _compare(Note note1, note2) {
    return _orderBy == OrderOption.dateModified
        ? _isDescending
            ? note2.dateModified.compareTo(note1.dateModified)
            : note1.dateModified.compareTo(note2.dateModified)
        : _isDescending
            ? note2.dateCreated.compareTo(note1.dateCreated)
            : note1.dateCreated.compareTo(note2.dateCreated);
  }

  void addNote(Note note) {
    _notes.add(note);
    notifyListeners();
  }

  void updateNote(Note note) {
    final index = _notes.indexWhere((n) => n.noteId == note.noteId);
    if (index != -1) {
      _notes[index] = note;
      notifyListeners();
    }
  }

  Future<void> deleteNote(Note note) async {
    final firestore = FirebaseFirestore.instance;
    await firestore.collection('notes').doc(note.noteId).delete();
    _notes.removeWhere((n) => n.noteId == note.noteId);
    notifyListeners();
  }

  void filterByTags(List<String> tags) {
    _selectedTags = tags;
    _filteredNotes = _tagFilter.filterByTags(_notes, tags);
    notifyListeners();
  }

  List<String> get selectedTags => _selectedTags;

  OrderOption _orderBy = OrderOption.dateModified;
  set orderBy(OrderOption value) {
    _orderBy = value;
    notifyListeners();
  }

  OrderOption get orderBy => _orderBy;

  bool _isDescending = true;
  set isDescending(bool value) {
    _isDescending = value;
    notifyListeners();
  }

  bool get isDescending => _isDescending;

  bool _isGrid = true;
  set isGrid(bool value) {
    _isGrid = value;
    notifyListeners();
  }

  bool get isGrid => _isGrid;

  String _searchTerm = '';
  set searchTerm(String value) {
    _searchTerm = value;
    notifyListeners();
  }

  String get searchTerm => _searchTerm;
}
