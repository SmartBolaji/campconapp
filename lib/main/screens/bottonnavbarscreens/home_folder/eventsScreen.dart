import 'package:campcon/main/constants/app_colors.dart';
import 'package:campcon/main/constants/text_constants.dart';
import 'package:campcon/main/provider/event_provider.dart';
import 'package:campcon/main/screens/other_screen/create_event_screen.dart';
import 'package:campcon/main/widgets/event_card.dart';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

class EventsScreen extends StatelessWidget {
  const EventsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<EventProvider>(
      builder: (context, eventProvider, child) {
        return Container(
          margin: EdgeInsets.only(top: 16.h),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Your Events', style: TextConstants.smallText),
                  Text('See all', style: TextConstants.smallText),
                ],
              ),
              SizedBox(height: 10.h),
              Row(
                children: [
                  _buildCreateEventCard(context),
                  SizedBox(width: 12.w),
                  // _buildEventCard('Campus Rave'),
                ],
              ),
              SizedBox(height: 12.h),
              Align(
                alignment: Alignment.centerLeft,
                child: Text('Explore Events', style: TextConstants.smallText),
              ),
             eventProvider.events.isEmpty
             ? Center(
        child: Text(
          'No events created yet.',
          style: TextStyle(fontSize: 16.sp, color: Colors.grey),
        ),
      )
    : GridView.builder(
            padding: EdgeInsets.all(16.w),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 16.w,
              mainAxisSpacing: 16.h,
              childAspectRatio: 0.8,
            ),
            itemCount: eventProvider.events.length,
            itemBuilder: (context, index) {
              final event = eventProvider.events[index];
              return EventCard(
                // title: event['name']!,
                // eventImage: event['image'],
                // hasInterested: true, // Example data
                // hasBookmark: index.isEven, // Example data
              );
            },
          )
              
            ],
          ),
        );
      },
    );
  }

  Widget _buildCreateEventCard(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ChangeNotifierProvider(
              create: (context) => EventProvider(),
              child: CreateEventScreen(),
            ),
          ),
        );
      },
      child: Container(
        width: 65.w,
        height: 50.h,
        decoration: BoxDecoration(
          color: Constants.backgroundColor,
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add, size: 24.sp, color: Colors.black),
            SizedBox(height: 4.h),
            Text(
              'Create event',
              style: TextStyle(
                fontSize: 10.sp,
                color: Colors.black,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
