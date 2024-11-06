import 'dart:async';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class Note {
  final int? id;
  final String content;

  Note({
    this.id,
    required this.content,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'content': content,
    };
  }

  factory Note.fromMap(Map<String, dynamic> map) {
    return Note(
      id: map['id'],
      content: map['content'],
    );
  }
}

class NoteDatabase {
  static final NoteDatabase instance = NoteDatabase._init();
  static Database? _database;

  NoteDatabase._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('notes.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);
    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future _createDB(Database db, int version) async {
    const idType = 'INTEGER PRIMARY KEY AUTOINCREMENT';
    const textType = 'TEXT NOT NULL';

    await db.execute('''CREATE TABLE notes (id $idType, content $textType)''');
    await db.execute('''CREATE TABLE deleted_notes (id $idType, content $textType)''');
  }

  // Insert dummy data into both tables
  Future<void> insertDummyData() async {
    final db = await instance.database;

    // Insert dummy notes into the 'notes' table
    await db.insert('notes', {'content': 'Sample Note 1'});
    await db.insert('notes', {'content': 'Sample Note 2'});
    await db.insert('notes', {'content': 'Sample Note 3'});


  }

  Future<void> create(Note note) async {
    final db = await instance.database;
    await db.insert('notes', note.toMap());
  }

  Future<void> createDeleted(Note note) async {
    final db = await instance.database;
    await db.insert('deleted_notes', note.toMap());
  }

  Future<List<Note>> readAllNotes() async {
    final db = await instance.database;
    final result = await db.query('notes');
    return result.map((map) => Note.fromMap(map)).toList();
  }

  Future<List<Note>> readAllDeletedNotes() async {
    final db = await instance.database;
    final result = await db.query('deleted_notes');
    return result.map((map) => Note.fromMap(map)).toList();
  }

  Future<void> delete(int id) async {
    final db = await instance.database;
    await db.delete('notes', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> deletePermanently(int id) async {
    final db = await instance.database;
    await db.delete('deleted_notes', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> update(Note note) async {
    final db = await instance.database;
    await db.update('notes', note.toMap(), where: 'id = ?', whereArgs: [note.id]);
  }

  Future close() async {
    final db = await instance.database;
    db.close();
  }
}


