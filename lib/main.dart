import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:typed_data';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:convert';
import 'theme_notifier.dart';
import 'settings_page.dart';
import 'tasks_page.dart';
import 'notes_page.dart';
import 'reminders_page.dart';
import 'create_task_page.dart';
import 'task_provider.dart';
import 'splash_screen.dart'; // Import SplashScreen

import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeNotifier()),
        ChangeNotifierProvider(create: (_) => TaskProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    const seedColor = Colors.blue;
    final themeNotifier = Provider.of<ThemeNotifier>(context);

    return MaterialApp(
      title: 'Trigram App',
      theme: ThemeData(
        colorSchemeSeed: seedColor,
        useMaterial3: true,
        brightness: Brightness.light,
      ),
      darkTheme: ThemeData(
        colorSchemeSeed: seedColor,
        useMaterial3: true,
        brightness: Brightness.dark,
      ),
      themeMode: themeNotifier.themeMode,
      debugShowCheckedModeBanner: false,
      home: const SplashScreen(), // Start with SplashScreen
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;
  Uint8List? _profileImageBytes;

  static final List<Widget> _widgetOptions = <Widget>[
    const TasksPage(),
    const NotesPage(),
    const RemindersPage(),
  ];

  @override
  void initState() {
    super.initState();
    _fetchUserProfileImage();
  }

  Future<void> _fetchUserProfileImage() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      final docSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      if (docSnapshot.exists) {
        final userData = docSnapshot.data();
        final base64Image = userData?['profileImage'] as String?;
        if (base64Image != null && base64Image.isNotEmpty) {
          setState(() {
            _profileImageBytes = base64Decode(base64Image);
          });
        }
      }
    } catch (e) {
      // Handle error silently
      debugPrint('Failed to load user profile image: $e');
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            const DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.blue,
              ),
              child: Text(
                'Menu',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text('Settings'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const SettingsPage()),
                );
              },
            ),
            const Divider(),
            const ListTile(
              leading: Icon(Icons.help),
              title: Text('Help'),
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Left: Menu button
                  Builder(
                    builder: (context) => IconButton(
                      icon: const Icon(Icons.menu),
                      onPressed: () {
                        Scaffold.of(context).openDrawer();
                      },
                      tooltip: 'Open navigation menu',
                    ),
                  ),
                  // Center: Page title
                  Text(
                    _selectedIndex == 0
                        ? 'Tasks'
                        : _selectedIndex == 1
                            ? 'Notes'
                            : 'Reminders',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  // Right: Row with filter (conditional) and profile image
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Filter button (only shown on Tasks tab)
                      if (_selectedIndex == 0)
                        Consumer<TaskProvider>(
                          builder: (context, taskProvider, child) {
                            return IconButton(
                              icon: Icon(
                                taskProvider.sortByNewest
                                    ? Icons.filter_list
                                    : Icons.filter_list_off,
                              ),
                              onPressed: () {
                                taskProvider.toggleSortOrder();
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      taskProvider.sortByNewest
                                          ? 'Sorting by newest first'
                                          : 'Sorting by oldest first',
                                    ),
                                    duration: const Duration(seconds: 1),
                                  ),
                                );
                              },
                              tooltip: taskProvider.sortByNewest
                                  ? 'Newest first'
                                  : 'Oldest first',
                            );
                          },
                        ),
                      // Profile image
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const SettingsPage()),
                          );
                        },
                        child: _profileImageBytes != null
                            ? CircleAvatar(
                                backgroundImage:
                                    MemoryImage(_profileImageBytes!),
                                radius: 20,
                              )
                            : const CircleAvatar(
                                radius: 20,
                                child: Icon(Icons.account_circle),
                              ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: _widgetOptions.elementAt(_selectedIndex),
            ),
          ],
        ),
      ),
      floatingActionButton: _buildFab(context),
      bottomNavigationBar: NavigationBar(
        onDestinationSelected: _onItemTapped,
        selectedIndex: _selectedIndex,
        destinations: const <Widget>[
          NavigationDestination(
            selectedIcon: Icon(Icons.task_alt),
            icon: Icon(Icons.task_alt_outlined),
            label: 'Tasks',
          ),
          NavigationDestination(
            selectedIcon: Icon(Icons.note_alt),
            icon: Icon(Icons.note_alt_outlined),
            label: 'Notes',
          ),
          NavigationDestination(
            selectedIcon: Icon(Icons.notifications),
            icon: Icon(Icons.notifications_outlined),
            label: 'Reminders',
          ),
        ],
      ),
    );
  }

  Widget? _buildFab(BuildContext context) {
    switch (_selectedIndex) {
      case 0:
        return FloatingActionButton.extended(
          onPressed: () async {
            final newTask = await Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const CreateTaskPage()),
            );

            if (newTask != null &&
                newTask is Map<String, dynamic> &&
                newTask.containsKey('title')) {
              final title = newTask['title'] as String;
              Provider.of<TaskProvider>(context, listen: false).addTask(
                title: title,
                subTasks: [], // Initialize with empty subtasks
              );
            }
          },
          label: const Text('New Task'),
          icon: const Icon(Icons.add_task),
        );
      case 1:
        return FloatingActionButton.extended(
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Add New Note Tapped')),
            );
          },
          label: const Text('New Note'),
          icon: const Icon(Icons.edit_note),
        );
      case 2:
        return FloatingActionButton.extended(
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Add New Reminder Tapped')),
            );
          },
          label: const Text('New Reminder'),
          icon: const Icon(Icons.add_alert),
        );
      default:
        return null;
    }
  }
}
