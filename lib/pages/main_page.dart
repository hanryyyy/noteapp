import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:noteapp/change_notifiers/new_note_controller.dart';
import 'package:noteapp/change_notifiers/notes_provider.dart';
import 'package:noteapp/pages/new_or_edit_note_page.dart';
import 'package:noteapp/widgets/view_options.dart';
import 'package:provider/provider.dart';

import '../models/note.dart';
import '../widgets/no_notes.dart';
import '../widgets/note_fab.dart';
import '../widgets/note_grid.dart';
import '../widgets/note_icon_button_outlined.dart';
import '../widgets/notes_list.dart';
import '../widgets/search_field.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Awesome Notes 📒'),
        actions: [
          NoteIconButtonOutlined(
            icon: FontAwesomeIcons.rightFromBracket,
            onPressed: () {},
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
                              'No notes found for your search query!',
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
