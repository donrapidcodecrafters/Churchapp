import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class AdminAddSongScreen extends StatefulWidget {
  @override
  _AdminAddSongScreenState createState() => _AdminAddSongScreenState();
}

class _AdminAddSongScreenState extends State<AdminAddSongScreen> {
  final _titleCtrl = TextEditingController();
  final _lyricsCtrl = TextEditingController();

  Future<void> _saveSong() async {
    final response = await http.post(
      Uri.parse('http://localhost:4000/songs'),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"title": _titleCtrl.text, "lyrics": _lyricsCtrl.text}),
    );
    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Song saved!")));
      _titleCtrl.clear();
      _lyricsCtrl.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Add Song")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(controller: _titleCtrl, decoration: InputDecoration(labelText: "Title")),
            TextField(controller: _lyricsCtrl, decoration: InputDecoration(labelText: "Lyrics"), maxLines: 6),
            SizedBox(height: 20),
            ElevatedButton(onPressed: _saveSong, child: Text("Save Song")),
          ],
        ),
      ),
    );
  }
}