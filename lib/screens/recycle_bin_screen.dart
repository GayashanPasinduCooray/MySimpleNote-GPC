import 'package:flutter/material.dart';

import '../db/note_database.dart'; // Assuming you have a NoteDatabase class for handling database operations

class RecycleBinScreen extends StatefulWidget {
  final Function onNoteRestored; // Callback function for when a note is restored

  const RecycleBinScreen({super.key, required this.onNoteRestored}); // Constructor

  @override
  State<RecycleBinScreen> createState() => _RecycleBinScreenState();
}

class _RecycleBinScreenState extends State<RecycleBinScreen> {
  List<Note> _deletedNotes = []; // List to hold deleted notes

  @override
  void initState() {
    super.initState();
    _loadDeletedNotes(); // Load deleted notes when the widget is initialized
  }

  // Load deleted notes from the database
  Future<void> _loadDeletedNotes() async {
    List<Note> deletedNotesData = await NoteDatabase.instance.readAllDeletedNotes();
    setState(() {
      _deletedNotes = deletedNotesData; // Update the UI with loaded deleted notes
    });
  }

  // Restore a note at the specified index
  Future<void> _restoreNoteAtIndex(int index) async {
    final noteToRestore = _deletedNotes[index];
    await NoteDatabase.instance.create(noteToRestore); // Restore note back to notes
    await NoteDatabase.instance.deletePermanently(noteToRestore.id!); // Delete from deleted notes
    _loadDeletedNotes(); // Refresh deleted notes
    widget.onNoteRestored(); // Call the callback to refresh notes in home page
    Navigator.of(context).pop(); // Close recycle bin screen
  }

  // Permanently delete a note at the specified index
  Future<void> _permanentlyDeleteNoteAtIndex(int index) async {
    final noteToDeletePermanently = _deletedNotes[index];
    await NoteDatabase.instance.deletePermanently(noteToDeletePermanently.id!); // Permanently delete from deleted notes
    _loadDeletedNotes(); // Refresh deleted notes
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Recycle Bin'),
      ),
      body: _deletedNotes.isEmpty
          ? const Center(child: Text('No deleted notes'))
          : ListView.builder(
        itemCount: _deletedNotes.length,
        itemBuilder: (context, index) {
          final note = _deletedNotes[index];
          return ListTile(
            title: Text(note.content), // Display the content of the note
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.restore),
                  onPressed: () => _restoreNoteAtIndex(index), // Restore note
                ),
                IconButton(
                  icon: const Icon(Icons.delete_forever, color: Colors.red),
                  onPressed: () => _permanentlyDeleteNoteAtIndex(index), // Permanently delete note
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}



