import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'theme_notifier.dart';
import 'settings_page.dart'; // Import the SettingsPage
import 'tasks_page.dart';    // Import TasksPage
import 'notes_page.dart';    // Import NotesPage
import 'reminders_page.dart'; // Import RemindersPage

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => ThemeNotifier(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Define the seed color for generating color schemes
    const seedColor = Colors.blue;
    final themeNotifier = Provider.of<ThemeNotifier>(context); // Get the notifier

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
      themeMode: themeNotifier.themeMode, // Use themeMode from notifier
      debugShowCheckedModeBanner: false, // Remove debug banner
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  // Use the actual page widgets
  static const List<Widget> _widgetOptions = <Widget>[
    TasksPage(),
    NotesPage(),
    RemindersPage(),
  ];

  // Titles for the AppBar corresponding to each tab - No longer needed as AppBar is removed

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Add an empty drawer for the drawer icon button to function
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[ // Remove 'const' here
            const DrawerHeader( // Keep const for individual constant widgets
              decoration: BoxDecoration(
                color: Colors.blue, // Example color
              ),
              child: Text(
                'Menu',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                ),
              ),
            ),
            // Remove the duplicate ListTile
            ListTile( // Keep this one for Settings
              leading: const Icon(Icons.settings),
              title: const Text('Settings'),
              onTap: () {
                Navigator.pop(context); // Close the drawer first
                Navigator.push( // Then navigate to SettingsPage
                  context,
                  MaterialPageRoute(builder: (context) => const SettingsPage()),
                );
              },
            ),
            const Divider(), // Add a divider for visual separation
            const ListTile( // Use const
              leading: Icon(Icons.help), // Use const
              title: Text('Help'), // Use const
              // Add onTap if needed for Help page later
            ),
          ],
        ),
      ),
      body: SafeArea( // Use SafeArea to avoid overlapping with status bar
        child: Column(
          children: [
            // Custom Search Bar Area
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Card( // Use Card for elevation and rounded corners
                elevation: 2.0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30.0), // Rounded corners
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Row(
                    children: [
                      Builder( // Use Builder to get context for Scaffold.of
                        builder: (context) => IconButton(
                          icon: const Icon(Icons.menu),
                          onPressed: () {
                            Scaffold.of(context).openDrawer(); // Open drawer
                          },
                          tooltip: 'Open navigation menu',
                        ),
                      ),
                      const Expanded(
                        child: TextField(
                          decoration: InputDecoration(
                            hintText: 'Search...',
                            border: InputBorder.none, // Remove underline
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.account_circle),
                        onPressed: () {
                          // TODO: Implement account action
                        },
                        tooltip: 'Account',
                      ),
                    ],
                  ),
                ),
              ),
            ),
            // Expanded content area for the selected page
            Expanded(
              child: Center(
                child: _widgetOptions.elementAt(_selectedIndex),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: _buildFab(context), // Add the FAB here
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

  // Helper method to build the FAB based on the selected index
  Widget? _buildFab(BuildContext context) {
    switch (_selectedIndex) {
      case 0: // Tasks
        return FloatingActionButton.extended( // Use FloatingActionButton.extended
          onPressed: () {
            // TODO: Implement Add Task action
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Add New Task Tapped')),
            );
          },
          label: const Text('New Task'),
          icon: const Icon(Icons.add_task),
        );
      case 1: // Notes
        return FloatingActionButton.extended( // Use FloatingActionButton.extended
          onPressed: () {
            // TODO: Implement Add Note action
             ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Add New Note Tapped')),
            );
          },
          label: const Text('New Note'),
          icon: const Icon(Icons.edit_note),
        );
      case 2: // Reminders
        return FloatingActionButton.extended( // Use FloatingActionButton.extended
          onPressed: () {
            // TODO: Implement Add Reminder action
             ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Add New Reminder Tapped')),
            );
          },
          label: const Text('New Reminder'),
          icon: const Icon(Icons.add_alert),
        );
      default:
        return null; // Should not happen
    }
  }
}
