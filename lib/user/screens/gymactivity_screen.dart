import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class MyActivitiesPage extends StatefulWidget {
  const MyActivitiesPage({super.key});

  @override
  _MyActivitiesPageState createState() => _MyActivitiesPageState();
}

class _MyActivitiesPageState extends State<MyActivitiesPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  late Stream<QuerySnapshot> activitiesStream;

  @override
  void initState() {
    super.initState();
    
    // Set up stream to listen for updates from Firebase Firestore
    activitiesStream = _firestore
        .collection('users')
        .doc(_auth.currentUser!.uid)
        .collection('myPlans')
        .snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("My Activities Progress"),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: activitiesStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("No activities found."));
          }

          var activities = snapshot.data!.docs;

          return ListView.builder(
            itemCount: activities.length,
            itemBuilder: (context, index) {
              var activity = activities[index];
              double progress = activity['progress'].toDouble();
              double target = activity['target'].toDouble();
              double progressPercentage = (progress / target) * 100;

              return Card(
                margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                child: Padding(
                  padding: const EdgeInsets.all(15.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        activity['activityName'],
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Text(
                            "Progress: ${progress.toStringAsFixed(0)} / ${target.toStringAsFixed(0)}",
                          ),
                          const Spacer(),
                          Text("${progressPercentage.toStringAsFixed(0)}%"),
                        ],
                      ),
                      const SizedBox(height: 10),
                      LinearProgressIndicator(
                        value: progressPercentage / 100,
                        color: Colors.blue,
                        backgroundColor: Colors.grey[300],
                      ),
                      const SizedBox(height: 15),
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
