import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class PlanPage extends StatelessWidget {
  PlanPage({super.key});

  final String userId = FirebaseAuth.instance.currentUser?.uid ?? "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("My Plan"),
        backgroundColor: Colors.purple,
        elevation: 0,
      ),
      body: FutureBuilder<QuerySnapshot>(
        future: FirebaseFirestore.instance
            .collection('my_plan')
            .where('userId', isEqualTo: userId)
            .get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("No plan found."));
          }

          var planDoc = snapshot.data!.docs.first;
          var planData = planDoc.data() as Map<String, dynamic>;

          var selectedSubcategories =
              planData['selectedSubcategories'] as Map<String, dynamic>? ?? {};
          var selectedTimes =
              planData['selectedTimes'] as Map<String, dynamic>? ?? {};

          int totalFee = planData['totalFee'] ?? 0;

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Total Fee: ₹$totalFee',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
                const SizedBox(height: 20),
                Expanded(
                  child: ListView(
                    children: selectedSubcategories.keys.map((category) {
                      String subcategory =
                          selectedSubcategories[category] ?? "";
                      String timeSlot = selectedTimes[category] ?? "";

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Category: $category',
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.purple,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Subcategory: $subcategory',
                            style: TextStyle(
                                fontSize: 18, color: Colors.grey[600]),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Time Slot: $timeSlot',
                            style: TextStyle(
                                fontSize: 18, color: Colors.grey[600]),
                          ),
                          const SizedBox(height: 20),
                          FutureBuilder<QuerySnapshot>(
                            future: FirebaseFirestore.instance
                                .collection('workout_plans')
                                .where('category', isEqualTo: category)
                                .where('subcategory', isEqualTo: subcategory)
                                .get(),
                            builder: (context, workoutSnapshot) {
                              if (workoutSnapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return const Center(
                                    child: CircularProgressIndicator());
                              }
                              if (!workoutSnapshot.hasData ||
                                  workoutSnapshot.data!.docs.isEmpty) {
                                return const Center(
                                    child: Text("No workout plans available."));
                              }

                              var workoutPlans =
                                  workoutSnapshot.data!.docs.map((doc) {
                                var data = doc.data() as Map<String, dynamic>;
                                return WorkoutPlan(
                                  name: data['name'] ?? '',
                                  description: data['description'] ?? '',
                                  sets: data['sets'] ?? '',
                                  reps: data['reps'] ?? '',
                                );
                              }).toList();

                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: workoutPlans.map((workoutPlan) {
                                  return WorkoutCard(workoutPlan: workoutPlan);
                                }).toList(),
                              );
                            },
                          ),
                          const SizedBox(height: 20),
                        ],
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class WorkoutPlan {
  final String name;
  final String description;
  final String sets;
  final String reps;

  WorkoutPlan({
    required this.name,
    required this.description,
    required this.sets,
    required this.reps,
  });
}

class WorkoutCard extends StatelessWidget {
  final WorkoutPlan workoutPlan;

  const WorkoutCard({super.key, required this.workoutPlan});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      elevation: 5,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              workoutPlan.name,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.purple,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              workoutPlan.description,
              style: TextStyle(fontSize: 16, color: Colors.grey[700]),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Sets: ${workoutPlan.sets}',
                  style: TextStyle(fontSize: 14, color: Colors.purple[600]),
                ),
                Text(
                  'Reps: ${workoutPlan.reps}',
                  style: TextStyle(fontSize: 14, color: Colors.purple[600]),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
