import 'package:flutter/material.dart';

class CamplistCategoryWidget extends StatelessWidget {
  // Sample list of categories: Personal, Faculty, and Institution
  final List<Map<String, dynamic>> categories = [
    {'icon': Icons.person, 'label': 'Personal'}, // Personal category
    {'icon': Icons.school, 'label': 'Faculty'}, // Faculty category
    {'icon': Icons.business, 'label': 'Institution'}, // Institution category
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
                      color: category['label'] == 'Personal'
                          ? Colors.grey.shade600
                          : Colors.white,
                      border: Border.all(width: 1, color: Colors.grey.shade600),
                      shape: BoxShape.circle),
                  child: Icon(
                    category['icon'],
                    size: 30,
                    color: category['label'] == 'Personal'
                        ? Colors.white
                        : Colors.black, // Icon color
                  ),
                ),
                const SizedBox(height: 8), // Spacing between icon and text
                Text(
                  category['label'], // Dynamic label based on category
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
