import 'package:flutter/material.dart';
import '../db/note_database.dart'; // Assuming you have a NoteDatabase class for handling database operations

class NoteDetailScreen extends StatefulWidget {
  final Note note;

  const NoteDetailScreen({Key? key, required this.note}) : super(key: key);

  @override
  _NoteDetailScreenState createState() => _NoteDetailScreenState();
}

class _NoteDetailScreenState extends State<NoteDetailScreen> {
  final TextEditingController _noteController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _noteController.text = widget.note.content; // Pre-fill the note content
  }

  Future<void> _updateNote() async {
    if (_noteController.text.isNotEmpty) {
      final updatedNote = Note(
        id: widget.note.id,
        content: _noteController.text,
      );
      await NoteDatabase.instance.update(updatedNote); // Update note in database
      Navigator.of(context).pop(true); // Return true to refresh the notes
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('View Note'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _updateNote, // Save updates
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: TextField(
          controller: _noteController,
          decoration: const InputDecoration(
            hintText: 'Enter your note',
            border: OutlineInputBorder(),
          ),
          maxLines: null,
        ),
      ),
    );
  }
}
