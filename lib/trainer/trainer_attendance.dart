import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AttendanceScreen extends StatefulWidget {
  const AttendanceScreen({super.key});

  @override
  _AttendanceScreenState createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends State<AttendanceScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final Map<String, bool> _markedAttendance = {};
  final Map<String, int> _attendanceCounts = {};
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = "";

  @override
  void initState() {
    super.initState();
    _loadInitialAttendanceStatus();
    _loadAttendanceCounts();
  }

  Future<void> _loadInitialAttendanceStatus() async {
    QuerySnapshot attendanceSnapshot = await _firestore.collection('attendance').get();
    for (var doc in attendanceSnapshot.docs) {
      _markedAttendance[doc['userId']] = true;
    }
    setState(() {});
  }

  Future<void> _loadAttendanceCounts() async {
    QuerySnapshot usersSnapshot = await _firestore.collection('users').get();
    for (var userDoc in usersSnapshot.docs) {
      String userId = userDoc.id;
      QuerySnapshot attendanceForUser = await _firestore
          .collection('attendance')
          .where('userId', isEqualTo: userId)
          .get();
      _attendanceCounts[userId] = attendanceForUser.docs.length;
    }
    setState(() {});
  }

  void _addAttendance(String userId) async {
    if (_markedAttendance[userId] == true) return;

    bool confirm = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Attendance'),
        content: const Text('Are you sure you want to mark attendance for this user?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Confirm'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    await _firestore.collection('attendance').add({
      'userId': userId,
      'timestamp': Timestamp.now(),
    });

    setState(() {
      _markedAttendance[userId] = true;
      _attendanceCounts[userId] = (_attendanceCounts[userId] ?? 0) + 1;
    });
  }

  void _removeLastAttendance(String userId) async {
    if (_attendanceCounts[userId] == null || _attendanceCounts[userId] == 0) return;

    QuerySnapshot attendanceSnapshot = await _firestore
        .collection('attendance')
        .where('userId', isEqualTo: userId)
        .orderBy('timestamp', descending: true)
        .limit(1)
        .get();

    if (attendanceSnapshot.docs.isNotEmpty) {
      String docId = attendanceSnapshot.docs.first.id;
      await _firestore.collection('attendance').doc(docId).delete();

      setState(() {
        _attendanceCounts[userId] = _attendanceCounts[userId]! - 1;
        _markedAttendance[userId] = _attendanceCounts[userId]! > 0;
      });
    }
  }

  String _getAttendanceCount(String userId) {
    return 'Attendance Count: ${_attendanceCounts[userId] ?? 0}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Attendance'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search user...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
              onChanged: (query) {
                setState(() {
                  _searchQuery = query.toLowerCase();
                });
              },
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _firestore.collection('users').snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }
                var users = snapshot.data!.docs.where((user) {
                  return user['name'].toString().toLowerCase().contains(_searchQuery);
                }).toList();
                return ListView.builder(
                  itemCount: users.length,
                  itemBuilder: (context, index) {
                    var user = users[index];
                    String userId = user.id;
                    bool isMarked = _markedAttendance[userId] ?? false;
                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                      child: ListTile(
                        title: Text(user['name']),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('User ID: $userId'),
                            Text(_getAttendanceCount(userId)),
                          ],
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.undo, color: Colors.orange),
                              onPressed: isMarked ? () => _removeLastAttendance(userId) : null,
                            ),
                            IconButton(
                              icon: Icon(
                                isMarked ? Icons.check : Icons.add,
                                color: isMarked ? Colors.grey : Colors.green,
                              ),
                              onPressed: () => _addAttendance(userId),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}