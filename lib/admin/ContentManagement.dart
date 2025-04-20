import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class ContentManagement extends StatefulWidget {
  const ContentManagement({super.key});

  @override
  _ContentManagementState createState() => _ContentManagementState();
}

class _ContentManagementState extends State<ContentManagement> {
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final ImagePicker _picker = ImagePicker();

  File? _selectedFile;
  String? _uploadedFileURL;
  final TextEditingController _youtubeController = TextEditingController();
  final List<String> _youtubeLinks = [];

  // Function to upload file to Firebase Storage
  Future<void> _uploadFile(File file, String path) async {
    try {
      await _storage.ref(path).putFile(file);
      final url = await _storage.ref(path).getDownloadURL();
      setState(() {
        _uploadedFileURL = url;
      });
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('File Uploaded!')));
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Upload Failed: $e')));
    }
  }

  // Function to pick file from gallery
  Future<void> _pickFile() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _selectedFile = File(pickedFile.path);
      });
    }
  }

  // Function to add YouTube links
  void _addYoutubeLink() {
    if (_youtubeController.text.isNotEmpty) {
      setState(() {
        _youtubeLinks.add(_youtubeController.text);
        _youtubeController.clear();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Content Management'),
        backgroundColor: Colors.deepPurple,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ElevatedButton(
                onPressed: _pickFile,
                child: const Text('Pick File'),
              ),
              const SizedBox(height: 20),
              _selectedFile != null
                  ? Text('File selected: ${_selectedFile!.path.split('/').last}')
                  : const Text('No file selected'),
              const SizedBox(height: 20),
              _selectedFile != null
                  ? ElevatedButton(
                      onPressed: () =>
                          _uploadFile(_selectedFile!, 'Uploads/${DateTime.now()}'),
                      child: const Text('Upload File'),
                    )
                  : Container(),
              const SizedBox(height: 20),
              _uploadedFileURL != null
                  ? Text('Uploaded: $_uploadedFileURL')
                  : Container(),
              const SizedBox(height: 20),
              TextField(
                controller: _youtubeController,
                decoration: const InputDecoration(
                  labelText: 'YouTube Video Link',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: _addYoutubeLink,
                child: const Text('Add YouTube Link'),
              ),
              const SizedBox(height: 20),
              ..._youtubeLinks.map((link) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Text(
                      link,
                      style: const TextStyle(
                          color: Colors.blue,
                          decoration: TextDecoration.underline),
                    ),
                  )),
            ],
          ),
        ),
      ),
    );
  }
}