import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/lesson_note.dart';

class LessonNotesService {
  static const String _storageKey = 'lesson_notes';

  // Get all lesson notes (optionally filtered by author)
  Future<List<LessonNote>> getLessonNotes({String? authorId}) async {
    final prefs = await SharedPreferences.getInstance();
    final notesJson = prefs.getStringList(_storageKey) ?? [];

    final List<LessonNote> notes = notesJson
        .map((noteStr) => LessonNote.fromJson(jsonDecode(noteStr)))
        .toList();

    if (authorId != null) {
      return notes.where((note) =>
      note.authorId == authorId || note.isPublic).toList();
    }

    return notes;
  }

  // Get public lesson notes
  Future<List<LessonNote>> getPublicLessonNotes() async {
    final notes = await getLessonNotes();
    return notes.where((note) => note.isPublic).toList();
  }

  // Get a specific lesson note by ID
  Future<LessonNote?> getLessonNoteById(String id) async {
    final notes = await getLessonNotes();
    try {
      return notes.firstWhere((note) => note.id == id);
    } catch (e) {
      return null;
    }
  }

  // Create a new lesson note
  Future<LessonNote> createLessonNote(LessonNote note) async {
    final prefs = await SharedPreferences.getInstance();
    final notesJson = prefs.getStringList(_storageKey) ?? [];

    // Create a new note with a unique ID
    final newNote = LessonNote(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: note.title,
      content: note.content,
      authorId: note.authorId,
      authorName: note.authorName,
      tags: note.tags,
      isPublic: note.isPublic,
    );

    notesJson.add(jsonEncode(newNote.toJson()));
    await prefs.setStringList(_storageKey, notesJson);

    return newNote;
  }

  // Update an existing lesson note
  Future<bool> updateLessonNote(LessonNote updatedNote) async {
    if (updatedNote.id == null) return false;

    final prefs = await SharedPreferences.getInstance();
    final notesJson = prefs.getStringList(_storageKey) ?? [];

    final List<LessonNote> notes = notesJson
        .map((noteStr) => LessonNote.fromJson(jsonDecode(noteStr)))
        .toList();

    final index = notes.indexWhere((note) => note.id == updatedNote.id);
    if (index == -1) return false;

    notes[index] = updatedNote;

    await prefs.setStringList(_storageKey,
        notes.map((note) => jsonEncode(note.toJson())).toList());

    return true;
  }

  // Delete a lesson note
  Future<bool> deleteLessonNote(String id) async {
    final prefs = await SharedPreferences.getInstance();
    final notesJson = prefs.getStringList(_storageKey) ?? [];

    final List<LessonNote> notes = notesJson
        .map((noteStr) => LessonNote.fromJson(jsonDecode(noteStr)))
        .toList();

    final initialLength = notes.length;
    notes.removeWhere((note) => note.id == id);

    if (notes.length == initialLength) return false;

    await prefs.setStringList(_storageKey,
        notes.map((note) => jsonEncode(note.toJson())).toList());

    return true;
  }
}