import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'theme_notifier.dart';
import 'auth_page.dart'; // Import AuthPage for logout navigation

class SettingsPage extends StatefulWidget {
  const SettingsPage({Key? key}) : super(key: key);

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  User? _currentUser;
  Map<String, dynamic>? _userData;
  Uint8List? _profileImageBytes;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    _currentUser = FirebaseAuth.instance.currentUser;
    if (_currentUser == null) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'User not logged in.';
      });
      return;
    }

    try {
      final docSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(_currentUser!.uid)
          .get();

      if (docSnapshot.exists) {
        _userData = docSnapshot.data();
        final base64Image = _userData?['profileImage'] as String?;
        if (base64Image != null && base64Image.isNotEmpty) {
          _profileImageBytes = base64Decode(base64Image);
        }
      } else {
        _errorMessage = 'User data not found.';
      }
    } catch (e) {
      _errorMessage = 'Failed to load user data: $e';
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeNotifier = Provider.of<ThemeNotifier>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        children: [
          if (_isLoading)
            const Center(
                child: Padding(
                    padding: EdgeInsets.all(20.0),
                    child: CircularProgressIndicator()))
          else if (_errorMessage != null)
            Center(
                child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Text(_errorMessage!,
                        style: TextStyle(
                            color: Theme.of(context).colorScheme.error))))
          else if (_userData != null)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundImage: _profileImageBytes != null
                        ? MemoryImage(_profileImageBytes!)
                        : null, // Use MemoryImage
                    child: _profileImageBytes == null
                        ? const Icon(Icons.person, size: 30)
                        : null,
                  ),
                  const SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _userData!['name'] ?? 'No Name',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      Text(
                        _userData!['email'] ?? 'No Email',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          const Divider(),
          ListTile(
            title: const Text('Theme'),
            trailing: DropdownButton<ThemeMode>(
              value: themeNotifier.themeMode,
              onChanged: (ThemeMode? newValue) {
                if (newValue != null) {
                  themeNotifier.setThemeMode(newValue);
                }
              },
              items: ThemeMode.values
                  .map<DropdownMenuItem<ThemeMode>>((ThemeMode value) {
                return DropdownMenuItem<ThemeMode>(
                  value: value,
                  child: Text(value.toString().split('.').last),
                );
              }).toList(),
            ),
          ),
          // Add other settings options here
          ListTile(
            title: const Text('Logout'),
            leading: const Icon(Icons.logout),
            onTap: () async {
              await FirebaseAuth.instance.signOut();
              // Navigate back to auth page or splash screen
              // Example: Assuming AuthPage is your entry point after logout
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(
                    builder: (context) =>
                        const AuthPage()), // Or your splash/login screen
                (Route<dynamic> route) => false, // Remove all routes below
              );
            },
          ),
        ],
      ),
    );
  }
}
