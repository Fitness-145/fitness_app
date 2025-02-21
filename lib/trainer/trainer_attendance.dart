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

  @override
  void initState() {
    super.initState();
    _loadTrainees();
  }

  Future<void> _loadTrainees() async {
    User? trainerUser = _auth.currentUser;
    if (trainerUser != null) {
      // Assuming you have a 'trainers' collection and each trainer document has 'trainees' subcollection
      final traineeSnapshot = await _firestore
          .collection('trainers')
          .doc(trainerUser.uid)
          .collection('trainees')
          .get();

      setState(() {
        trainees = traineeSnapshot.docs.map((doc) {
          return doc.data() as Map<String, dynamic>; // Cast to Map<String, dynamic>
        }).toList();
      });
    }
  }

  Future<void> _markAttendance(String traineeId, bool isPresent) async {
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
          .set({'isPresent': isPresent, 'timestamp': Timestamp.fromDate(now)}, SetOptions(merge: true)); // Merge to avoid overwriting other fields if any

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Attendance marked successfully for trainee ID: $traineeId')),
      );
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
                return Card(
                  margin: const EdgeInsets.all(8.0),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(trainee['name'] ?? 'Trainee Name'), // Assuming 'name' field in trainee data
                        Row(
                          children: [
                            ElevatedButton(
                              onPressed: () => _markAttendance(trainee['traineeId'], true), // Assuming 'traineeId' field
                              style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                              child: const Text("Present"),
                            ),
                            const SizedBox(width: 8),
                            ElevatedButton(
                              onPressed: () => _markAttendance(trainee['traineeId'], false),
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