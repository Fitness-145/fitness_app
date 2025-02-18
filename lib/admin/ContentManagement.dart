import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';

class ContentManagement extends StatefulWidget {
  const ContentManagement({super.key});

  @override
  _ContentManagementState createState() => _ContentManagementState();
}

class _ContentManagementState extends State<ContentManagement> {
  final List<Map<String, String>> _contentList = [];

  /// Function to pick files (Images, Audio, Files)
  Future<void> _pickContent(String type) async {
    FileType fileType = FileType.any;

    if (type == 'Image') {
      fileType = FileType.image;
    } else if (type == 'Audio') {
      fileType = FileType.audio;
    }

    FilePickerResult? result = await FilePicker.platform.pickFiles(type: fileType);

    if (result != null && result.files.isNotEmpty) {
      String filePath = result.files.single.path ?? "";
      setState(() {
        _contentList.add({'type': type, 'path': filePath});
      });
    } else {
      // Handle case where user cancels file picking
      debugPrint("No file selected");
    }
  }

  /// Function to delete content
  void _deleteContent(int index) {
    setState(() {
      _contentList.removeAt(index);
    });
  }

  /// Show bottom sheet for content selection
  void _showAddOptions() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.image),
              title: const Text("Add Image"),
              onTap: () {
                Navigator.pop(context);
                _pickContent('Image');
              },
            ),
            ListTile(
              leading: const Icon(Icons.audiotrack),
              title: const Text("Add Audio"),
              onTap: () {
                Navigator.pop(context);
                _pickContent('Audio');
              },
            ),
            ListTile(
              leading: const Icon(Icons.attach_file),
              title: const Text("Add File"),
              onTap: () {
                Navigator.pop(context);
                _pickContent('File');
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Content Management")),
      body: _contentList.isEmpty
          ? const Center(child: Text("No content added"))
          : ListView.builder(
              itemCount: _contentList.length,
              itemBuilder: (context, index) {
                return Card(
                  child: ListTile(
                    title: Text(_contentList[index]['type'] ?? ''),
                    subtitle: Text(_contentList[index]['path'] ?? ''),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () => _deleteContent(index),
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddOptions,
        child: const Icon(Icons.add),
      ),
    );
  }
}
