 
import 'package:fitness_app/admin/usermanage.dart';
 
import 'package:flutter/material.dart';

import 'ContentManagement.dart';
import 'subscription_tracking.dart';
import 'reports_analytics.dart';

class AdminDashboard extends StatelessWidget {
  const AdminDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Admin Dashboard"),
        centerTitle: true,
        backgroundColor: Colors.deepPurple,
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: GridView(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
          ),
          children: [
            _buildCard(context, "User Management", Icons.person,
                const UserManagement()),
            _buildCard(context, "Workout & Diet", Icons.fitness_center,
                const ContentManagement()),
            _buildCard(context, "Subscription Tracking", Icons.payment,
                const SubscriptionTracking()),
            _buildCard(context, "Reports & Analytics", Icons.analytics,
                const ReportsAnalytics()),
          ],
        ),
      ),
    );
  }

  Widget _buildCard(
      BuildContext context, String title, IconData icon, Widget route) {
    return Card(
      elevation: 6,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: InkWell(
        borderRadius: BorderRadius.circular(15),
        onTap: () {
          Navigator.push(
            context,
            PageRouteBuilder(
              pageBuilder: (context, animation, secondaryAnimation) => route,
              transitionsBuilder:
                  (context, animation, secondaryAnimation, child) {
                return FadeTransition(opacity: animation, child: child);
              },
            ),
          );
        },
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 55, color: Colors.deepPurple),
            const SizedBox(height: 10),
            Text(title,
                textAlign: TextAlign.center,
                style:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}
