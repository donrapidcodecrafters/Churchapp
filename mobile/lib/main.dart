import 'package:flutter/material.dart';
import 'notes_ocr_screen.dart';
import 'music_ocr_screen.dart';
import 'service_screen.dart';
import 'admin_add_song.dart';

void main() {
  runApp(ChurchApp());
}

class ChurchApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Church App',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: HomeScreen(),
      routes: {
        '/ocr-notes': (_) => NotesOCRScreen(),
        '/ocr-music': (_) => MusicOCRScreen(),
        '/service': (_) => ServiceScreen(),
        '/admin-song': (_) => AdminAddSongScreen(),
      },
    );
  }
}

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Church App')),
      body: ListView(
        children: [
          ListTile(title: Text('Notes OCR'), onTap: () => Navigator.pushNamed(context, '/ocr-notes')),
          ListTile(title: Text('Music OCR'), onTap: () => Navigator.pushNamed(context, '/ocr-music')),
          ListTile(title: Text('Service Display'), onTap: () => Navigator.pushNamed(context, '/service')),
          ListTile(title: Text('Admin: Add Song'), onTap: () => Navigator.pushNamed(context, '/admin-song')),
        ],
      ),
    );
  }
}