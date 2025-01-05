import 'package:flutter/material.dart';
import 'package:iconly/iconly.dart';

class CamplistCategoryWidget extends StatelessWidget {
  // List of categories with icons
  final List<Map<String, dynamic>> categories = [
    {'icon': Icons.person_4, 'label': 'Mine'},
    {'icon': Icons.school, 'label': 'Faculty'},
    {'icon': Icons.business, 'label': 'Institution'},
  ];

  final String activeCategory;
  final void Function(String category)? onCategoryTap;

  CamplistCategoryWidget({
    Key? key,
    this.activeCategory = 'Mine', // Default active category
    this.onCategoryTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Container(
      padding: const EdgeInsets.only(top: 10),
      margin: const EdgeInsets.only(bottom: 10),
      height: 45, // Adjusted height to fit icon and text
      width: screenWidth,
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.grey.shade300, width: 1),
        ),
      ),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final category = categories[index];
          return _buildCategoryItem(
            category['label'],
            icon: category['icon'],
            isActive: category['label'] == activeCategory,
          );
        },
      ),
    );
  }

  Widget _buildCategoryItem(String label,
      {required IconData icon, bool isActive = false}) {
    return GestureDetector(
      onTap: () {
        if (onCategoryTap != null) {
          onCategoryTap!(label); // Pass the label back on tap
        }
      },
      child: Padding(
        padding: const EdgeInsets.only(left: 20, right: 10),
        child: Container(
          decoration: isActive
              ? BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      width: 3,
                      color: const Color(0xFFBA9E02), // Active underline color
                    ),
                  ),
                )
              : null,
          child: Column(
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Icon(
                  //   icon,
                  //   color: isActive ? Colors.black : Colors.grey.shade600,
                  //   size: 20,
                  // ),
                  // const SizedBox(width: 5),
                  Text(
                    label,
                    style: TextStyle(
                      fontFamily: 'Lato',
                      fontSize: 14,
                      fontWeight:
                          isActive ? FontWeight.bold : FontWeight.normal,
                      color: isActive ? Colors.black : Colors.grey.shade600,
                    ),
                  ),
                  // const SizedBox(width: 5),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
