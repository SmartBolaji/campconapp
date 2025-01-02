import 'package:campcon/floatingbutton.dart';
import 'package:campcon/screens/search_screen/search_input.dart';
import 'package:flutter/material.dart';
import 'package:iconly/iconly.dart';

class SearchScreen extends StatelessWidget {
  const SearchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    bool _isFabVisible = true;

    return Scaffold(
      floatingActionButton: FloatingButton(isFabVisible: _isFabVisible),
      backgroundColor: Colors.grey.shade100,
      body: Column(
        children: [
          // Search Field
          Padding(
            padding:
                const EdgeInsets.only(top: 50, left: 16, right: 16, bottom: 10),
            child: GestureDetector(
              onTap: () {
                // Navigate to the search input screen
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const SearchInputScreen()),
                );
              },
              child: Container(
                height: 50,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(width: 1, color: Colors.black12)
                    // boxShadow: [
                    //   BoxShadow(
                    //     color: Colors.black12,
                    //     blurRadius: 4,
                    //     offset: const Offset(0, 2),
                    //   ),
                    // ],
                    ),
                child: const Row(
                  children: [
                    Icon(IconlyLight.search, color: Colors.grey),
                    SizedBox(width: 10),
                    Text(
                      'Search...',
                      style: TextStyle(
                        color: Colors.grey,
                        fontFamily: 'Lato',
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Categories Section
          Container(
            height: 35,
            width: screenWidth,
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(color: Colors.grey.shade300, width: 1),
              ),
            ),
            child: ListView(
              scrollDirection: Axis.horizontal,
              // padding: const EdgeInsets.symmetric(horizontal: 10),
              children: [
                _buildCategoryItem('Trending', isActive: true),
                // _buildCategoryItem('People'),
                _buildCategoryItem('News'),
                _buildCategoryItem('Education'),
                _buildCategoryItem('Sports'),
                _buildCategoryItem('Events'),
                _buildCategoryItem('Music'),
              ],
            ),
          ),

          // Banner Section
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Container(
              height: 150,
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                image: const DecorationImage(
                  image: AssetImage('assets/images/social.jpeg'),
                  fit: BoxFit.cover,
                ),
              ),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  gradient: LinearGradient(
                    colors: [Colors.black.withOpacity(0.5), Colors.transparent],
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                  ),
                ),
                child: const Padding(
                  padding: EdgeInsets.all(12),
                  child: Align(
                    alignment: Alignment.bottomLeft,
                    child: Text(
                      'Discover What’s Trending!',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontFamily: 'Lato',
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),

          // Trending people
          // const Padding(
          //   padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          //   child: Align(
          //     alignment: Alignment.centerLeft,
          //     child: Text(
          //       'People',
          //       style: TextStyle(
          //         fontSize: 18,
          //         fontWeight: FontWeight.bold,
          //         fontFamily: 'Lato',
          //       ),
          //     ),
          //   ),
          // ),

          // Trending Topics Section
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Top Trending',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Lato',
                ),
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: demoTrendingTopics.length,
              itemBuilder: (context, index) {
                final topic = demoTrendingTopics[index];
                return Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  child: ListTile(
                    shape: const RoundedRectangleBorder(
                      side: BorderSide(width: 1, color: Colors.black12),
                      borderRadius: BorderRadius.all(Radius.circular(15)),
                    ),
                    tileColor: Colors.grey.shade200,
                    leading: const Icon(Icons.trending_up_sharp,
                        color: Color(0xFFBA9E02)),
                    title: Text(
                      topic,
                      style: TextStyle(
                        color: Colors.grey.shade700,
                        fontWeight: FontWeight.w500,
                        fontSize: 15,
                        fontFamily: 'Lato',
                      ),
                    ),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () {
                      // Handle topic click
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // Category Widget
  Widget _buildCategoryItem(String label, {bool isActive = false}) {
    return GestureDetector(
      onTap: () {},
      child: Container(
        decoration: isActive
            ? BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    width: 3,
                    color:
                        isActive ? const Color(0xFFBA9E02) : Colors.transparent,
                  ),
                ),
              )
            : null,
        margin: const EdgeInsets.only(left: 16, right: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: TextStyle(
                fontFamily: 'Lato',
                fontSize: 16,
                fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                color: isActive ? Colors.black : Colors.grey.shade600,
              ),
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
    );
  }
}

// Demo trending topics
final List<String> demoTrendingTopics = [
  'Flutter 3.0 Released!',
  'Champions League Finals',
  'Coldplay’s New Album',
  'TechCrunch Startup Battle',
  '2024 Elections',
];
