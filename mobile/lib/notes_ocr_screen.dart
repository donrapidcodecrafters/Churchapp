import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

class NotesOCRScreen extends StatefulWidget {
  @override
  _NotesOCRScreenState createState() => _NotesOCRScreenState();
}

class _NotesOCRScreenState extends State<NotesOCRScreen> {
  File? _image;
  String _recognizedText = "";
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.camera);
    if (pickedFile != null) {
      setState(() => _image = File(pickedFile.path));
      _performOCR(File(pickedFile.path));
    }
  }

  Future<void> _performOCR(File imageFile) async {
    final textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);
    final inputImage = InputImage.fromFile(imageFile);
    final RecognizedText recognizedText = await textRecognizer.processImage(inputImage);
    setState(() => _recognizedText = recognizedText.text);
    textRecognizer.close();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Notes OCR')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            ElevatedButton(onPressed: _pickImage, child: Text("Capture Notes")),
            if (_image != null) Image.file(_image!, height: 200),
            SizedBox(height: 20),
            Expanded(child: SingleChildScrollView(child: Text(_recognizedText.isEmpty ? "No text recognized yet." : _recognizedText))),
          ],
        ),
      ),
    );
  }
}