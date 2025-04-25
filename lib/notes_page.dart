import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'task_provider.dart';
import 'create_note_page.dart';

class NotesPage extends StatefulWidget {
  const NotesPage({super.key});

  @override
  State<NotesPage> createState() => _NotesPageState();
}

class _NotesPageState extends State<NotesPage> {
  bool _isGridView = true;
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();
  final List<Color> _noteColors = [
    Colors.white,
    Colors.red.shade100,
    Colors.orange.shade100,
    Colors.yellow.shade100,
    Colors.green.shade100,
    Colors.blue.shade100,
    Colors.indigo.shade100,
    Colors.purple.shade100,
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildSearchBar(),
        Expanded(
          child: Consumer<TaskProvider>(
            builder: (context, taskProvider, child) {
              final allNotes = taskProvider.getNotes();

              // Filter notes based on search query
              final notes = _searchQuery.isEmpty
                  ? allNotes
                  : allNotes.where((note) {
                      final title = note['title']?.toLowerCase() ?? '';
                      final content = note['content']?.toLowerCase() ?? '';
                      final query = _searchQuery.toLowerCase();
                      return title.contains(query) || content.contains(query);
                    }).toList();

              if (notes.isEmpty) {
                return _buildEmptyState();
              }

              return _isGridView
                  ? _buildMasonryGridView(notes, taskProvider)
                  : _buildListView(notes, taskProvider);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Align(
        alignment: Alignment.centerRight,
        child: IconButton(
            icon: Icon(_isGridView ? Icons.view_list : Icons.grid_view),
            onPressed: () {
              setState(() {
                _isGridView = !_isGridView;
              });
            },
            tooltip: _isGridView ? 'List view' : 'Grid view',
          ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.note_alt_outlined,
            size: 80,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          Text(
            _searchQuery.isEmpty
                ? 'Notes you add appear here'
                : 'No matching notes found',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey.shade600,
            ),
          ),
          if (_searchQuery.isEmpty) ...[
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const CreateNotePage()),
                );
              },
              icon: const Icon(Icons.add),
              label: const Text('Create a note'),
              style: ElevatedButton.styleFrom(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMasonryGridView(
      List<Map<String, String>> notes, TaskProvider taskProvider) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: MasonryGridView.count(
        crossAxisCount: MediaQuery.of(context).size.width > 600 ? 4 : 2,
        mainAxisSpacing: 8,
        crossAxisSpacing: 8,
        itemCount: notes.length,
        itemBuilder: (context, index) {
          final note = notes[index];
          // Generate a pseudo-random color based on the note title's hash code
          final colorIndex = note['title']!.hashCode % _noteColors.length;
          return _buildNoteCard(
              note, taskProvider, _noteColors[colorIndex.abs()]);
        },
      ),
    );
  }

  Widget _buildListView(
      List<Map<String, String>> notes, TaskProvider taskProvider) {
    return ListView.builder(
      padding: const EdgeInsets.all(8.0),
      itemCount: notes.length,
      itemBuilder: (context, index) {
        final note = notes[index];
        // Generate a pseudo-random color based on the note title's hash code
        final colorIndex = note['title']!.hashCode % _noteColors.length;
        return Padding(
          padding: const EdgeInsets.only(bottom: 8.0),
          child:
              _buildNoteCard(note, taskProvider, _noteColors[colorIndex.abs()]),
        );
      },
    );
  }

  Widget _buildNoteCard(
      Map<String, String> note, TaskProvider taskProvider, Color cardColor) {
    // Calculate content lines based on content length
    final contentLength = note['content']?.length ?? 0;
    final estimatedLines = (contentLength / 30).clamp(1, 10).toInt();

    return Card(
      color: cardColor,
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () {
          _openNoteEditor(note, taskProvider);
        },
        customBorder: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (note['title']!.isNotEmpty) ...[
                Text(
                  note['title']!,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Colors.black,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
              ],
              Text(
                note['content']!,
                style: const TextStyle(fontSize: 14,
                    color: Colors.black),
                maxLines: estimatedLines,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _openNoteEditor(Map<String, String> note, TaskProvider taskProvider) {
    // Find the task that contains this note
    final task = taskProvider.tasks.firstWhere(
      (task) => task.title == note['title'] && task.note == note['content'],
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
  }
}
