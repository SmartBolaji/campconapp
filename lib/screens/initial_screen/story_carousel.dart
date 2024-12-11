import 'package:flutter/material.dart';

class StoryViewCarousel extends StatelessWidget {
  final List<String> storyImages;

  const StoryViewCarousel({Key? key, required this.storyImages})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;

    return Container(
      height: 130, // Adjust height as needed
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.grey.shade300, width: 1),
        ),
      ),
      child: ListView.builder(
        padding: EdgeInsets.zero,
        scrollDirection: Axis.horizontal,
        itemCount: storyImages.length + 1, // Add one for "Create Story"
        itemBuilder: (context, index) {
          if (index == 0) {
            return _buildCreateStory(screenWidth);
          } else {
            return _buildStoryItem(screenWidth, storyImages[index - 1]);
          }
        },
      ),
    );
  }

  Widget _buildCreateStory(double screenWidth) {
    return Padding(
      padding: const EdgeInsets.only(left: 15, top: 8, bottom: 8, right: 3),
      child: GestureDetector(
        onTap: () {
          // Handle "Create Story" action
        },
        child: Container(
          width: screenWidth / 4,
          height: 90,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            color: Colors.grey.shade300,
            border: Border.all(width: 1, color: Colors.grey.shade400),
          ),
          child: Stack(
            children: [
              // Profile image at the left
              Positioned(
                top: 10,
                left: 6,
                child: Container(
                  width: 30,
                  height: 30,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(width: 2, color: Colors.grey.shade600),
                  ),
                  child: ClipOval(
                    child: Image.asset(
                      'assets/images/social.jpeg', // Replace with a valid image
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
              // Add icon and text
              const Center(
                child: Icon(
                  Icons.add,
                  size: 35,
                  color: Colors.grey,
                ),
              ),
              // Positioned(
              //   bottom: 4,
              //   left: 60, // Adjusted for profile image
              //   child: Text(
              //     'Add Story',
              //     style: TextStyle(
              //       fontFamily: 'Trebuchet',
              //       fontSize: 12,
              //       color: Colors.grey.shade800,
              //       fontWeight: FontWeight.bold,
              //     ),
              //   ),
              // ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStoryItem(double screenWidth, String imageUrl) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 3.0, vertical: 8),
      child: ClipRRect(
        borderRadius:
            BorderRadius.circular(8), // Ensure border radius is applied
        child: Container(
          width: screenWidth / 4,
          height: 90,
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage(imageUrl),
              fit: BoxFit.cover,
            ),
            border: Border.all(width: 1, color: Colors.grey.shade400),
          ),
          child: Stack(
            children: [
              // Dark shadow overlay at the bottom
              Positioned.fill(
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: Container(
                    height: 40, // Adjust height of shadow
                    decoration: BoxDecoration(
                      borderRadius: const BorderRadius.vertical(
                        bottom: Radius.circular(8), // Match the border radius
                      ),
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withOpacity(0.6), // Shadow effect
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              // Profile image at the bottom left
              Positioned(
                top: 6,
                left: 6,
                child: Container(
                  width: 30,
                  height: 30,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border:
                        Border.all(width: 2, color: const Color(0xFFBA9E02)),
                  ),
                  child: ClipOval(
                    child: Image.asset(
                      imageUrl, // Use the profile image
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
