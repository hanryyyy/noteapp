import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:noteapp/change_notifiers/notes_provider.dart';

import 'package:noteapp/models/note.dart';
import 'package:noteapp/widgets/no_notes.dart';
import 'package:noteapp/widgets/note_grid.dart';
import 'package:noteapp/widgets/notes_list.dart';
import 'package:noteapp/widgets/search_field.dart';
import 'package:noteapp/widgets/view_options.dart';
import 'package:provider/provider.dart';

import '../change_notifiers/new_note_controller.dart';
import '../widgets/note_fab.dart';
import '../widgets/tag_filter_dialog.dart';
import 'new_or_edit_note_page.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  @override
  Widget build(BuildContext context) {
    final notesProvider = context.watch<NotesProvider>();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Awesome Notes'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () async {
              final selectedTags = await showDialog<List<String>>(
                context: context,
                builder: (context) => TagFilterDialog(
                  selectedTags: notesProvider.selectedTags,
                ),
              );

              if (selectedTags != null) {
                notesProvider.filterByTags(selectedTags);
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              Navigator.pushReplacementNamed(context, '/login');
            },
          ),
        ],
      ),
      floatingActionButton: NoteFab(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ChangeNotifierProvider(
                create: (context) => NewNoteController(),
                child: const NewOrEditNotePage(
                  isNewNote: true,
                ),
              ),
            ),
          );
        },
      ),
      body: Consumer<NotesProvider>(
        builder: (context, notesProvider, child) {
          final List<Note> notes = notesProvider.notes;
          return notes.isEmpty && notesProvider.searchTerm.isEmpty
              ? const NoNotes()
              : Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Column(
                    children: [
                      const SearchField(),
                      if (notes.isNotEmpty) ...[
                        const ViewOptions(),
                        Expanded(
                          child: notesProvider.isGrid
                              ? NotesGrid(notes: notes)
                              : NotesList(notes: notes),
                        ),
                      ] else
                        const Expanded(
                          child: Center(
                            child: Text(
                              'Keyword not found!',
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                    ],
                  ),
                );
        },
      ),
    );
  }
}
