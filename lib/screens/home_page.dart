import 'package:flutter/material.dart';
import '../db/note_database.dart'; // Assuming you have a NoteDatabase class for handling database operations
import 'note_detail_screen.dart'; // Import the NoteDetailScreen
import 'recycle_bin_screen.dart'; // Import the RecycleBinScreen

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> with SingleTickerProviderStateMixin {
  List<Note> _notes = []; // List to hold notes
  final _noteController = TextEditingController();
  int? _editingNoteId; // To track the note being edited
  late AnimationController _animationController;
  late Animation<double> _animation;
  String _headerTitle = 'MySimpleNote'; // Default header title
  bool _isMenuOpen = false; // Track the state of the menu

  @override
  void initState() {
    super.initState();
    _loadNotes(); // Load notes when the widget is initialized

    // Initialize Animation
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _animation = Tween<double>(begin: -250.0, end: 0.0).animate(_animationController); // Adjusted for left to right movement
  }

  // Load notes from the database
  Future<void> _loadNotes() async {
    List<Note> notesData = await NoteDatabase.instance.readAllNotes();
    setState(() {
      _notes = notesData; // Update the UI with loaded notes
    });
  }

  // Add or update a note
  Future<void> _addOrUpdateNote() async {
    if (_noteController.text.isNotEmpty) {
      if (_editingNoteId == null) {
        // Create new note
        final newNote = Note(content: _noteController.text);
        await NoteDatabase.instance.create(newNote);
      } else {
        // Update existing note
        final updatedNote = Note(
          id: _editingNoteId,
          content: _noteController.text,
        );
        await NoteDatabase.instance.update(updatedNote); // Update note in database
        _editingNoteId = null; // Reset editing note id
      }

      _noteController.clear();
      _loadNotes(); // Refresh notes
      Navigator.of(context).pop(); // Close dialog
    }
  }

  // Show add or edit note dialog
  void _showAddOrEditNoteDialog({Note? note}) {
    if (note != null) {
      _noteController.text = note.content; // Pre-fill the note content for editing
      _editingNoteId = note.id; // Set editing note id
    } else {
      _noteController.clear();
      _editingNoteId = null; // Reset for new note
    }

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(note == null ? 'Add Note' : 'Edit Note'),
          content: TextField(
            controller: _noteController,
            decoration: const InputDecoration(hintText: 'Enter your note'),
            maxLines: null,
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                _addOrUpdateNote(); // Add or update the note and close the dialog
              },
              child: Text(note == null ? 'Add' : 'Update'),
            ),
          ],
        );
      },
    );
  }

  // Delete a note at the specified index
  Future<void> _deleteNoteAtIndex(int index) async {
    final noteToDelete = _notes[index];
    await NoteDatabase.instance.createDeleted(noteToDelete); // Move to deleted notes
    await NoteDatabase.instance.delete(noteToDelete.id!); // Delete from notes
    _loadNotes(); // Refresh notes
  }

  // Handle note restoration callback
  void _onNoteRestored() {
    _loadNotes(); // Refresh notes after restoring
  }

  // Open the burger menu
  void _toggleMenu() {
    if (_animationController.isDismissed) {
      _animationController.forward();
      setState(() {
        _isMenuOpen = true; // Menu is now open
      });
    } else {
      _animationController.reverse();
      setState(() {
        _isMenuOpen = false; // Menu is now closed
      });
    }
  }

  // Update header title when selecting menu item
  void _updateHeader(String title) {
    setState(() {
      _headerTitle = title; // Update header title
    });
    _toggleMenu(); // Close menu
  }

  @override
  void dispose() {
    _animationController.dispose(); // Dispose the animation controller
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_headerTitle), // Change title dynamically
        backgroundColor: _isMenuOpen ? Colors.greenAccent : Colors.white, // Change color based on menu state
        leading: IconButton(
          icon: const Icon(Icons.menu),
          onPressed: _toggleMenu, // Open/close menu
        ),
      ),
      body: GestureDetector(
        onTap: () {
          if (_isMenuOpen) {
            _toggleMenu(); // Close menu when tapping outside
          }
        },
        child: Stack(
          children: [
            _notes.isEmpty
                ? const Center(child: Text('No notes yet'))
                : GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2, // Two notes per row
                crossAxisSpacing: 8.0,
                mainAxisSpacing: 8.0,
                childAspectRatio: 1.0, // Square shape
              ),
              padding: const EdgeInsets.all(8.0),
              itemCount: _notes.length,
              itemBuilder: (context, index) {
                final note = _notes[index];
                return GestureDetector(
                  onTap: () async {
                    bool? shouldRefresh = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => NoteDetailScreen(note: note), // Navigate to full screen note
                      ),
                    );
                    if (shouldRefresh ?? false) {
                      _loadNotes(); // Refresh notes if updated
                    }
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.yellow[300], // Yellow sticky note color
                      borderRadius: BorderRadius.circular(8.0),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 4.0,
                          offset: Offset(2, 2),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          note.content,
                          style: const TextStyle(
                            fontSize: 16.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Spacer(),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () {
                            _deleteNoteAtIndex(index); // Move note to recycle bin
                          },
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
            // Burger menu
            AnimatedBuilder(
              animation: _animation,
              builder: (context, child) {
                return Transform.translate(
                  offset: Offset(_animation.value, 0), // Move to the right
                  child: Opacity(
                    opacity: 1.0, // Set opacity to 1 for a solid color
                    child: Container(
                      color: Colors.greenAccent, // Change to your desired solid color
                      width: 250,
                      height: double.infinity,
                      child: Column(
                        children: [
                          ListTile(
                            leading: const Icon(Icons.home),
                            title: const Text('Home'),
                            tileColor: _isMenuOpen ? Colors.green : Colors.transparent, // Change color when open
                            onTap: () {
                              // Navigate back to the home page
                              _updateHeader('MySimpleNote'); // Change header to Home
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(builder: (context) => const MyHomePage()), // Navigate to Home
                              );
                            },
                          ),
                          ListTile(
                            leading: const Icon(Icons.delete),
                            title: const Text('Recycle Bin'),
                            tileColor: _isMenuOpen ? Colors.green : Colors.transparent, // Change color when open
                            onTap: () {
                              _updateHeader('MySimpleNote'); // Change header to Recycle Bin
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => RecycleBinScreen(onNoteRestored: _onNoteRestored), // Navigate to Recycle Bin
                                ),
                              ).then((_) {
                                _loadNotes(); // Refresh notes when coming back from recycle bin
                              });
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddOrEditNoteDialog(), // Show dialog for adding a note
        child: const Icon(Icons.add),
      ),
    );
  }
}





