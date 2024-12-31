import 'package:flutter/material.dart';
import 'package:noteapp/models/note.dart';
import 'package:noteapp/widgets/note_grid.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../change_notifiers/notes_provider.dart';
import '../change_notifiers/new_note_controller.dart';
import '../widgets/note_fab.dart';
import '../widgets/tag_filter_dialog.dart';
import 'new_or_edit_note_page.dart';
import '../widgets/no_notes.dart';
import '../widgets/search_field.dart';
import '../widgets/view_options.dart';

import '../widgets/notes_list.dart';

class MainPage extends StatefulWidget {
  const MainPage({Key? key}) : super(key: key);

  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _selectedIndex = 0;

  void _onItemTapped(int index) async {
    setState(() {
      _selectedIndex = index;
    });

    if (index == 1) {
      final notesProvider = context.read<NotesProvider>();
      final selectedTags = await showDialog<List<String>>(
        context: context,
        builder: (context) => TagFilterDialog(
          selectedTags: notesProvider.selectedTags,
        ),
      );

      if (selectedTags != null) {
        notesProvider.filterByTags(selectedTags);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final notesProvider = context.watch<NotesProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Awesome Notes'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              Navigator.pushReplacementNamed(context, '/login');
            },
          ),
        ],
      ),
      body: _buildBody(context, notesProvider),
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
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.update),
            label: 'Modified',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.filter_list),
            label: 'Filter',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
            label: 'Search',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.amber[800],
        onTap: _onItemTapped,
      ),
    );
  }

  Widget _buildBody(BuildContext context, NotesProvider notesProvider) {
    switch (_selectedIndex) {
      case 0:
        return _buildModifiedView(notesProvider);
      case 1:
        return _buildFilterView(context, notesProvider);
      case 2:
        return _buildSearchView(notesProvider);
      default:
        return _buildModifiedView(notesProvider);
    }
  }

  Widget _buildModifiedView(NotesProvider notesProvider) {
    final List<Note> notes = notesProvider.notes;
    return notes.isEmpty && notesProvider.searchTerm.isEmpty
        ? const NoNotes()
        : Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              children: [
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
                        'No notes available!',
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
              ],
            ),
          );
  }

  Widget _buildFilterView(BuildContext context, NotesProvider notesProvider) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ElevatedButton(
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
            child: const Text('Filter Notes by Tags'),
          ),
          const SizedBox(height: 16.0),
          if (notesProvider.selectedTags.isNotEmpty)
            Wrap(
              spacing: 8.0,
              children: notesProvider.selectedTags
                  .map((tag) => Chip(
                        label: Text(tag),
                        onDeleted: () {
                          notesProvider.filterByTags(
                            notesProvider.selectedTags
                                .where((t) => t != tag)
                                .toList(),
                          );
                        },
                      ))
                  .toList(),
            ),
          const SizedBox(height: 16.0),
          Expanded(
            child: notesProvider.notes.isEmpty
                ? const Center(child: Text('No notes available!'))
                : notesProvider.isGrid
                    ? NotesGrid(notes: notesProvider.notes)
                    : NotesList(notes: notesProvider.notes),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchView(NotesProvider notesProvider) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        children: [
          const SearchField(),
          if (notesProvider.notes.isNotEmpty) ...[
            const ViewOptions(),
            Expanded(
              child: notesProvider.isGrid
                  ? NotesGrid(notes: notesProvider.notes)
                  : NotesList(notes: notesProvider.notes),
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
  }
}
