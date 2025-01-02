import 'package:campcon/screens/events_screen/bottom_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class EventViewPage extends StatefulWidget {
  final List<String> imageUrls;
  final String title;
  final String location;
  final String food;
  final DateTime date;
  final String time;
  final int reservations;
  final int totalSeats;
  final List<String> attendingProfiles;
  final String price;

  const EventViewPage({
    Key? key,
    required this.imageUrls,
    required this.title,
    required this.location,
    required this.food,
    required this.date,
    required this.time,
    required this.reservations,
    required this.totalSeats,
    required this.attendingProfiles,
    required this.price,
  }) : super(key: key);

  @override
  State<EventViewPage> createState() => _EventViewPageState();
}

class _EventViewPageState extends State<EventViewPage> {
  final ScrollController _scrollController = ScrollController();
  bool _showAppBarTitle = false;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(() {
      if (_scrollController.offset > 150 && !_showAppBarTitle) {
        setState(() {
          _showAppBarTitle = true;
        });
      } else if (_scrollController.offset <= 150 && _showAppBarTitle) {
        setState(() {
          _showAppBarTitle = false;
        });
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const int maxVisibleIndicators = 4;

    // Determine the start and end of the visible range
    int startIndex = (_currentIndex - maxVisibleIndicators ~/ 2)
        .clamp(0, widget.imageUrls.length - maxVisibleIndicators);
    int endIndex =
        (startIndex + maxVisibleIndicators).clamp(0, widget.imageUrls.length);

    // Generate indicators
    List<Widget> indicators = [];
    if (startIndex > 0) {
      indicators.add(Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        width: 4,
        height: 4,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.grey.withOpacity(0.6), // Mini dot
        ),
      ));
    }
    for (int i = startIndex; i < endIndex; i++) {
      indicators.add(Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        width: 6,
        height: 6,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: _currentIndex == i ? const Color(0xFFBA9E02) : Colors.grey,
        ),
      ));
    }
    if (endIndex < widget.imageUrls.length) {
      indicators.add(Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        width: 4,
        height: 4,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.grey.withOpacity(0.6), // Mini dot
        ),
      ));
    }

    bool isLongContent = widget.title.length > 13;
    String displayContent =
        isLongContent ? '${widget.title.substring(0, 13)}...' : widget.title;

    return Scaffold(
      bottomSheet: BottomSheetWidget(widget: widget),
      backgroundColor: Colors.grey.shade100,
      body: SafeArea(
        child: Stack(
          children: [
            CustomScrollView(
              controller: _scrollController,
              slivers: [
                SliverAppBar(
                  surfaceTintColor: Colors.grey.shade100
                      .withOpacity(_showAppBarTitle ? 1 : 0),
                  backgroundColor: Colors.grey.shade100
                      .withOpacity(_showAppBarTitle ? 1 : 0),
                  expandedHeight: 300,
                  floating: false,
                  pinned: true,
                  flexibleSpace: FlexibleSpaceBar(
                    title: _showAppBarTitle
                        ? Container(
                            child: Text(
                              displayContent,
                              style: const TextStyle(
                                fontFamily: 'Lato',
                                color: Colors.black,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                              maxLines: 1,
                            ),
                          )
                        : null,
                    background: Stack(
                      alignment: Alignment.bottomCenter,
                      children: [
                        PageView.builder(
                          itemCount: widget.imageUrls.length,
                          onPageChanged: (index) {
                            setState(() {
                              _currentIndex = index;
                            });
                          },
                          itemBuilder: (context, index) {
                            return Image.asset(
                              widget.imageUrls[index],
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) =>
                                  Container(
                                color: Colors.grey.shade300,
                                child: const Icon(
                                  Icons.broken_image,
                                  color: Colors.grey,
                                  size: 50,
                                ),
                              ),
                            );
                          },
                        ),
                        Positioned(
                          bottom: 16,
                          child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: indicators),
                        ),
                      ],
                    ),
                  ),
                  leading: GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Transform.scale(
                      scale: 0.85, // Adjust the scale factor to reduce size
                      child: Container(
                        margin: const EdgeInsets.fromLTRB(10, 0, 0, 0),
                        decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.grey.shade100,
                            border: Border.all(
                                width: 1,
                                color: Colors.grey.shade400
                                    .withOpacity(_showAppBarTitle ? 1 : 0))),
                        child: Icon(
                          Icons.arrow_back,
                          color: Colors.grey.shade800,
                          size: 32,
                        ),
                      ),
                    ),
                  ),
                  actions: [
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Transform.scale(
                        scale: 1, // Adjust the scale factor to reduce size
                        child: Container(
                          margin: const EdgeInsets.fromLTRB(10, 0, 0, 0),
                          padding: EdgeInsets.all(10),
                          decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.grey.shade100,
                              border: Border.all(
                                  width: 1,
                                  color: Colors.grey.shade400
                                      .withOpacity(_showAppBarTitle ? 1 : 0))),
                          child: Icon(
                            FeatherIcons.bookmark,
                            color: Colors.grey.shade800,
                            size: 20,
                          ),
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Transform.scale(
                        scale: 1, // Adjust the scale factor to reduce size
                        child: Container(
                          margin: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                          padding: EdgeInsets.all(10),
                          decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.grey.shade100,
                              border: Border.all(
                                  width: 1,
                                  color: Colors.grey.shade400
                                      .withOpacity(_showAppBarTitle ? 1 : 0))),
                          child: Icon(
                            FeatherIcons.share2,
                            color: Colors.grey.shade800,
                            size: 20,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                SliverToBoxAdapter(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Event Details Section
                      Container(
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          borderRadius:
                              BorderRadius.vertical(top: Radius.circular(20)),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Title
                              Container(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    !_showAppBarTitle
                                        ? Column(
                                            children: [
                                              Text(
                                                widget.title,
                                                style: TextStyle(
                                                  fontSize: 26,
                                                  fontFamily: 'Lato',
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              const SizedBox(height: 20),
                                            ],
                                          )
                                        : const SizedBox(),

                                    // Location
                                    Row(
                                      children: [
                                        const Icon(
                                          FeatherIcons.mapPin,
                                          size: 18,
                                          color: Color(0xFF9c936b),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Text(
                                            widget.location,
                                            style: TextStyle(
                                              fontSize: 15,
                                              color: Color(0xFF9c936b),
                                              fontFamily: 'Lato',
                                              fontWeight: FontWeight.w400,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 13),

                                    // Date and Time
                                    Row(
                                      children: [
                                        const Icon(
                                          FeatherIcons.calendar,
                                          size: 18,
                                          color: Color(0xFF9c936b),
                                        ),
                                        const SizedBox(width: 12),
                                        Text(
                                          DateFormat.yMMMMd()
                                              .format(widget.date),
                                          style: TextStyle(
                                            fontSize: 15,
                                            fontFamily: 'Lato',
                                            fontWeight: FontWeight.w400,
                                          ),
                                        ),
                                        const SizedBox(width: 16),
                                        const Icon(
                                          FeatherIcons.clock,
                                          size: 18,
                                          color: Color(0xFF9c936b),
                                        ),
                                        const SizedBox(width: 12),
                                        Text(widget.time,
                                            style: TextStyle(
                                              fontSize: 15,
                                              fontFamily: 'Lato',
                                              fontWeight: FontWeight.w400,
                                            )),
                                      ],
                                    ),
                                    const SizedBox(height: 13),

                                    // Reservations & Item7
                                    Row(
                                      children: [
                                        // Reservation
                                        const Icon(
                                          FeatherIcons.users,
                                          size: 18,
                                          color: Color(0xFF9c936b),
                                        ),
                                        const SizedBox(width: 12),
                                        RichText(
                                          text: TextSpan(
                                            children: [
                                              TextSpan(
                                                text: '${widget.reservations}',
                                                style: TextStyle(
                                                  fontSize: 15,
                                                  color: Colors.grey.shade500,
                                                  fontFamily: 'Lato',
                                                  fontWeight: FontWeight.w400,
                                                ),
                                              ),
                                              TextSpan(
                                                text: ' / ',
                                                style: TextStyle(
                                                  fontSize: 15,
                                                  color: Colors.grey.shade400,
                                                  fontFamily: 'Lato',
                                                  fontWeight: FontWeight.w400,
                                                ),
                                              ),
                                              TextSpan(
                                                text: '${widget.totalSeats}',
                                                style: TextStyle(
                                                  fontSize: 15,
                                                  color: Colors.grey.shade800,
                                                  fontFamily: 'Lato',
                                                  fontWeight: FontWeight.w400,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),

                                        const SizedBox(width: 16),

                                        // Item 7
                                        const Icon(
                                          Icons.restaurant_menu_outlined,
                                          size: 18,
                                          color: Color(0xFF9c936b),
                                        ),
                                        const SizedBox(width: 12),
                                        Text(widget.food,
                                            style: TextStyle(
                                              fontSize: 15,
                                              fontFamily: 'Lato',
                                              fontWeight: FontWeight.w400,
                                            )),
                                      ],
                                    ),

                                    // const SizedBox(height: 8),

                                    // Refund policy
                                    // Row(
                                    //   mainAxisAlignment:
                                    //       MainAxisAlignment.start,
                                    //   crossAxisAlignment:
                                    //       CrossAxisAlignment.start,
                                    //   children: [
                                    //     const Icon(
                                    //       FeatherIcons.dollarSign,
                                    //       size: 18,
                                    //       color: Color(0xFF9c936b),
                                    //     ),
                                    //     const SizedBox(width: 8),
                                    //     Column(
                                    //       mainAxisAlignment:
                                    //           MainAxisAlignment.start,
                                    //       crossAxisAlignment:
                                    //           CrossAxisAlignment.start,
                                    //       children: [
                                    //         Text('Refund Policy',
                                    //             style: TextStyle(
                                    //               fontSize: 14,
                                    //               fontFamily: 'Trebuchet',
                                    //             )),
                                    //         const SizedBox(height: 5),
                                    //         Text(
                                    //             'Refunds up to 7 days before event.',
                                    //             style: TextStyle(
                                    //               fontSize: 12,
                                    //               color: Colors.grey.shade600,
                                    //               fontFamily: 'Trebuchet',
                                    //             )),
                                    //       ],
                                    //     ),
                                    //   ],
                                    // ),
                                  ],
                                ),
                              ),

                              Container(
                                  padding: const EdgeInsets.only(
                                    left: 20,
                                    right: 20,
                                    bottom: 15,
                                  ),
                                  decoration: BoxDecoration(
                                    border: Border(
                                      bottom: BorderSide(
                                          color: Colors.grey.shade200,
                                          width: 1),
                                    ),
                                  )),

                              // About the Event
                              Padding(
                                padding: EdgeInsets.only(top: 15, bottom: 5),
                                child: Text(
                                  'About the event',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontFamily: 'Lato',
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              Container(
                                padding:
                                    const EdgeInsets.fromLTRB(15, 4, 15, 4),
                                decoration: BoxDecoration(
                                    color: Colors.grey.shade300,
                                    borderRadius: BorderRadius.circular(20)),
                                child: Text(
                                  'Technology',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontFamily: 'Lato',
                                    fontWeight: FontWeight.w400,
                                    color: Colors.grey.shade700,
                                  ),
                                ),
                              ),

                              const SizedBox(height: 10),
                              Text(
                                'This is a brief description of the event that explains the purpose, activities, and any additional details the attendees should know.',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey.shade600,
                                  fontFamily: 'Lato',
                                  fontWeight: FontWeight.w400,
                                  height: 1.5,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Read more',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontFamily: 'Lato',
                                  fontWeight: FontWeight.w800,
                                  color: Colors.grey.shade900,
                                ),
                              ),

                              const SizedBox(height: 20),

                              // Attending Profiles Section (stacked circles)
                              if (widget.attendingProfiles.isNotEmpty)
                                Column(
                                  children: [
                                    // Wrap Stack with a Container to provide a fixed height or constraints
                                    Container(
                                      height:
                                          30, // Set a height that fits your design
                                      child: Stack(
                                        clipBehavior: Clip.none,
                                        children: List.generate(
                                          widget.attendingProfiles.length,
                                          (index) {
                                            return Positioned(
                                              left: index *
                                                  20.0, // Space between circles
                                              child: CircleAvatar(
                                                radius: 20,
                                                backgroundImage: AssetImage(
                                                  widget
                                                      .attendingProfiles[index],
                                                ),
                                              ),
                                            );
                                          },
                                        ),
                                      ),
                                    ),
                                  ],
                                ),

                              // Creator profile
                              Container(
                                // height: 80, // Adjust height as needed
                                width: double.infinity,
                                decoration: BoxDecoration(
                                    color: Colors.grey.shade100,
                                    borderRadius: BorderRadius.circular(10)),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 25),
                                margin:
                                    const EdgeInsets.only(top: 40, bottom: 20),
                                child: Column(
                                  children: [
                                    // Username and Followers
                                    CircleAvatar(
                                      radius: 25, // Size of the profile picture
                                      backgroundImage: const AssetImage(
                                          'assets/images/social.jpeg'), // Replace with the image URL or path
                                      backgroundColor: Colors
                                          .grey.shade300, // Fallback color
                                    ),
                                    const SizedBox(
                                        height:
                                            16), // Spacing between the picture and text

                                    Text(
                                      'Organized by', // Replace with dynamic follower count
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.grey.shade600,
                                        fontFamily: 'Lato',
                                        fontWeight: FontWeight.w400,
                                      ),
                                    ),
                                    const SizedBox(height: 5),
                                    Text(
                                      'Peter Opad.', // Replace with dynamic username
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontFamily: 'Lato',
                                        // fontWeight: FontWeight.w400,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 15),
                                    // Follow Button
                                    ElevatedButton(
                                      onPressed: () {
                                        // Add follow/unfollow action
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: const Color(
                                            0xFF9c936b), // Custom color
                                        foregroundColor: Colors.white,
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 15, vertical: 8),
                                      ),
                                      child: const Text(
                                        'Connect',
                                        style: TextStyle(
                                            fontSize: 14,
                                            fontFamily: 'Lato',
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              const SizedBox(height: 30),

                              // About the Event
                              const Text(
                                'More like this',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontFamily: 'Lato',
                                  // fontWeight: FontWeight.w400,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 80),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
