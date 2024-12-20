import 'package:fitness_app/user/screens/category_screen.dart';
import 'package:flutter/material.dart';

class CustomizeInterestsScreen extends StatefulWidget {
  @override
  _CustomizeInterestsScreenState createState() => _CustomizeInterestsScreenState();
}

class _CustomizeInterestsScreenState extends State<CustomizeInterestsScreen> {
  // Track selected interests
  final List<Map<String, dynamic>> interests = [
    {'interest': 'Gym', 'icon': Icons.fitness_center, 'selected': false},
    {'interest': 'Karate', 'icon': Icons.sports_kabaddi, 'selected': false},
    {'interest': 'Martial Arts', 'icon': Icons.sports_mma, 'selected': false},
    {'interest': 'Badminton', 'icon': Icons.sports_tennis, 'selected': false},
    {'interest': 'Shooting', 'icon': Icons.sports_esports, 'selected': false},
    {'interest': 'Boxing', 'icon': Icons.sports_mma, 'selected': false},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            // Progress indicator
            LinearProgressIndicator(
              value: 0.5,
              backgroundColor: Colors.grey[300],
              valueColor: AlwaysStoppedAnimation<Color>(Colors.purple),
            ),
            SizedBox(height: 20),

            // Title
            Text(
              'Time to customize your interests',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 20),

            // Interest options
            Expanded(
              child: GridView.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  childAspectRatio: .9,
                  mainAxisSpacing: 10,
                  crossAxisSpacing: 10,
                ),
                itemCount: interests.length,
                itemBuilder: (context, index) {
                  final interest = interests[index];
                  bool isSelected = interest['selected'];

                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        interest['selected'] = !isSelected;
                      });
                    },
                    child: Column(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: isSelected ? Colors.purple[100] : Colors.white,
                            border: Border.all(
                              color: isSelected ? Colors.purple : Colors.grey,
                              width: 2,
                            ),
                          ),
                          padding: EdgeInsets.all(20),
                          child: Icon(
                            interest['icon'],
                            color: isSelected ? Colors.purple : Colors.grey,
                            size: 40,
                          ),
                        ),
                        SizedBox(height: 5),
                        Text(interest['interest'], style: TextStyle(fontSize: 14)),
                      ],
                    ),
                  );
                },
              ),
            ),

            // Continue button
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Create a list of selected interests as a list of maps
                List<Map<String, dynamic>> selectedInterests = interests
                    .where((interest) => interest['selected'])
                    .toList();

                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CategorySelectionScreen(selectedInterests: selectedInterests,),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.purple,
                padding: EdgeInsets.symmetric(horizontal: 100, vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              child: Text('Continue', style: TextStyle(color: Colors.white)),
            ),
            
            
            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
