import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:http/http.dart' as http;
import 'package:music_sheet_widget/music_sheet_widget.dart';

class MusicOCRScreen extends StatefulWidget {
  @override
  _MusicOCRScreenState createState() => _MusicOCRScreenState();
}

class _MusicOCRScreenState extends State<MusicOCRScreen> {
  String? _musicXML;
  bool _loading = false;

  Future<void> _pickAndUploadFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(type: FileType.image);
    if (result != null) {
      File file = File(result.files.single.path!);
      setState(() => _loading = true);
      var request = http.MultipartRequest('POST', Uri.parse('http://localhost:4000/music-ocr'));
      request.files.add(await http.MultipartFile.fromPath('sheet', file.path));
      var response = await request.send();
      if (response.statusCode == 200) {
        final body = await response.stream.bytesToString();
        final data = jsonDecode(body);
        setState(() {
          _musicXML = data['musicxml'];
          _loading = false;
        });
      } else {
        setState(() {
          _loading = false;
          _musicXML = "Error: ${response.statusCode}";
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Music OCR')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            ElevatedButton(onPressed: _pickAndUploadFile, child: Text("Upload Music Sheet")),
            SizedBox(height: 20),
            if (_loading) CircularProgressIndicator(),
            if (_musicXML != null && !_loading)
              Expanded(child: MusicSheetWidget.fromMusicXML(_musicXML!)),
          ],
        ),
      ),
    );
  }
}