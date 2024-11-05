import 'package:flutter/material.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: CategorySelectionScreen(),
    );
  }
}

class CategorySelectionScreen extends StatefulWidget {
  @override
  _CategorySelectionScreenState createState() =>
      _CategorySelectionScreenState();
}

class _CategorySelectionScreenState extends State<CategorySelectionScreen> {
  int selectedIndex = -1; // Tracks the selected option
  List<String> selectedCategories = []; // List to store previous selections

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                "Selected Categories",
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  buildOption(0, "Category 1", "assets/option1.png"),
                  buildOption(1, "Category 2", "assets/option2.png"),
                  buildOption(2, "Category 3", "assets/option3.png"),
                ],
              ),
              const SizedBox(height: 20),
              Expanded(
                child: ListView.builder(
                  itemCount: selectedCategories.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      leading: Icon(Icons.category, color: Colors.purple),
                      title: Text(selectedCategories[index]),
                    );
                  },
                ),
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: () {
                  // Handle continue action
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.purple,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 80, vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  "Continue",
                  style: TextStyle(fontSize: 18, color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildOption(int index, String label, String imagePath) {
    return GestureDetector(
      onTap: () {
        setState(() {
          if (!selectedCategories.contains(label)) { // Check if category is already selected
            selectedIndex = index;
            selectedCategories.add(label); // Add the selected category to the list
          }
        });
      },
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(8.0),
            decoration: BoxDecoration(
              color: selectedIndex == index ? Colors.purple.shade50 : Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: selectedCategories.contains(label)
                    ? Colors.purple // Change border color if selected
                    : Colors.grey.shade300,
                width: 2,
              ),
            ),
            child: Image.asset(
              imagePath,
              width: 70,
              height: 70,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              color: selectedCategories.contains(label) ? Colors.purple : Colors.black,
            ),
          ),
        ],
      ),
    );
  }
}
