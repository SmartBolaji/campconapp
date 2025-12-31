import 'dart:io';
import 'package:campcon/main/constants/app_colors.dart';
import 'package:campcon/main/constants/text_constants.dart';
import 'package:campcon/main/provider/auth_provider.dart';
import 'package:campcon/main/provider/event_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:iconify_flutter/iconify_flutter.dart';
import 'package:iconify_flutter/icons/ph.dart';
import 'package:intl/intl.dart';

class CreateEventScreen extends StatefulWidget {
  const CreateEventScreen({Key? key}) : super(key: key);

  @override
  State<CreateEventScreen> createState() => _CreateEventScreenState();
}

class _CreateEventScreenState extends State<CreateEventScreen> {
  final _titleController = TextEditingController();
  final _locationController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  final _ticketLinkController = TextEditingController();
  final _ticketStockController = TextEditingController(); //  New

  @override
  void initState() {
    super.initState();
    // Clear form when screen opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<EventProvider>(context, listen: false).clearForm();
    });
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );

    if (pickedFile != null) {
      Provider.of<EventProvider>(context, listen: false)
          .setSelectedImage(File(pickedFile.path));
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppTheme.primary,
              onPrimary: AppTheme.white,
              surface: AppTheme.surface,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && mounted) {
      Provider.of<EventProvider>(context, listen: false)
          .setSelectedDate(picked);
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppTheme.primary,
              onPrimary: AppTheme.white,
              surface: AppTheme.surface,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && mounted) {
      Provider.of<EventProvider>(context, listen: false)
          .setSelectedTime(picked);
    }
  }

  Future<void> _createEvent() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final eventProvider = Provider.of<EventProvider>(context, listen: false);

    final currentUser = authProvider.currentUser;
    if (currentUser == null) {
      _showError('User not logged in');
      return;
    }

    final school = currentUser.school;
    if (school == null || school.isEmpty) {
      _showError('Please set your school first');
      return;
    }

    if (_titleController.text.trim().isEmpty ||
        _locationController.text.trim().isEmpty ||
        eventProvider.selectedCategoryForForm == null ||
        _descriptionController.text.trim().isEmpty ||
        eventProvider.selectedDate == null ||
        eventProvider.selectedTime == null) {
      _showError('Please fill all required fields');
      return;
    }

    if (!eventProvider.isFree) {
      final price = double.tryParse(_priceController.text.trim());
      if (price == null || price <= 0) {
        _showError('Please enter a valid ticket price');
        return;
      }

      if (eventProvider.sellOnCampcon) {
        final stock = int.tryParse(_ticketStockController.text.trim());
        if (stock == null || stock <= 0) {
          _showError('Please enter valid ticket quantity');
          return;
        }
      }
    }

    FocusScope.of(context).unfocus();

    //  CAPTURE ALL VALUES BEFORE CLEARING
    final title = _titleController.text.trim();
    final location = _locationController.text.trim();
    final description = _descriptionController.text.trim();
    final category = eventProvider.selectedCategoryForForm!;
    final image = eventProvider.selectedImage;
    final eventDate = eventProvider.selectedDate!;
    final eventTime = DateTime(
      eventDate.year,
      eventDate.month,
      eventDate.day,
      eventProvider.selectedTime!.hour,
      eventProvider.selectedTime!.minute,
    );
    final isFree = eventProvider.isFree; //  CAPTURE BEFORE CLEAR
    final sellOnCampcon = eventProvider.sellOnCampcon; //  CAPTURE BEFORE CLEAR
    final price = isFree ? null : double.tryParse(_priceController.text.trim());
    final ticketLink = _ticketLinkController.text.trim().isEmpty
        ? null
        : _ticketLinkController.text.trim();
    final ticketStock = sellOnCampcon && !isFree
        ? int.tryParse(_ticketStockController.text.trim())
        : null;

    // NOW clear text controllers
    _titleController.clear();
    _locationController.clear();
    _descriptionController.clear();
    _priceController.clear();
    _ticketLinkController.clear();
    _ticketStockController.clear();

    // NOW clear form in provider
    eventProvider.clearForm();

    Navigator.of(context).pop();

    //  USE CAPTURED VALUES
    final success = await eventProvider.createEventSilently(
      organizerId: currentUser.uid,
      organizerName: currentUser.name ?? currentUser.username,
      title: title,
      description: description,
      location: location,
      eventDate: eventDate,
      eventTime: eventTime,
      category: category,
      school: school,
      isFree: isFree,
      ticketPrice: price,
      ticketLink: ticketLink,
      image: image,
      sellOnCampcon: sellOnCampcon,
      ticketStock: ticketStock,
    );

    debugPrint(success ? ' Event created' : '❌ Failed to create event');
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppTheme.error,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<EventProvider>(
      builder: (context, eventProvider, child) {
        return Scaffold(
          backgroundColor: AppTheme.surface,
          body: SafeArea(
            child: Column(
              children: [
                _buildHeader(),
                Expanded(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.all(20.w),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildImageUpload(eventProvider),
                        SizedBox(height: 20.h),
                        _buildTextField(
                          label: 'Event Title *',
                          controller: _titleController,
                          hint: 'e.g. Campus Music Festival 2024',
                        ),
                        SizedBox(height: 16.h),
                        _buildCategoryDropdown(eventProvider),
                        SizedBox(height: 16.h),
                        _buildTextField(
                          label: 'Location *',
                          controller: _locationController,
                          hint: 'e.g. Sports Complex, Main Hall',
                        ),
                        SizedBox(height: 16.h),
                        _buildTextField(
                          label: 'Description *',
                          controller: _descriptionController,
                          hint:
                              'Describe your event, activities, what to expect...',
                          maxLines: 5,
                        ),
                        SizedBox(height: 20.h),
                        _buildDateTimeSection(eventProvider),
                        SizedBox(height: 20.h),
                        _buildPricingSection(eventProvider),

                        //  Add Ticket Stock Section
                        if (!eventProvider.isFree) ...[
                          SizedBox(height: 20.h),
                          _buildTicketStockSection(eventProvider),
                        ],

                        //  Only show external ticket link if NOT selling on CampCon
                        if (!eventProvider.sellOnCampcon ||
                            eventProvider.isFree) ...[
                          SizedBox(height: 16.h),
                          _buildTicketLinkSection(eventProvider),
                        ],
                      ],
                    ),
                  ),
                ),
                _buildCreateButton(),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        border: Border(
          bottom: BorderSide(color: AppTheme.border, width: 1),
        ),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              padding: EdgeInsets.all(8.w),
              decoration: BoxDecoration(
                color: AppTheme.background,
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Iconify(
                Ph.x,
                color: AppTheme.textPrimary,
                size: 20.sp,
              ),
            ),
          ),
          Expanded(
            child: Center(
              child: Text(
                'Create Event',
                style: TextConstants.mediumText.copyWith(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textPrimary,
                ),
              ),
            ),
          ),
          SizedBox(width: 40.w),
        ],
      ),
    );
  }

  Widget _buildImageUpload(EventProvider eventProvider) {
    return GestureDetector(
      onTap: _pickImage,
      child: Container(
        height: 200.h,
        width: double.infinity,
        decoration: BoxDecoration(
          color: AppTheme.background,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(
            color: AppTheme.border,
            width: 1.5,
          ),
        ),
        child: eventProvider.selectedImage != null
            ? Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(15.r),
                    child: Image.file(
                      eventProvider.selectedImage!,
                      width: double.infinity,
                      height: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),
                  Positioned(
                    top: 8.h,
                    right: 8.w,
                    child: GestureDetector(
                      onTap: () => eventProvider.setSelectedImage(null),
                      child: Container(
                        padding: EdgeInsets.all(6.w),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.6),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.close,
                          color: Colors.white,
                          size: 18.sp,
                        ),
                      ),
                    ),
                  ),
                ],
              )
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Iconify(
                    Ph.image,
                    size: 48.sp,
                    color: AppTheme.textLight,
                  ),
                  SizedBox(height: 12.h),
                  Text(
                    'Add Event Cover Image',
                    style: TextConstants.mediumText.copyWith(
                      fontSize: 16.sp,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    'Tap to upload',
                    style: TextConstants.smallText.copyWith(
                      fontSize: 13.sp,
                      color: AppTheme.textLight,
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildDateTimeSection(EventProvider eventProvider) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppTheme.background,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AppTheme.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Iconify(
                Ph.calendar_blank,
                size: 20.sp,
                color: AppTheme.primary,
              ),
              SizedBox(width: 8.w),
              Text(
                'Event Date & Time *',
                style: TextConstants.mediumText.copyWith(
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textPrimary,
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () => _selectDate(context),
                  child: Container(
                    padding: EdgeInsets.all(12.w),
                    decoration: BoxDecoration(
                      color: AppTheme.buttonBorder,
                      borderRadius: BorderRadius.circular(8.r),
                      border: Border.all(color: AppTheme.border),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          eventProvider.selectedDate == null
                              ? 'Select Date'
                              : DateFormat('MMM dd, yyyy')
                                  .format(eventProvider.selectedDate!),
                          style: TextConstants.smallText.copyWith(
                            fontSize: 13.sp,
                            color: eventProvider.selectedDate == null
                                ? AppTheme.textLight
                                : AppTheme.textPrimary,
                          ),
                        ),
                        Iconify(
                          Ph.calendar,
                          size: 18.sp,
                          color: AppTheme.textSecondary,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: GestureDetector(
                  onTap: () => _selectTime(context),
                  child: Container(
                    padding: EdgeInsets.all(12.w),
                    decoration: BoxDecoration(
                      color: AppTheme.buttonBorder,
                      borderRadius: BorderRadius.circular(8.r),
                      border: Border.all(color: AppTheme.border),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          eventProvider.selectedTime == null
                              ? 'Select Time'
                              : eventProvider.selectedTime!.format(context),
                          style: TextConstants.smallText.copyWith(
                            fontSize: 13.sp,
                            color: eventProvider.selectedTime == null
                                ? AppTheme.textLight
                                : AppTheme.textPrimary,
                          ),
                        ),
                        Iconify(
                          Ph.clock,
                          size: 18.sp,
                          color: AppTheme.textSecondary,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPricingSection(EventProvider eventProvider) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: eventProvider.isFree
            ? AppTheme.success.withOpacity(0.05)
            : AppTheme.primary.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: eventProvider.isFree
              ? AppTheme.success.withOpacity(0.3)
              : AppTheme.primary.withOpacity(0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Iconify(
                Ph.ticket,
                size: 20.sp,
                color:
                    eventProvider.isFree ? AppTheme.success : AppTheme.primary,
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Ticket Pricing',
                      style: TextConstants.mediumText.copyWith(
                        fontSize: 15.sp,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      eventProvider.isFree
                          ? 'Free entry for all attendees'
                          : 'Paid tickets required',
                      style: TextConstants.smallText.copyWith(
                        fontSize: 12.sp,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Switch(
                value: eventProvider.isFree,
                onChanged: (value) {
                  eventProvider.toggleIsFree(value);
                  if (value) {
                    _priceController.clear();
                  }
                },
                activeThumbColor: AppTheme.success,
              ),
            ],
          ),
          if (!eventProvider.isFree) ...[
            SizedBox(height: 16.h),
            Text(
              'Ticket Price *',
              style: TextConstants.smallText.copyWith(
                fontSize: 13.sp,
                fontWeight: FontWeight.w600,
                color: AppTheme.textPrimary,
              ),
            ),
            SizedBox(height: 8.h),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),
              decoration: BoxDecoration(
                color: AppTheme.buttonBorder,
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(color: AppTheme.border, width: 1),
              ),
              child: Row(
                children: [
                  Text(
                    '₦',
                    style: TextConstants.mediumText.copyWith(
                      fontSize: 16.sp,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                  SizedBox(width: 8.w),
                  Expanded(
                    child: TextField(
                      controller: _priceController,
                      keyboardType: TextInputType.number,
                      style: TextConstants.mediumText.copyWith(
                        fontSize: 15.sp,
                        color: AppTheme.textPrimary,
                      ),
                      decoration: InputDecoration(
                        hintText: 'Enter ticket price',
                        hintStyle: TextConstants.smallText.copyWith(
                          color: AppTheme.textLight,
                        ),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(vertical: 12.h),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 8.h),
            Row(
              children: [
                Icon(
                  Icons.info_outline,
                  size: 14.sp,
                  color: AppTheme.textLight,
                ),
                SizedBox(width: 6.w),
                Expanded(
                  child: Text(
                    'This price will be used if no external ticket link is provided',
                    style: TextConstants.smallText.copyWith(
                      fontSize: 11.sp,
                      color: AppTheme.textLight,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  //  New Widget: Ticket Stock Section
  Widget _buildTicketStockSection(EventProvider eventProvider) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: eventProvider.sellOnCampcon
            ? AppTheme.primary.withOpacity(0.05)
            : AppTheme.background,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: eventProvider.sellOnCampcon
              ? AppTheme.primary.withOpacity(0.3)
              : AppTheme.border,
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Iconify(
                Ph.storefront,
                size: 20.sp,
                color: eventProvider.sellOnCampcon
                    ? AppTheme.primary
                    : AppTheme.textSecondary,
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Sell Tickets via Campcon',
                      style: TextConstants.mediumText.copyWith(
                        fontSize: 15.sp,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      eventProvider.sellOnCampcon
                          ? 'Enable in-app ticket sales — attendees can purchase securely on Campcon.'
                          : 'Manage ticket sales externally. Paste the external purchase link below if you have one.',
                      style: TextConstants.smallText.copyWith(
                        fontSize: 12.sp,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Switch(
                value: eventProvider.sellOnCampcon,
                onChanged: (value) {
                  eventProvider.toggleSellOnCampcon(value);
                  if (!value) {
                    _ticketStockController.clear();
                  }
                },
                activeThumbColor: AppTheme.primary,
              ),
            ],
          ),
          if (eventProvider.sellOnCampcon) ...[
            SizedBox(height: 16.h),

            // Info box
            Container(
              padding: EdgeInsets.all(12.w),
              decoration: BoxDecoration(
                color: AppTheme.success.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8.r),
                border: Border.all(
                  color: AppTheme.success.withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    size: 16.sp,
                    color: AppTheme.success,
                  ),
                  SizedBox(width: 8.w),
                  Expanded(
                    child: Text(
                      'Attendees will purchase tickets through Campcon and you\'ll receive payouts (minus any platform or payment processing fees).',
                      style: TextConstants.smallText.copyWith(
                        fontSize: 11.sp,
                        color: AppTheme.textSecondary,
                        height: 1.3,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: 16.h),

            // Ticket quantity input
            Row(
              children: [
                Text(
                  'Ticket Quantity *',
                  style: TextConstants.smallText.copyWith(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textPrimary,
                  ),
                  textAlign: TextAlign.start,
                ),
              ],
            ),
            SizedBox(height: 8.h),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),
              decoration: BoxDecoration(
                color: AppTheme.buttonBorder,
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(color: AppTheme.border, width: 1),
              ),
              child: Row(
                children: [
                  Iconify(
                    Ph.ticket,
                    size: 20.sp,
                    color: AppTheme.textSecondary,
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: TextField(
                      controller: _ticketStockController,
                      keyboardType: TextInputType.number,
                      style: TextConstants.mediumText.copyWith(
                        fontSize: 15.sp,
                        color: AppTheme.textPrimary,
                      ),
                      decoration: InputDecoration(
                        hintText:
                            'Enter number of tickets available (e.g. 100)',
                        hintStyle: TextConstants.smallText.copyWith(
                          color: AppTheme.textLight,
                        ),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(vertical: 12.h),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  //  Update Ticket Link Section
  Widget _buildTicketLinkSection(EventProvider eventProvider) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppTheme.background,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AppTheme.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // Iconify(
              //   Ph.link,
              //   size: 20.sp,
              //   color: AppTheme.primary,
              // ),
              // SizedBox(width: 8.w),
              Text(
                'Ticket Link (Optional)',
                style: TextConstants.mediumText.copyWith(
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textPrimary,
                ),
              ),
            ],
          ),
          SizedBox(height: 8.h),
          Container(
            padding: EdgeInsets.all(12.w),
            decoration: BoxDecoration(
              color: AppTheme.primary.withOpacity(0.05),
              borderRadius: BorderRadius.circular(8.r),
              border: Border.all(
                color: AppTheme.primary.withOpacity(0.2),
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.lightbulb_outline,
                  size: 16.sp,
                  color: AppTheme.primary,
                ),
                SizedBox(width: 8.w),
                Expanded(
                  child: Text(
                    eventProvider.isFree
                        ? 'Provide a registration or RSVP link so attendees can sign up (e.g. Google Forms, Typeform).'
                        : 'Paste the external ticket URL (Eventbrite, Selar, etc.) so attendees can purchase tickets.',
                    style: TextConstants.smallText.copyWith(
                      fontSize: 12.sp,
                      color: AppTheme.textSecondary,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 12.h),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),
            decoration: BoxDecoration(
              color: AppTheme.buttonBorder,
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(color: AppTheme.border, width: 1),
            ),
            child: TextField(
              controller: _ticketLinkController,
              keyboardType: TextInputType.url,
              style: TextConstants.mediumText.copyWith(
                fontSize: 15.sp,
                color: AppTheme.textPrimary,
              ),
              decoration: InputDecoration(
                hintText: eventProvider.isFree
                    ? 'https://forms.google.com/...'
                    : 'https://eventbrite.com/your-event',
                hintStyle: TextConstants.smallText.copyWith(
                  color: AppTheme.textLight,
                ),
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(vertical: 12.h),
                // prefixIcon: Icon(
                //   Icons.link,
                //   size: 18.sp,
                //   color: AppTheme.textLight,
                // ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    required String hint,
    int maxLines = 1,
    TextInputType? keyboardType,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextConstants.smallText.copyWith(
            fontSize: 14.sp,
            fontWeight: FontWeight.w600,
            color: AppTheme.textPrimary,
          ),
        ),
        SizedBox(height: 8.h),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),
          decoration: BoxDecoration(
            color: AppTheme.buttonBorder,
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(color: AppTheme.border, width: 1),
          ),
          child: TextField(
            controller: controller,
            maxLines: maxLines,
            keyboardType: keyboardType,
            style: TextConstants.mediumText.copyWith(
              fontSize: 15.sp,
              color: AppTheme.textPrimary,
            ),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: TextConstants.smallText.copyWith(
                color: AppTheme.textLight,
              ),
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(vertical: 12.h),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryDropdown(EventProvider eventProvider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Category *',
          style: TextConstants.smallText.copyWith(
            fontSize: 14.sp,
            fontWeight: FontWeight.w600,
            color: AppTheme.textPrimary,
          ),
        ),
        SizedBox(height: 8.h),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          decoration: BoxDecoration(
            color: AppTheme.buttonBorder,
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(color: AppTheme.border, width: 1),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              isExpanded: true,
              value: eventProvider.selectedCategoryForForm,
              hint: Text(
                'Select category',
                style: TextConstants.smallText.copyWith(
                  color: AppTheme.textLight,
                ),
              ),
              icon: Iconify(
                Ph.caret_down,
                color: AppTheme.textLight,
                size: 20.sp,
              ),
              style: TextConstants.mediumText.copyWith(
                fontSize: 15.sp,
                color: AppTheme.textPrimary,
              ),
              dropdownColor: AppTheme.surface,
              items: eventProvider.eventCategories.map((category) {
                return DropdownMenuItem(
                  value: category,
                  child: Text(category),
                );
              }).toList(),
              onChanged: (value) => eventProvider.setSelectedCategory(value),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCreateButton() {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        border: Border(
          top: BorderSide(color: AppTheme.border, width: 1),
        ),
      ),
      child: GestureDetector(
        onTap: _createEvent,
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(vertical: 16.h),
          decoration: BoxDecoration(
            color: AppTheme.primary,
            borderRadius: BorderRadius.circular(12.r),
          ),
          child: Center(
            child: Text(
              'Create Event',
              style: TextConstants.mediumText.copyWith(
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
                color: AppTheme.white,
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _locationController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _ticketLinkController.dispose();
    _ticketStockController.dispose(); //  New
    super.dispose();
  }
}
