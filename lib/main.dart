import 'package:flutter/material.dart';
import 'db/note_database.dart'; // Importing note_database.dart to access NoteDatabase
import 'screens/home_page.dart'; // Importing home_page.dart


// Main entry point of the application
void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // Ensures Flutter is fully initialized before database setup

  // Initialize the database and insert dummy data
  final db = NoteDatabase.instance;
  await db.database; // This initializes the database
  await db.insertDummyData(); // Inserts dummy data into both notes and deleted_notes tables

  runApp(const MyApp());
}
// Main application widget
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MySimpleNote',
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const MyHomePage(), // Set the home to MyHomePage
    );
  }
}
