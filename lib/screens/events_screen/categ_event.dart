import 'package:flutter/material.dart';
import 'package:iconly/iconly.dart';

class CategoriesWidget extends StatelessWidget {
  // Updated list of categories with icons
  final List<Map<String, dynamic>> categories = [
    {
      'icon': Icons.local_fire_department,
      'label': 'Hot'
    }, // Replaced fire icon with discovery
    {'icon': IconlyBold.game, 'label': 'Gaming'}, // Game icon available
    {'icon': Icons.palette, 'label': 'Arts'}, // Replaced palette with edit
    {
      'icon': IconlyBold.work,
      'label': 'Business'
    }, // Replaced briefcase with work
    {'icon': Icons.checkroom, 'label': 'Fashion'}, // Closest match for closet
    {'icon': Icons.sports, 'label': 'Sports'},
    {'icon': IconlyBold.video, 'label': 'Movies'}, // Video icon available
    {'icon': IconlyBold.voice, 'label': 'Music'}, // Replaced music with voice
    {
      'icon': IconlyBold.discovery,
      'label': 'Science'
    }, // Discovery icon fits science
    {'icon': Icons.travel_explore, 'label': 'Travel'},
    {'icon': Icons.food_bank, 'label': 'Food'},
  ];

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Container(
      padding: const EdgeInsets.only(top: 10),
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
            isActive: category['label'] == 'Hot', // Default active item
          );
        },
      ),
    );
  }

  Widget _buildCategoryItem(String label,
      {required IconData icon, bool isActive = false}) {
    return GestureDetector(
      onTap: () {
        // Add your onTap functionality here
      },
      child: Padding(
        padding: const EdgeInsets.only(left: 20, right: 10),
        child: Container(
          // margin: EdgeInsets.only(bottom: 5),
          decoration: isActive
              ? BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      width: 3,
                      color: isActive
                          ? const Color(0xFFBA9E02)
                          : Colors.transparent,
                    ),
                  ),
                )
              : null,
          child: Column(
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    icon,
                    color: isActive ? Colors.black : Colors.grey.shade600,
                    size: 20,
                  ),
                  const SizedBox(width: 5),
                  Text(
                    label,
                    style: TextStyle(
                      fontFamily: 'Trebuchet',
                      fontSize: 14,
                      fontWeight:
                          isActive ? FontWeight.bold : FontWeight.normal,
                      color: isActive ? Colors.black : Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(width: 5),
                ],
              ),
              // if (isActive)
              //   Container(
              //     margin: const EdgeInsets.only(top: 5),
              //     width: 65,
              //     height: 3,
              //     color: const Color(0xFFBA9E02),
              //   ),
            ],
          ),
        ),
      ),
    );
  }
}




// import 'package:flutter/material.dart';

// class CategoriesWidget extends StatelessWidget {
//   // Sample list of categories
//   // Updated list of categories with "All" added
//   final List<Map<String, dynamic>> categories = [
//     {'icon': Icons.category, 'label': 'All'}, // "All" category
//     {'icon': Icons.videogame_asset, 'label': 'Gaming'},
//     {'icon': Icons.palette, 'label': 'Arts'},
//     {'icon': Icons.business_center, 'label': 'Business'},
//     {'icon': Icons.checkroom, 'label': 'Fashion'},
//     {'icon': Icons.sports, 'label': 'Sports'},
//     {'icon': Icons.movie, 'label': 'Movies'},
//     {'icon': Icons.music_note, 'label': 'Music'},
//     {'icon': Icons.science, 'label': 'Science'},
//     {'icon': Icons.travel_explore, 'label': 'Travel'},
//     {'icon': Icons.food_bank, 'label': 'Food'},
//   ];

//   @override
//   Widget build(BuildContext context) {
//     return SizedBox(
//       height: 120, // Adjust height based on your layout needs
//       child: ListView.builder(
//         padding: const EdgeInsets.only(top: 20),
//         scrollDirection: Axis.horizontal,
//         itemCount: categories.length,
//         itemBuilder: (context, index) {
//           final category = categories[index];
//           return Padding(
//             padding: const EdgeInsets.symmetric(horizontal: 15.0),
//             child: Column(
//               children: [
//                 Container(
//                   height: 60,
//                   width: 60,
//                   decoration: BoxDecoration(
//                       color: category['label'] == 'All'
//                           ? Colors.grey.shade600
//                           : Colors.white,
//                       border: Border.all(width: 1, color: Colors.grey.shade600),
//                       shape: BoxShape.circle),
//                   child: Icon(
//                     category['icon'],
//                     size: 30,
//                     color: category['label'] == 'All'
//                         ? Colors.white
//                         : Colors.black, // Icon color
//                   ),
//                 ),
//                 const SizedBox(height: 8), // Spacing between icon and text
//                 Text(
//                   category['label'],
//                   style: const TextStyle(
//                     fontSize: 12,
//                     fontFamily: 'Trebuchet',
//                     fontWeight: FontWeight.w500,
//                   ),
//                 ),
//               ],
//             ),
//           );
//         },
//       ),
//     );
//   }
// }
