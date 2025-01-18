import 'package:fitness_app/user/screens/payment_screen.dart';
import 'package:flutter/material.dart';

class CategorySelectionScreen extends StatefulWidget {
  const CategorySelectionScreen({super.key, required this.selectedInterests});

  final List<Map<String, dynamic>> selectedInterests;

  @override
  _CategorySelectionScreenState createState() =>
      _CategorySelectionScreenState();
}

class _CategorySelectionScreenState extends State<CategorySelectionScreen> {
  int? selectedCategoryIndex;
  String? selectedCategory;
  Map<String, String?> selectedSubcategories = {}; // Track selected subcategory per category
  Map<String, int> subcategoryFees = {}; // Track fees for selected subcategories
  Map<String, String?> selectedTimes = {}; // Track selected time slot per category
  int _tabIndex = 0;

  final Map<String, List<String>> subcategories = {
    'Gym': ['Weight Loss', 'Weight Gain', 'Overall Fitness'],
    'Karate': ['Beginner', 'Amateur', 'Mature', 'Pro'],
    'Martial Arts': ['Beginner', 'Intermediate', 'Advanced'],
    'Shooting': ['Handgun', 'Rifle', 'Shotgun'],
    'Boxing': ['Beginner', 'Intermediate', 'Advanced'],
    'Badminton': ['Singles', 'Doubles', 'Mixed Doubles'],
  };

  final Map<String, int> subcategoryFeesData = {
    'Weight Loss': 1500,
    'Weight Gain': 1800,
    'Overall Fitness': 2000,
    'Beginner': 1200,
    'Amateur': 1500,
    'Mature': 1800,
    'Pro': 2000,
    'Intermediate': 1600,
    'Advanced': 2000,
    'Handgun': 1500,
    'Rifle': 1800,
    'Shotgun': 2000,
    'Singles': 1400,
    'Doubles': 1600,
    'Mixed Doubles': 1800,
  };

  final List<String> timeSlots = ['7 AM - 9 AM', '4 PM - 9 PM'];

  int get totalFee => subcategoryFees.values.fold(0, (sum, fee) => sum + fee);

  void _onTabTapped(int index) {
    setState(() {
      _tabIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Category Selection"),
        backgroundColor: Colors.purple,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),
                const Text(
                  "Select Categories and Subcategories",
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),
                _buildCategoryGrid(),
                const SizedBox(height: 20),
                if (selectedCategory != null) _buildSubcategoryAndTimeSelection(),
                const SizedBox(height: 20),
                if (selectedSubcategories.isNotEmpty) _buildSummarySection(),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _tabIndex,
        selectedItemColor: Colors.purple,
        unselectedItemColor: Colors.grey,
        onTap: _onTabTapped,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: "My Plan",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.event),
            label: "Activities",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: "Profile",
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryGrid() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 20,
        crossAxisSpacing: 20,
        childAspectRatio: 0.9,
      ),
      itemCount: widget.selectedInterests.length,
      itemBuilder: (context, index) {
        final interest = widget.selectedInterests[index];
        return GestureDetector(
          onTap: () {
            setState(() {
              selectedCategoryIndex = index;
              selectedCategory = interest['interest'];
            });
          },
          child: Card(
            color: selectedCategoryIndex == index ? Colors.purple : Colors.white,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    interest['icon'],
                    color: selectedCategoryIndex == index
                        ? Colors.white
                        : Colors.black,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    interest['interest'],
                    style: TextStyle(
                      color: selectedCategoryIndex == index
                          ? Colors.white
                          : Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSubcategoryAndTimeSelection() {
    final subcategoryList = subcategories[selectedCategory] ?? [];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Subcategories and Time Slot for $selectedCategory",
          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        ...subcategoryList.map((subcategory) {
          final fee = subcategoryFeesData[subcategory] ?? 0;
          return RadioListTile<String>(
            title: Text("$subcategory (₹$fee)"),
            value: subcategory,
            groupValue: selectedSubcategories[selectedCategory],
            onChanged: (value) {
              setState(() {
                selectedSubcategories[selectedCategory!] = value;
                subcategoryFees[selectedCategory!] = fee;
              });
            },
          );
        }),
        const SizedBox(height: 20),
        const Text(
          "Select Time Slot",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        ...timeSlots.map((slot) {
          return RadioListTile<String>(
            title: Text(slot),
            value: slot,
            groupValue: selectedTimes[selectedCategory],
            onChanged: (value) {
              setState(() {
                selectedTimes[selectedCategory!] = value;
              });
            },
          );
        }),
      ],
    );
  }

  Widget _buildSummarySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Summary",
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        ...selectedSubcategories.entries.map((entry) {
          final category = entry.key;
          final subcategory = entry.value ?? '';
          final timeSlot = selectedTimes[category] ?? 'Not selected';
          final fee = subcategoryFees[category] ?? 0;
          return Text(
            "$category - $subcategory, Time: $timeSlot, Fee: ₹$fee",
            style: const TextStyle(fontSize: 16),
          );
        }),
        const SizedBox(height: 10),
        Text(
          "Total Fee: ₹$totalFee",
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.green,
          ),
        ),
        const SizedBox(height: 20),
        ElevatedButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => PaymentScreen(
                  summaryDetails: selectedSubcategories,
                  totalFee: totalFee,
                ),
              ),
            );
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.purple,
            padding: const EdgeInsets.symmetric(vertical: 15.0),
          ),
          child: const Center(
            child: Text(
              "Continue to Payment",
              style: TextStyle(fontSize: 18, color: Colors.white),
            ),
          ),
        ),
      ],
    );
  }
}
