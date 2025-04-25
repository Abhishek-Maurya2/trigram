import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'task_provider.dart';
import 'create_note_page.dart';

class NotesPage extends StatelessWidget {
  const NotesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<TaskProvider>(
      builder: (context, taskProvider, child) {
        final notes = taskProvider.getNotes();

        if (notes.isEmpty) {
          return const Center(
            child: Text('No notes yet. Tap + to add a new note.'),
          );
        }

        return GridView.builder(
          padding: const EdgeInsets.all(8.0),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount:
                ((MediaQuery.of(context).size.width ~/ 200).clamp(1, 6))
                    .toInt(),
            crossAxisSpacing: 8.0,
            mainAxisSpacing: 8.0,
            childAspectRatio: 1,
          ),
          itemCount: notes.length,
          itemBuilder: (context, index) {
            final note = notes[index];

            return InkWell(
              onTap: () {
                // Find the task that contains this note
                final task = taskProvider.tasks.firstWhere(
                  (task) =>
                      task.title == note['title'] &&
                      task.note == note['content'],
                  orElse: () => throw Exception('Note not found'),
                );

                // Open the CreateNotePage with the note's data
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CreateNotePage(
                      initialTitle: note['title'],
                      initialContent: note['content'],
                      taskId: task.id,
                    ),
                  ),
                );
              },
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        note['title']!,
                        style: Theme.of(context).textTheme.titleMedium,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const Divider(),
                      Expanded(
                        child: Text(
                          note['content']!,
                          maxLines: 6,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
