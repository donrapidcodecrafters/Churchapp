import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class PastorNotesScreen extends StatefulWidget {
  final int serviceId;
  PastorNotesScreen({required this.serviceId});

  @override
  _PastorNotesScreenState createState() => _PastorNotesScreenState();
}

class _PastorNotesScreenState extends State<PastorNotesScreen> {
  List<Map<String, dynamic>> _notes = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _fetchNotes();
  }

  Future<void> _fetchNotes() async {
    final res = await http.get(Uri.parse("http://localhost:4000/services/${widget.serviceId}/notes"));
    if (res.statusCode == 200) {
      setState(() {
        _notes = List<Map<String, dynamic>>.from(jsonDecode(res.body));
        _loading = false;
      });
    }
  }

  Future<void> _updateNote(int id, String content, int displayTime, int position) async {
    await http.put(
      Uri.parse("http://localhost:4000/notes/$id"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"content": content, "display_time": displayTime, "position": position}),
    );
    _fetchNotes();
  }

  Future<void> _deleteNote(int id) async {
    await http.delete(Uri.parse("http://localhost:4000/notes/$id"));
    _fetchNotes();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Pastor Notes (Live Editable)")),
      body: _loading
          ? Center(child: CircularProgressIndicator())
          : ReorderableListView(
              children: _notes.map((note) {
                final id = note['id'];
                final contentCtrl = TextEditingController(text: note['content']);
                final timeCtrl = TextEditingController(text: "${note['display_time']}");
                final pos = note['position'];

                return Card(
                  key: ValueKey(id),
                  child: ListTile(
                    title: TextField(
                      controller: contentCtrl,
                      decoration: InputDecoration(labelText: "Note Content"),
                      onSubmitted: (val) => _updateNote(id, val, int.parse(timeCtrl.text), pos),
                    ),
                    subtitle: Row(
                      children: [
                        SizedBox(
                          width: 80,
                          child: TextField(
                            controller: timeCtrl,
                            decoration: InputDecoration(labelText: "Sec"),
                            keyboardType: TextInputType.number,
                            onSubmitted: (val) => _updateNote(id, contentCtrl.text, int.parse(val), pos),
                          ),
                        ),
                        SizedBox(width: 20),
                        IconButton(
                          icon: Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _deleteNote(id),
                        )
                      ],
                    ),
                  ),
                );
              }).toList(),
              onReorder: (oldIndex, newIndex) async {
                if (newIndex > _notes.length) newIndex = _notes.length;
                if (oldIndex < newIndex) newIndex -= 1;
                final moved = _notes.removeAt(oldIndex);
                _notes.insert(newIndex, moved);
                for (int i = 0; i < _notes.length; i++) {
                  final n = _notes[i];
                  await _updateNote(n['id'], n['content'], n['display_time'], i + 1);
                }
                _fetchNotes();
              },
            ),
    );
  }
}