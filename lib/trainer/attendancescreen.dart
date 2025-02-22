import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';

class AttendanceScreen extends StatefulWidget {
  @override
  _AttendanceScreenState createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends State<AttendanceScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final Set<String> _markedAttendance = {}; // Track marked attendances
  final Map<String, int> _attendanceCounts = {}; // Track attendance counts for each user

  @override
  void initState() {
    super.initState();
    _loadInitialAttendanceStatus();
    _loadAttendanceCounts();
  }

  Future<void> _loadInitialAttendanceStatus() async {
    // Load already marked attendances to reflect correctly on UI restart
    QuerySnapshot attendanceSnapshot = await _firestore.collection('attendance').get();
    attendanceSnapshot.docs.forEach((doc) {
      _markedAttendance.add(doc['userId']);
    });
    setState(() {}); // Refresh UI to show initial marked status
  }

  Future<void> _loadAttendanceCounts() async {
    // Load attendance counts for each user
    QuerySnapshot usersSnapshot = await _firestore.collection('users').get();
    for (var userDoc in usersSnapshot.docs) {
      String userId = userDoc.id;
      QuerySnapshot attendanceForUser = await _firestore
          .collection('attendance')
          .where('userId', isEqualTo: userId)
          .get();
      _attendanceCounts[userId] = attendanceForUser.docs.length;
    }
    setState(() {}); // Refresh UI to show attendance counts
  }

  void _addAttendance(String userId) async {
    if (_markedAttendance.contains(userId)) return;

    // Show confirmation dialog
    bool confirm = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Confirm Attendance'),
        content: Text('Are you sure you want to mark attendance for this user?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text('Confirm'),
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
      _markedAttendance.add(userId);
      _attendanceCounts[userId] = (_attendanceCounts[userId] ?? 0) + 1; // Increment count
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Attendance added for user $userId')),
    );
  }

  void _removeLastAttendance(String userId) async {
    if (!_markedAttendance.contains(userId)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No attendance marked for user $userId to undo')),
      );
      return;
    }

    // Find the last attendance record for this user and delete it
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
        _markedAttendance.remove(userId);
        _attendanceCounts[userId] = (_attendanceCounts[userId] ?? 1) - 1; // Decrement count
         if (_attendanceCounts[userId]! < 0) _attendanceCounts[userId] = 0; // Ensure count doesn't go below zero
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Attendance undone for user $userId')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No attendance record found to undo for user $userId')),
      );
    }
  }

  String _getAttendancePercentage(String userId) {
    int count = _attendanceCounts[userId] ?? 0;
    return 'Attendance Count: $count';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Attendance')),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore.collection('users').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }
          var users = snapshot.data!.docs;
          return ListView.builder(
            itemCount: users.length,
            itemBuilder: (context, index) {
              var user = users[index];
              String userId = user.id;
              bool isMarked = _markedAttendance.contains(userId);

              return Card(
                margin: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                child: ListTile(
                  title: Text(user['name']),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('User ID: $userId'),
                      Text(_getAttendancePercentage(userId)), // Display attendance count
                    ],
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(Icons.undo, color: Colors.orange), // Undo icon
                        onPressed: isMarked ? () => _removeLastAttendance(userId) : null, // Enable undo only if marked
                      ),
                      IconButton(
                        icon: Icon(
                          isMarked ? Icons.check : Icons.add,
                          color: isMarked ? Colors.grey : Colors.green,
                        ),
                        onPressed: isMarked ? null : () => _addAttendance(userId),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}