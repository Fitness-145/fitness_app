import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class ContentManagement extends StatefulWidget {
  const ContentManagement({super.key});

  @override
  _ContentManagementState createState() => _ContentManagementState();
}

class _ContentManagementState extends State<ContentManagement> {
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final ImagePicker _picker = ImagePicker();

  File? _selectedFile;
  String? _uploadedFileURL;
  final TextEditingController _youtubeController = TextEditingController();
  final List<String> _youtubeLinks = [];
  Map<String, int> _attendanceCounts = {}; // Map to store attendance counts for users

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

  // Function to mark attendance and update count
  Future<void> _markAttendance(String userId) async {
    final attendanceRef = _firestore.collection('attendance');
    final userRef = _firestore.collection('users').doc(userId);

    // Add attendance record
    await attendanceRef.add({
      'userId': userId,
      'startTime': DateTime.now().toIso8601String(),
      'endTime': null, // End time is initially null
      'date': DateTime.now().toIso8601String(),
    });

    // Update attendance count for the user
    final userSnapshot = await userRef.get();
    if (userSnapshot.exists) {
      final currentCount = userSnapshot['attendanceCount'] ?? 0;
      await userRef.update({'attendanceCount': currentCount + 1});
    }
  }

  // Function to load attendance counts for all users
  Future<void> _loadAttendanceCounts() async {
    try {
      // Fetch all users
      QuerySnapshot usersSnapshot = await _firestore.collection('users').get();
      for (var userDoc in usersSnapshot.docs) {
        String userId = userDoc.id;

        // Count the attendance records for each user
        QuerySnapshot attendanceSnapshot = await _firestore
            .collection('attendance')
            .where('userId', isEqualTo: userId)
            .get();

        setState(() {
          _attendanceCounts[userId] = attendanceSnapshot.docs.length;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Error loading attendance counts: $e')));
    }
  }

  @override
  void initState() {
    super.initState();
    _loadAttendanceCounts(); // Load attendance counts on initialization
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
                          _uploadFile(_selectedFile!, 'uploads/${DateTime.now()}'),
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
                    child: Column(
                      children: [
                        GestureDetector(
                          onTap: () {},
                          child: Text(
                            link,
                            style: const TextStyle(
                                color: Colors.blue,
                                decoration: TextDecoration.underline),
                          ),
                        ),
                      ],
                    ),
                  )),
              const SizedBox(height: 30),
              const Text(
                'Attendance Records',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              StreamBuilder(
                stream: _firestore.collection('attendance').snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  final attendanceDocs = snapshot.data!.docs;
                  return FutureBuilder(
                    future: _firestore.collection('users').get(),
                    builder: (context, userSnapshot) {
                      if (!userSnapshot.hasData) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      final usersDocs = userSnapshot.data!.docs;
                      final userMap = {
                        for (var user in usersDocs) user.id: user['name']
                      };

                      return DataTable(
                        columns: const [
                          DataColumn(label: Text('User ID')),
                          DataColumn(label: Text('User Name')),
                          DataColumn(label: Text('Start Time')),
                          DataColumn(label: Text('End Time')),
                          DataColumn(label: Text('Attendance Count')),
                        ],
                        rows: attendanceDocs.map((doc) {
                          final userId = doc['userId'];
                          return DataRow(cells: [
                            DataCell(Text(userId)),
                            DataCell(Text(userMap[userId] ?? 'Unknown')),
                            DataCell(Text(doc['startTime'].toString())),
                            DataCell(Text(doc['endTime'] ?? 'N/A')),
                            DataCell(Text(_attendanceCounts[userId]?.toString() ?? '0')),
                          ]);
                        }).toList(),
                      );
                    },
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
