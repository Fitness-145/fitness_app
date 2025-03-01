import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class TrainerAttendance extends StatefulWidget {
  const TrainerAttendance({super.key});

  @override
  State<TrainerAttendance> createState() => _TrainerAttendanceState();
}

class _TrainerAttendanceState extends State<TrainerAttendance> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<Map<String, dynamic>> trainees = []; // Store trainees data
  Map<String, bool> attendanceMarked = {}; // Track if attendance has been marked for each trainee

  @override
  void initState() {
    super.initState();
    _loadTrainees();
  }

  // Load trainees data from Firestore
  Future<void> _loadTrainees() async {
    try {
      User? trainerUser = _auth.currentUser;
      if (trainerUser != null) {
        final traineeSnapshot = await _firestore
            .collection('trainers')
            .doc(trainerUser.uid)
            .collection('trainees')
            .get();

        if (traineeSnapshot.docs.isEmpty) {
          throw 'No trainees found';
        }

        setState(() {
          trainees = traineeSnapshot.docs.map((doc) {
            return doc.data();
          }).toList();
        });
      }
    } catch (error) {
      print('Error loading trainees: $error');
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Error loading trainees')));
    }
  }

  // Mark attendance for a trainee
  Future<void> _markAttendance(String traineeId, bool isPresent) async {
    try {
      User? trainerUser = _auth.currentUser;
      if (trainerUser != null) {
        DateTime now = DateTime.now();
        DateTime today = DateTime(now.year, now.month, now.day); // Get date without time

        await _firestore
            .collection('trainer_attendance')
            .doc(trainerUser.uid)
            .collection('attendance_records')
            .doc(today.toString()) // Use date as document ID
            .collection('trainee_attendance')
            .doc(traineeId)
            .set({
              'isPresent': isPresent,
              'timestamp': Timestamp.fromDate(now),
            }, SetOptions(merge: true)); // Merge to avoid overwriting other fields

        // Update the attendance status in the app
        setState(() {
          attendanceMarked[traineeId] = true; // Mark the attendance as recorded
        });

        // Update the trainee's attendance count
        await _updateAttendanceCount(traineeId, isPresent);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Attendance marked successfully for trainee ID: $traineeId')),
        );
      }
    } catch (error) {
      print('Error marking attendance: $error');
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Error marking attendance')));
    }
  }

  // Undo attendance marking
  Future<void> _undoAttendance(String traineeId) async {
    try {
      User? trainerUser = _auth.currentUser;
      if (trainerUser != null) {
        DateTime now = DateTime.now();
        DateTime today = DateTime(now.year, now.month, now.day); // Get date without time

        await _firestore
            .collection('trainer_attendance')
            .doc(trainerUser.uid)
            .collection('attendance_records')
            .doc(today.toString()) // Use date as document ID
            .collection('trainee_attendance')
            .doc(traineeId)
            .delete(); // Delete the attendance record

        // Update the attendance status in the app
        setState(() {
          attendanceMarked[traineeId] = false; // Reset attendance status
        });

        // Update the trainee's attendance count to reduce by 1
        await _updateAttendanceCount(traineeId, false);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Attendance undone for trainee ID: $traineeId')),
        );
      }
    } catch (error) {
      print('Error undoing attendance: $error');
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Error undoing attendance')));
    }
  }

  // Update attendance count in Firestore (Add or Reduce 1)
  Future<void> _updateAttendanceCount(String traineeId, bool isPresent) async {
    try {
      User? trainerUser = _auth.currentUser;
      if (trainerUser != null) {
        final traineeRef = _firestore.collection('trainers').doc(trainerUser.uid)
            .collection('trainees').doc(traineeId);

        // Fetch current attendance data
        final traineeDoc = await traineeRef.get();

        if (traineeDoc.exists) {
          int attendanceCount = traineeDoc.data()?['attendanceCount'] ?? 0;

          if (isPresent) {
            // If present, increase attendance count
            attendanceCount++;
          } else {
            // If undone, decrease attendance count
            attendanceCount = attendanceCount > 0 ? attendanceCount - 1 : 0;
          }

          // Update Firestore with new attendance count
          await traineeRef.update({
            'attendanceCount': attendanceCount,
          });

          // Update the UI to reflect the new count
          setState(() {
            trainees = trainees.map((trainee) {
              if (trainee['traineeId'] == traineeId) {
                trainee['attendanceCount'] = attendanceCount; // Update count in the local list
              }
              return trainee;
            }).toList();
          });
        } else {
          throw 'Trainee document not found';
        }
      }
    } catch (error) {
      print('Error updating attendance count: $error');
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Error updating attendance count')));
    }
  }

  // Get attendance percentage for a trainee
  Future<double> _getAttendancePercentage(String traineeId) async {
    try {
      User? trainerUser = _auth.currentUser;
      if (trainerUser != null) {
        final traineeDoc = await _firestore
            .collection('trainers')
            .doc(trainerUser.uid)
            .collection('trainees')
            .doc(traineeId)
            .get();

        if (traineeDoc.exists) {
          int totalClasses = traineeDoc.data()?['totalClasses'] ?? 0;
          int attendedClasses = traineeDoc.data()?['attendanceCount'] ?? 0;

          if (totalClasses == 0) {
            return 0.0; // No classes yet
          }
          return (attendedClasses / totalClasses) * 100; // Calculate percentage
        } else {
          throw 'Trainee document not found';
        }
      }
      return 0.0;
    } catch (error) {
      print('Error fetching attendance percentage: $error');
      return 0.0;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Attendance Management"),
        backgroundColor: Colors.teal,
      ),
      body: trainees.isEmpty
          ? const Center(child: Text("No trainees assigned yet."))
          : ListView.builder(
              itemCount: trainees.length,
              itemBuilder: (context, index) {
                final trainee = trainees[index];
                final traineeId = trainee['traineeId'];
                final isMarked = attendanceMarked[traineeId] ?? false;

                return Card(
                  margin: const EdgeInsets.all(8.0),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(trainee['name'] ?? 'Trainee Name'),
                            FutureBuilder<double>(
                              future: _getAttendancePercentage(traineeId),
                              builder: (context, snapshot) {
                                if (snapshot.connectionState == ConnectionState.waiting) {
                                  return const CircularProgressIndicator();
                                }
                                final attendancePercentage = snapshot.data ?? 0.0;
                                return Text('Attendance: ${attendancePercentage.toStringAsFixed(2)}%');
                              },
                            ),
                            Text('Attendance Count: ${trainee['attendanceCount'] ?? 0}'),
                          ],
                        ),
                        Row(
                          children: [
                            if (!isMarked) // Show "+" button if attendance is not marked
                              ElevatedButton(
                                onPressed: () => _markAttendance(traineeId, true),
                                style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                                child: const Text("Present"),
                              ),
                            if (isMarked) // Show "Undo" button if attendance is marked
                              ElevatedButton(
                                onPressed: () => _undoAttendance(traineeId),
                                style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
                                child: const Text("Undo"),
                              ),
                            const SizedBox(width: 8),
                            if (!isMarked) // Show "-" button for "Absent"
                              ElevatedButton(
                                onPressed: () => _markAttendance(traineeId, false),
                                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                                child: const Text("Absent"),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}