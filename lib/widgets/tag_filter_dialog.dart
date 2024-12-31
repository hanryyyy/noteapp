import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../change_notifiers/notes_provider.dart';

class TagFilterDialog extends StatefulWidget {
  final List<String> selectedTags;

  const TagFilterDialog({Key? key, required this.selectedTags})
      : super(key: key);

  @override
  _TagFilterDialogState createState() => _TagFilterDialogState();
}

class _TagFilterDialogState extends State<TagFilterDialog> {
  late List<String> _selectedTags;

  @override
  void initState() {
    super.initState();
    _selectedTags = List.from(widget.selectedTags);
  }

  @override
  Widget build(BuildContext context) {
    final notesProvider = context.watch<NotesProvider>();
    final allTags =
        notesProvider.notes.expand((note) => note.tags ?? []).toSet().toList();

    return AlertDialog(
      title: const Text('Filter by Tags'),
      content: SingleChildScrollView(
        child: Column(
          children: allTags.map((tag) {
            return CheckboxListTile(
              title: Text(tag),
              value: _selectedTags.contains(tag),
              onChanged: (bool? value) {
                setState(() {
                  if (value == true) {
                    _selectedTags.add(tag);
                  } else {
                    _selectedTags.remove(tag);
                  }
                });
              },
            );
          }).toList(),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () {
            Navigator.of(context).pop(_selectedTags);
          },
          child: const Text('Apply'),
        ),
      ],
    );
  }
}
