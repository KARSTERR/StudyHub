// lib/screens/note_detail_screen.dart
import 'package:flutter/material.dart';
import '../models/lesson_note.dart';

class NoteDetailScreen extends StatelessWidget {
  final LessonNote note;

  const NoteDetailScreen({super.key, required this.note});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(note.title),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              note.title,
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Text(
                  'By ${note.authorName}',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const Spacer(),
                Chip(
                  label: Text(
                    note.isPublic ? 'Public' : 'Private',
                    style: TextStyle(
                      color: note.isPublic ? Colors.white : Colors.black,
                    ),
                  ),
                  backgroundColor: note.isPublic ? Colors.green : Colors.grey.shade300,
                ),
              ],
            ),
            if (note.tags.isNotEmpty) ...[
              const SizedBox(height: 16),
              Wrap(
                spacing: 8,
                runSpacing: 4,
                children: note.tags
                    .map((tag) => Chip(label: Text(tag)))
                    .toList(),
              ),
            ],
            const SizedBox(height: 24),
            Text(
              note.content,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ],
        ),
      ),
    );
  }
}