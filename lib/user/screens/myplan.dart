import 'package:flutter/material.dart';

class PlanPage extends StatelessWidget {
  final String subcategoryName;
  final String subcategoryDescription;
  final List<WorkoutPlan> workoutPlans;

  const PlanPage({
    super.key,
    required this.subcategoryName,
    required this.subcategoryDescription,
    required this.workoutPlans,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(subcategoryName),
        backgroundColor: Colors.purple,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Subcategory Description Section
            Text(
              'Category: $subcategoryName',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.purple,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              subcategoryDescription,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 20),

            // Workout Plan Section
            const Text(
              'Workout Plan:',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.purple,
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                itemCount: workoutPlans.length,
                itemBuilder: (context, index) {
                  return WorkoutCard(workoutPlan: workoutPlans[index]);
                },
              ),
            ),
          ],
        ),
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
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[700],
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Sets: ${workoutPlan.sets}',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.purple[600],
                  ),
                ),
                Text(
                  'Reps: ${workoutPlan.reps}',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.purple[600],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
