import 'package:flutter/material.dart';

class SuggestionWidget extends StatelessWidget {
  final List<User> suggestedUsers;
  final Function(User) onConnect;
  final double height;
  final double width;

  const SuggestionWidget({
    Key? key,
    required this.suggestedUsers,
    required this.onConnect,
    required this.height,
    required this.width,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: height / 60),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(15),
        // boxShadow: [
        //   BoxShadow(
        //     color: Colors.grey.withOpacity(0.3),
        //     spreadRadius: 2,
        //     blurRadius: 5,
        //     offset: const Offset(0, 3),
        //   ),
        // ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.only(
              bottom: height / 50,
              left: width / 20,
            ),
            child: Text(
              "Suggested Connects",
              style: TextStyle(
                fontFamily: 'Trebuchet',
                fontWeight: FontWeight.bold,
                fontSize: width / 22,
                color: Colors.black87,
              ),
            ),
          ),
          // Suggested users in a horizontal sliding view
          SizedBox(
            height: height / 5, // Adjust height as needed
            child: ListView.builder(
              padding: EdgeInsets.zero,
              scrollDirection: Axis.horizontal,
              itemCount: suggestedUsers.length,
              itemBuilder: (context, index) {
                return _buildUserSuggestion(suggestedUsers[index]);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserSuggestion(User user) {
    return Container(
      width: width / 2.5, // Adjust width for each item
      margin: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // User image
          Container(
            width: width / 6,
            height: width / 6,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              image: DecorationImage(
                image: AssetImage(user.imageUrl),
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(height: 8),
          // User name and handle
          Text(
            user.name,
            style: TextStyle(
              fontFamily: 'Trebuchet',
              fontSize: width / 28,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
            textAlign: TextAlign.center,
          ),
          Text(
            '@${user.handle}',
            style: TextStyle(
              fontFamily: 'Trebuchet',
              fontSize: width / 30,
              color: Colors.grey.shade600,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          // Connect button
          ElevatedButton(
            onPressed: () => onConnect(user),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.grey.shade800,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              padding: EdgeInsets.symmetric(
                  horizontal: width / 30, vertical: height / 70),
            ),
            child: Text(
              'Connect',
              style: TextStyle(
                fontFamily: 'Trebuchet',
                fontSize: width / 30,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Dummy User class
class User {
  final String name;
  final String handle;
  final String imageUrl;

  User({
    required this.name,
    required this.handle,
    required this.imageUrl,
  });
}
