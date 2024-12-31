import 'package:flutter/material.dart';

Widget featuredEventItem({
  required String title,
  required String location,
  required String date,
  required String imageUrl,
  required List<String> attendingProfiles,
  required int reservations,
  required int totalSeats,
  required VoidCallback onPressed, // Adding a callback for CTA
}) {
  int attendeeLenght = 0;

  if (attendingProfiles.isNotEmpty && attendingProfiles.length < 5) {
    attendeeLenght = attendingProfiles.length;
  } else if (attendingProfiles.isNotEmpty && attendingProfiles.length > 5) {
    attendeeLenght = 5;
  }

  return Container(
    width: double.infinity, // Ensure it spans across the whole width
    margin: const EdgeInsets.symmetric(
        vertical: 10, horizontal: 15), // Reduced margin
    decoration: BoxDecoration(
      borderRadius:
          BorderRadius.circular(12), // Reduced border radius for a smaller card
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.1), // Softer shadow
          blurRadius: 8,
          offset: const Offset(0, 4),
        ),
      ],
    ),
    child: Stack(
      children: [
        // Image Section
        ClipRRect(
          borderRadius: BorderRadius.circular(12), // Rounded corners
          child: Image.asset(
            imageUrl,
            height: 200, // Slightly larger image height
            width: double.infinity,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return Container(
                color: Colors.grey.shade300,
                child: const Icon(
                  Icons.broken_image,
                  size: 50,
                  color: Colors.grey,
                ),
              );
            },
          ),
        ),

        // Dark Blur Overlay
        Container(
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.5), // Dark overlay
            borderRadius: BorderRadius.circular(12),
          ),
        ),

        // Content on top of the image
        Positioned(
          left: 15,
          right: 15,
          top: 15,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title
              Text(
                title,
                style: TextStyle(
                  fontSize: 20, // Adjusted font size
                  fontFamily: 'Lato',
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  overflow: TextOverflow.ellipsis,
                ),
                maxLines: 1,
              ),
              const SizedBox(height: 8),

              // Location
              Row(
                children: [
                  const Icon(Icons.location_on, color: Colors.white, size: 16),
                  const SizedBox(width: 5),
                  Expanded(
                    child: Text(
                      location,
                      style: const TextStyle(
                        fontFamily: 'Lato',
                        fontWeight: FontWeight.w400,
                        fontSize: 14,
                        color: Colors.white70,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // Date
              Row(
                children: [
                  const Icon(Icons.access_time, color: Colors.white, size: 16),
                  const SizedBox(width: 5),
                  Text(
                    date,
                    style: const TextStyle(
                      fontFamily: 'Lato',
                      fontWeight: FontWeight.w400,
                      fontSize: 14,
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              if (attendingProfiles.isNotEmpty)
                Column(
                  children: [
                    // Wrap Stack with a Container to provide a fixed height or constraints
                    Container(
                      height: 30, // Set a height that fits your design
                      child: Stack(
                        clipBehavior: Clip.none,
                        children: List.generate(
                          attendeeLenght,
                          (index) {
                            return Positioned(
                              left: index * 15.0, // Space between circles
                              child: CircleAvatar(
                                radius: 20,
                                backgroundImage: AssetImage(
                                  attendingProfiles[index],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                ),

              // // Reservation Count
              // RichText(
              //   text: TextSpan(
              //     children: [
              //       TextSpan(
              //         text: '$reservations',
              //         style: const TextStyle(
              //           fontSize: 16,
              //           color: Colors.white,
              //           fontWeight: FontWeight.w400,
              //           fontFamily: 'Trebuchet',
              //         ),
              //       ),
              //       const TextSpan(
              //         text: ' / ',
              //         style: TextStyle(
              //           fontSize: 16,
              //           color: Colors.white70,
              //         ),
              //       ),
              //       TextSpan(
              //         text: '$totalSeats',
              //         style: const TextStyle(
              //           fontSize: 16,
              //           color: Colors.white,
              //           fontWeight: FontWeight.bold,
              //           fontFamily: 'Trebuchet',
              //         ),
              //       ),
              //     ],
              //   ),
              // ),
            ],
          ),
        ),

        // CTA Button Section (over the image)
        Positioned(
          bottom: 20,
          right: 15,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.7),
              borderRadius: BorderRadius.circular(30),
            ),
            child: TextButton(
              onPressed: onPressed, // Add the CTA action
              child: Text(
                'Reserve Now',
                style: TextStyle(
                  fontSize: 14, // Smaller text
                  fontFamily: 'Lato',
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ),
      ],
    ),
  );
}
