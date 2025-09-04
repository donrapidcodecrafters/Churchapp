import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class ServiceScreen extends StatefulWidget {
  @override
  _ServiceScreenState createState() => _ServiceScreenState();
}

class _ServiceScreenState extends State<ServiceScreen> {
  List<Map<String, dynamic>> _songs = [];
  List<Map<String, dynamic>> _notes = [];
  List<Map<String, dynamic>> _displayQueue = [];

  int _currentIndex = 0;
  bool _loading = true;
  bool _autoScroll = false;
  Timer? _scrollTimer;
  int _scrollInterval = 10; // default for songs

  @override
  void initState() {
    super.initState();
    _fetchService();
  }

  Future<void> _fetchService() async {
    final res = await http.get(Uri.parse('http://localhost:4000/services/1'));
    if (res.statusCode == 200) {
      final data = jsonDecode(res.body);
      setState(() {
        _songs = List<Map<String, dynamic>>.from(data['songs']);
        _loading = false;
      });
      await _fetchNotes(1);
      _buildDisplayQueue();
      if (_displayQueue.isNotEmpty) {
        _pushLyricsToWeb(_displayQueue[_currentIndex]['content']);
      }
    }
  }

  Future<void> _fetchNotes(int serviceId) async {
    final res = await http.get(Uri.parse("http://localhost:4000/services/$serviceId/notes"));
    if (res.statusCode == 200) {
      setState(() {
        _notes = List<Map<String, dynamic>>.from(jsonDecode(res.body));
      });
    }
  }

  void _buildDisplayQueue() {
    _displayQueue = [];
    _displayQueue.addAll(_songs.asMap().entries.map((entry) => {
      "type": "song",
      "content": entry.value['lyrics'],
      "position": entry.key + 1,
      "time": _scrollInterval,
    }));
    _displayQueue.addAll(_notes.map((n) => {
      "type": "note",
      "content": n['content'],
      "position": n['position'] ?? 0,
      "time": n['display_time'] ?? _scrollInterval,
    }));
    _displayQueue.sort((a, b) => (a['position'] as int).compareTo(b['position'] as int));
  }

  void _next() {
    if (_currentIndex < _displayQueue.length - 1) {
      setState(() => _currentIndex++);
      _pushLyricsToWeb(_displayQueue[_currentIndex]['content']);
    }
  }

  void _prev() {
    if (_currentIndex > 0) {
      setState(() => _currentIndex--);
      _pushLyricsToWeb(_displayQueue[_currentIndex]['content']);
    }
  }

  Future<void> _pushLyricsToWeb(String content) async {
    try {
      await http.post(
        Uri.parse('http://localhost:4000/push-lyrics'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"lyrics": content}),
      );
    } catch (e) {
      print("Error pushing content: $e");
    }
  }

  void _toggleAutoScroll() {
    setState(() => _autoScroll = !_autoScroll);
    if (_autoScroll) {
      _scrollTimer = Timer.periodic(Duration(seconds: 1), (timer) {
        if (_currentIndex < _displayQueue.length - 1) {
          final current = _displayQueue[_currentIndex];
          final wait = current['time'] ?? _scrollInterval;
          if (timer.tick % wait == 0) {
            setState(() => _currentIndex++);
            _pushLyricsToWeb(_displayQueue[_currentIndex]['content']);
          }
        } else {
          timer.cancel();
          setState(() => _autoScroll = false);
        }
      });
    } else {
      _scrollTimer?.cancel();
    }
  }

  @override
  void dispose() {
    _scrollTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text('Service Display'),
        actions: [
          IconButton(
            icon: Icon(_autoScroll ? Icons.pause : Icons.play_arrow),
            onPressed: _toggleAutoScroll,
            tooltip: _autoScroll ? "Pause Auto-Scroll" : "Start Auto-Scroll",
          ),
        ],
      ),
      body: _loading
          ? Center(child: CircularProgressIndicator())
          : _displayQueue.isEmpty
              ? Center(child: Text("No content", style: TextStyle(color: Colors.white)))
              : Column(
                  children: [
                    Expanded(
                      child: Center(
                        child: Text(
                          _displayQueue[_currentIndex]['content'] ?? "No content",
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.white, fontSize: 32),
                        ),
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        ElevatedButton(onPressed: _prev, child: Text("Prev")),
                        ElevatedButton(onPressed: _next, child: Text("Next")),
                      ],
                    ),
                    SizedBox(height: 10),
                    Text(
                      "Auto-scroll: ${_autoScroll ? "ON" : "OFF"}",
                      style: TextStyle(color: Colors.white70),
                    ),
                    SizedBox(height: 20),
                  ],
                ),
    );
  }
}