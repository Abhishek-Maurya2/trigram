import 'package:flutter/material.dart';

class NotesPage extends StatefulWidget {
  const NotesPage({super.key});

  @override
  State<NotesPage> createState() => _NotesPageState();
}

class _NotesPageState extends State<NotesPage> {
  // Dummy list of notes
  final List<Map<String, String>> _notes = List.generate(10, (index) => {
    'title': 'Note ${index + 1}',
    'content': 'This is the content for note number ${index + 1}. It could be a bit longer to see how it wraps.'
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(8.0),
      itemCount: _notes.length,
      itemBuilder: (context, index) {
        return Card(
          margin: const EdgeInsets.symmetric(vertical: 4.0),
          child: ListTile(
            title: Text(_notes[index]['title']!),
            subtitle: Text(
              _notes[index]['content']!,
              maxLines: 2, // Limit content preview
              overflow: TextOverflow.ellipsis,
            ),
            onTap: () {
              // TODO: Implement note tap action (e.g., open full note)
            },
          ),
        );
      },
    );
  }
}
