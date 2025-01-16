import 'package:flutter/material.dart';

class CategorySelectionScreen extends StatefulWidget {
  const CategorySelectionScreen({super.key, required this.selectedInterests});

  final List<Map<String, dynamic>> selectedInterests;

  @override
  _CategorySelectionScreenState createState() =>
      _CategorySelectionScreenState();
}

class _CategorySelectionScreenState extends State<CategorySelectionScreen> {
  int? selectedCategoryIndex; // Track the selected category
  String? selectedCategory; // Name of the selected category
  Map<String, String?> selectedSubcategories = {}; // Track subcategory selections
  Map<String, int> subcategoryFees = {}; // Track fees for selected subcategories
  String? selectedBatch; // Track selected batch
  String? selectedTime; // Track selected time
  int _tabIndex = 0; // Manage selected bottom bar index

  // Map of categories and their subcategories
  final Map<String, List<String>> subcategories = {
    'Gym': ['Weight Loss', 'Weight Gain', 'Overall Fitness'],
    'Karate': ['Beginner', 'Amateur', 'Mature', 'Pro'],
    'Martial Arts': ['Beginner', 'Intermediate', 'Advanced'],
    'Shooting': ['Handgun', 'Rifle', 'Shotgun'],
    'Boxing': ['Beginner', 'Intermediate', 'Advanced'],
    'Badminton': ['Singles', 'Doubles', 'Mixed Doubles'],
  };

  // Fee details for subcategories
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

  // Total fee calculation
  int get totalFee => subcategoryFees.values.fold(0, (sum, fee) => sum + fee);

  // Method to handle bottom navigation taps
  void _onTabTapped(int index) {
    setState(() {
      _tabIndex = index;
    });
    // Add navigation logic here if needed
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
                if (selectedCategory != null) _buildSubcategoryList(),
                const SizedBox(height: 20),
                if (subcategoryFees.isNotEmpty) _buildTotalFeeSection(),
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

  // Build the category grid
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
              selectedSubcategories.clear();
              subcategoryFees.clear();
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

  // Build the subcategory list
  Widget _buildSubcategoryList() {
    final subcategoryList = subcategories[selectedCategory] ?? [];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Subcategories for $selectedCategory",
          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: subcategoryList.length,
          itemBuilder: (context, index) {
            final subcategory = subcategoryList[index];
            final fee = subcategoryFeesData[subcategory] ?? 0;
            final isSelected = selectedSubcategories.containsKey(subcategory);

            return CheckboxListTile(
              title: Text("$subcategory (₹$fee)"),
              value: isSelected,
              onChanged: (value) {
                setState(() {
                  if (value == true) {
                    selectedSubcategories[subcategory] = subcategory;
                    subcategoryFees[subcategory] = fee;
                  } else {
                    selectedSubcategories.remove(subcategory);
                    subcategoryFees.remove(subcategory);
                  }
                });
              },
            );
          },
        ),
      ],
    );
  }

  // Build the total fee section
  Widget _buildTotalFeeSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Summary",
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        Text("Selected Subcategories: ${selectedSubcategories.keys.join(', ')}"),
        const SizedBox(height: 5),
        Text(
          "Total Fee: ₹$totalFee",
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.green,
          ),
        ),
      ],
    );
  }
}
