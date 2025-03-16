// lib/screens/lesson_notes_screen.dart
import 'package:flutter/material.dart';
import '../models/lesson_note.dart';
import '../services/lesson_notes_service.dart';
import '../services/auth_service.dart';
import 'create_edit_note_screen.dart';
import 'note_detail_screen.dart'; // Add import for NoteDetailScreen

class LessonNotesScreen extends StatefulWidget {
  const LessonNotesScreen({super.key});

  @override
  State<LessonNotesScreen> createState() => _LessonNotesScreenState(); // Use State<T> instead of private type
}

class _LessonNotesScreenState extends State<LessonNotesScreen> {
  final LessonNotesService _notesService = LessonNotesService();
  final AuthService _authService = AuthService(); // Remove namespace alias
  List<LessonNote> _notes = [];
  bool _isLoading = true;
  String? _currentUserId;
  String? _currentUsername;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _loadNotes();
  }

  Future<void> _loadNotes() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = '';
      });

      _currentUserId = await _authService.getUserId();
      _currentUsername = await _authService.getUsername();

      final notes = await _notesService.getLessonNotes(
        authorId: _currentUserId,
      );

      setState(() {
        _notes = notes;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Failed to load notes: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lesson Notes'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadNotes,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage.isNotEmpty
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              _errorMessage,
              style: const TextStyle(color: Colors.red),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadNotes,
              child: const Text('Retry'),
            ),
          ],
        ),
      )
          : _notes.isEmpty
          ? const Center(
        child: Text('No notes found. Create your first note!'),
      )
          : ListView.builder(
        itemCount: _notes.length,
        itemBuilder: (context, index) {
          final note = _notes[index];
          return Card(
            margin: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 8,
            ),
            child: ListTile(
              title: Text(note.title),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    note.content.length > 50
                        ? '${note.content.substring(0, 50)}...'
                        : note.content,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment:
                    MainAxisAlignment.spaceBetween,
                    children: [
                      Text('By ${note.authorName}'),
                      Text(
                        note.isPublic ? 'Public' : 'Private',
                        style: TextStyle(
                          color: note.isPublic
                              ? Colors.green
                              : Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              trailing: note.authorId == _currentUserId
                  ? PopupMenuButton(
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'edit',
                    child: Text('Edit'),
                  ),
                  const PopupMenuItem(
                    value: 'delete',
                    child: Text('Delete'),
                  ),
                ],
                onSelected: (value) async {
                  if (value == 'edit') {
                    final updatedNote = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            CreateEditNoteScreen(note: note),
                      ),
                    );
                    if (updatedNote != null) {
                      _loadNotes();
                    }
                  } else if (value == 'delete') {
                    _confirmDelete(note);
                  }
                },
              )
                  : null,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        NoteDetailScreen(note: note),
                  ),
                );
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => CreateEditNoteScreen(
                currentUserId: _currentUserId,
                currentUsername: _currentUsername,
              ),
            ),
          );
          if (result != null) {
            _loadNotes();
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Future<void> _confirmDelete(LessonNote note) async {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Note'),
        content: Text('Are you sure you want to delete "${note.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await _notesService.deleteLessonNote(note.id!);
              _loadNotes();
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'), // Moved child to be the last argument
          ),
        ],
      ),
    );
  }
}