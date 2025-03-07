import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
// Import intl package for date formatting

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
    try {
      QuerySnapshot attendanceSnapshot =
          await _firestore.collection('attendance').get();
      for (var doc in attendanceSnapshot.docs) {
        DateTime attendanceDate = (doc['startTime'] as Timestamp).toDate();
        DateTime todayStart = DateTime(
            attendanceDate.year, attendanceDate.month, attendanceDate.day);
        DateTime todayEnd = todayStart.add(const Duration(days: 1));

        DateTime now = DateTime.now();
        if (now.isAfter(todayStart) && now.isBefore(todayEnd)) {
          _markedAttendance[doc['userId']] = true;
        }
      }
      setState(() {});
    } catch (e) {
      _showSnackBar('Error loading initial attendance status: $e');
    }
  }

  Future<void> _loadAttendanceCounts() async {
    try {
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
    } catch (e) {
      _showSnackBar('Error loading attendance counts: $e');
    }
  }

  // Function to mark attendance for today
  void _addAttendance(String userId) async {
    if (_markedAttendance[userId] == true) {
      _showSnackBar('Attendance already marked for today.');
      return;
    }

    bool? confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Attendance'),
        content:
            const Text('Are you sure you want to mark attendance for today?'),
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

    if (confirm != true || confirm == null) {
      return;
    }

    DateTime currentTime = DateTime.now();

    try {
      // Save today's attendance with current time
      await _firestore.collection('attendance').add({
        'userId': userId,
        'timestamp': Timestamp.now(),
        'startTime': Timestamp.fromDate(currentTime), // Save start time
      });

      setState(() {
        _markedAttendance[userId] = true;
        _attendanceCounts[userId] = (_attendanceCounts[userId] ?? 0) + 1;
      });
      _showSnackBar(
          'Attendance marked successfully for ${userId.substring(0, 5)}...');
    } catch (e) {
      _showSnackBar('Error marking attendance: $e');
    }
  }

  // Function to remove last attendance for today
  void _removeLastAttendance(String userId) async {
    if (_attendanceCounts[userId] == null || _attendanceCounts[userId] == 0) {
      _showSnackBar('No attendance records to remove for this user.');
      return;
    }

    try {
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
        _showSnackBar(
            'Last attendance record removed for ${userId.substring(0, 5)}...');
      } else {
        _showSnackBar('No attendance record found to remove.');
      }
    } catch (e) {
      _showSnackBar('Error removing last attendance: $e');
    }
  }

  String _getAttendanceCount(String userId) {
    return 'Attendance Count: ${_attendanceCounts[userId] ?? 0}';
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
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
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }
                var users = snapshot.data!.docs.where((user) {
                  return user['name']
                      .toString()
                      .toLowerCase()
                      .contains(_searchQuery);
                }).toList();
                if (users.isEmpty && _searchQuery.isNotEmpty) {
                  return const Center(child: Text('No users found.'));
                }
                return ListView.builder(
                  itemCount: users.length,
                  itemBuilder: (context, index) {
                    var user = users[index];
                    String userId = user.id;
                    bool isMarked = _markedAttendance[userId] ?? false;
                    return Card(
                      margin: const EdgeInsets.symmetric(
                          vertical: 4, horizontal: 8),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor:
                              isMarked ? Colors.green : Colors.grey,
                          child: Icon(
                              isMarked ? Icons.check : Icons.person_outline,
                              color: Colors.white),
                        ),
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
                              icon:
                                  const Icon(Icons.undo, color: Colors.orange),
                              tooltip: 'Remove Last Attendance',
                              onPressed: isMarked
                                  ? () => _removeLastAttendance(userId)
                                  : null,
                            ),
                            IconButton(
                              icon: Icon(
                                isMarked
                                    ? Icons.check_circle
                                    : Icons.add_circle,
                                size: 30,
                                color: isMarked ? Colors.green : Colors.blue,
                              ),
                              tooltip: isMarked
                                  ? 'Attendance Marked'
                                  : 'Mark Attendance',
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