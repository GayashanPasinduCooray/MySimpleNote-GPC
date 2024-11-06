import 'package:flutter/material.dart';

class EditNoteScreen extends StatelessWidget {
  final String currentNote;
  final Function(String) onSave; // Callback to save the edited note
  final int index; // Index of the note being edited

  const EditNoteScreen({
    Key? key,
    required this.currentNote,
    required this.onSave,
    required this.index,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final _noteController = TextEditingController(text: currentNote); // Set the current note in the controller

    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Note'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: () {
              if (_noteController.text.isNotEmpty) {
                onSave(_noteController.text); // Call onSave callback
                Navigator.of(context).pop(); // Close the screen
              }
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: TextField(
          controller: _noteController,
          decoration: const InputDecoration(hintText: 'Edit your note here'),
          maxLines: null, // Allow multiple lines
        ),
      ),
    );
  }
}

