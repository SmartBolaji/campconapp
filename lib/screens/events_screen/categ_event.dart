import 'package:flutter/material.dart';

class CategoriesWidget extends StatelessWidget {
  // Sample list of categories
  // Updated list of categories with "All" added
  final List<Map<String, dynamic>> categories = [
    {'icon': Icons.category, 'label': 'All'}, // "All" category
    {'icon': Icons.videogame_asset, 'label': 'Gaming'},
    {'icon': Icons.palette, 'label': 'Arts'},
    {'icon': Icons.business_center, 'label': 'Business'},
    {'icon': Icons.checkroom, 'label': 'Fashion'},
    {'icon': Icons.sports, 'label': 'Sports'},
    {'icon': Icons.movie, 'label': 'Movies'},
    {'icon': Icons.music_note, 'label': 'Music'},
    {'icon': Icons.science, 'label': 'Science'},
    {'icon': Icons.travel_explore, 'label': 'Travel'},
    {'icon': Icons.food_bank, 'label': 'Food'},
  ];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 120, // Adjust height based on your layout needs
      child: ListView.builder(
        padding: const EdgeInsets.only(top: 20),
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final category = categories[index];
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15.0),
            child: Column(
              children: [
                Container(
                  height: 60,
                  width: 60,
                  decoration: BoxDecoration(
                      color: category['label'] == 'All'
                          ? Colors.grey.shade600
                          : Colors.white,
                      border: Border.all(width: 1, color: Colors.grey.shade600),
                      shape: BoxShape.circle),
                  child: Icon(
                    category['icon'],
                    size: 30,
                    color: category['label'] == 'All'
                        ? Colors.white
                        : Colors.black, // Icon color
                  ),
                ),
                const SizedBox(height: 8), // Spacing between icon and text
                Text(
                  category['label'],
                  style: const TextStyle(
                    fontSize: 12,
                    fontFamily: 'Trebuchet',
                    fontWeight: FontWeight.w500,
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
