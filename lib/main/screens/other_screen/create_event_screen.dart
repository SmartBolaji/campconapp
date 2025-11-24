import 'package:campcon/main/constants/app_colors.dart';
import 'package:campcon/main/constants/text_constants.dart';
import 'package:campcon/main/provider/event_provider.dart';
import 'package:campcon/main/widgets/custom_btn.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

class CreateEventScreen extends StatelessWidget {
  const CreateEventScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Consumer<EventProvider>(
        builder: (context, eventProvider, child) {
          return SingleChildScrollView(
            padding: EdgeInsets.all(16.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  margin: EdgeInsets.only(top: 20.sp),
                  padding: EdgeInsets.symmetric(vertical: 20.h),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: const Icon(
                          Icons.arrow_back,
                        ),
                      ),
                      SizedBox(width: 30.w),
                      Text(
                        'Create Event',
                        style: TextConstants.mediumText,
                      ),
                    ],
                  ),
                ),
                // Event name
                _buildInputSection(
                  label: 'Event name',
                  onChanged: eventProvider.updateEventName,
                ),

                SizedBox(height: 20.h),

                // Event description
                _buildInputSection(
                  label: 'Event description',
                  onChanged: eventProvider.updateEventDescription,
                  maxLines: 3,
                ),

                SizedBox(height: 20.h),

                // Event image
                _buildImageUploadSection(eventProvider),

                SizedBox(height: 20.h),

                // Location
                _buildInputSection(
                  label: 'Location',
                  onChanged: eventProvider.updateLocation,
                ),

                SizedBox(height: 20.h),

                // Ticket link
                _buildInputSection(
                  label: 'Ticket link',
                  onChanged: eventProvider.updateTicketLink,
                ),

                SizedBox(height: 40.h),

                // Create event button
                CustomButton(
                  backgroundColor: Constants.primaryDark,
                  text: 'Create Event',
                  onPressed: () {
                    eventProvider.createEvent();
                    Navigator.pop(context);
                  },
                  textColor: Constants.textPrimary,
                )
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildInputSection({
    required String label,
    required Function(String) onChanged,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextConstants.smallText.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 8.h),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(12.r),
          ),
          child: TextField(
            onChanged: onChanged,
            maxLines: maxLines,
            decoration: InputDecoration(
              border: InputBorder.none,
              hintText: '',
              isDense: true,
              contentPadding: EdgeInsets.zero,
            ),
            style: TextStyle(fontSize: 14.sp),
          ),
        ),
      ],
    );
  }

  Widget _buildImageUploadSection(EventProvider eventProvider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Event image',
          style: TextConstants.smallText.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 8.h),
        GestureDetector(
          onTap: () {
            // Handle image upload
            eventProvider.updateEventImage('sample_image.jpg');
          },
          child: Container(
            width: double.infinity,
            height: 120.h,
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.cloud_upload_outlined,
                    size: 24.sp,
                    color: Colors.grey.shade600,
                  ),
                  SizedBox(height: 8.h),
                  Text('Upload Image', style: TextConstants.smallText),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
