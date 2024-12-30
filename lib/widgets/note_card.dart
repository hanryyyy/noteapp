import 'package:flutter/material.dart';
import 'package:noteapp/change_notifiers/new_note_controller.dart';
import 'package:noteapp/change_notifiers/notes_provider.dart';
import 'package:noteapp/core/constants.dart';
import 'package:noteapp/core/dialogs.dart';
import 'package:noteapp/core/utlils.dart';
import 'package:noteapp/enums/order_option.dart';
import 'package:noteapp/models/note.dart';
import 'package:noteapp/pages/new_or_edit_note_page.dart';
import 'package:noteapp/widgets/note_color_assigner.dart';
import 'package:noteapp/widgets/note_tag.dart';
import 'package:provider/provider.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class NoteCard extends StatelessWidget {
  final Note note;
  final bool isInGrid;

  NoteCard({required this.note, required this.isInGrid});

  @override
  Widget build(BuildContext context) {
    final Color noteColor = NoteColorAssigner.getColorFromIndex(note.color);

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ChangeNotifierProvider(
              create: (_) => NewNoteController()..note = note,
              child: const NewOrEditNotePage(
                isNewNote: false,
              ),
            ),
          ),
        );
      },
      onLongPress: () {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('Do you want to delete this note?'),
              content: SingleChildScrollView(
                child: ListBody(
                  children: <Widget>[
                    GestureDetector(
                      child: Text('Edit'),
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ChangeNotifierProvider(
                              create: (_) => NewNoteController()..note = note,
                              child: const NewOrEditNotePage(
                                isNewNote: false,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                    Padding(padding: EdgeInsets.all(8.0)),
                    GestureDetector(
                      onTap: () async {
                        final shouldDelete = await showConfirmationDialog(
                                context: context,
                                title: 'Do you want to delete this note?') ??
                            false;

                        if (shouldDelete && context.mounted) {
                          context.read<NotesProvider>().deleteNote(note);
                        }
                        Navigator.pop(context);
                      },
                      child: Row(
                        children: const [
                          Text('Delete'),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: noteColor,
          border: Border.all(
            color: primary,
            width: 2,
          ),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: primary.withOpacity(0.5),
              offset: const Offset(4, 4),
            ),
          ],
        ),
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (note.title != null) ...[
              Text(
                note.title!,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: gray900,
                ),
              ),
              const SizedBox(height: 4),
            ],
            if (note.tags != null) ...[
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: List.generate(
                    note.tags!.length,
                    (index) => NoteTag(label: note.tags![index]),
                  ),
                ),
              ),
              const SizedBox(height: 4),
            ],
            if (note.content != null)
              isInGrid
                  ? Expanded(
                      child: Text(
                        note.content!,
                        style: const TextStyle(color: gray700),
                      ),
                    )
                  : Text(
                      note.content!,
                      style: const TextStyle(color: gray700),
                    ),
            if (isInGrid) const Spacer(),
            Row(
              children: [
                Selector<NotesProvider, OrderOption>(
                  selector: (_, notesProvider) => notesProvider.orderBy,
                  builder: (_, orderBy, __) => Text(
                    toShortDate(orderBy == OrderOption.dateModified
                        ? note.dateModified
                        : note.dateCreated),
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: gray500,
                    ),
                  ),
                ),
                const Spacer(),
                GestureDetector(
                  onTap: () async {
                    final shouldDelete = await showConfirmationDialog(
                            context: context,
                            title: 'Do you want to delete this note?') ??
                        false;

                    if (shouldDelete && context.mounted) {
                      context.read<NotesProvider>().deleteNote(note);
                    }
                  },
                  child: const FaIcon(
                    FontAwesomeIcons.trash,
                    color: gray500,
                    size: 16,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
