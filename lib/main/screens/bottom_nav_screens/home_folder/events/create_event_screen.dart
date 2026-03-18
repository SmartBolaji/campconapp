import 'dart:io';

import 'package:campcon/main/constants/app_colors.dart';
import 'package:campcon/main/provider/auth_provider.dart';
import 'package:campcon/main/provider/event_create_provider.dart';
import 'package:campcon/main/provider/event_provider.dart';
import 'package:campcon/main/screens/bottom_nav_screens/home_folder/events/widgets/create_event/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

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
  final _ticketStockController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<EventCreateProvider>(context, listen: false).clearForm();
    });
  }

  Future<void> _createEvent() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final createProvider =
        Provider.of<EventCreateProvider>(context, listen: false);
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

    // Validate required fields
    if (_titleController.text.trim().isEmpty ||
        _locationController.text.trim().isEmpty ||
        createProvider.selectedCategory == null ||
        _descriptionController.text.trim().isEmpty ||
        createProvider.selectedDate == null ||
        createProvider.selectedTime == null) {
      _showError('Please fill all required fields');
      return;
    }

    // Validate pricing
    if (!createProvider.isFree && !createProvider.hasMultipleTiers) {
      final price = double.tryParse(_priceController.text.trim());
      if (price == null || price <= 0) {
        _showError('Please enter a valid ticket price');
        return;
      }

      if (createProvider.sellOnCampcon) {
        final stock = int.tryParse(_ticketStockController.text.trim());
        if (stock == null || stock <= 0) {
          _showError('Please enter valid ticket quantity');
          return;
        }
      }
    }

    // Validate tiers if multiple tiers enabled
    if (createProvider.hasMultipleTiers) {
      for (var tier in createProvider.ticketTiers) {
        if (tier.name.isEmpty || tier.price <= 0 || tier.stock <= 0) {
          _showError('Please complete all ticket tier details');
          return;
        }
      }
    }

    FocusScope.of(context).unfocus();

    // Capture values before clearing
    final title = _titleController.text.trim();
    final location = _locationController.text.trim();
    final description = _descriptionController.text.trim();
    final category = createProvider.selectedCategory!;
    final images = List<File>.from(createProvider.selectedImages);
    final eventDate = createProvider.selectedDate!;
    final eventTime = DateTime(
      eventDate.year,
      eventDate.month,
      eventDate.day,
      createProvider.selectedTime!.hour,
      createProvider.selectedTime!.minute,
    );
    final isFree = createProvider.isFree;
    final sellOnCampcon = createProvider.sellOnCampcon;
    final hasMultipleTiers = createProvider.hasMultipleTiers;
    final ticketTiers = List.of(createProvider.ticketTiers);
    final price = isFree || hasMultipleTiers
        ? null
        : double.tryParse(_priceController.text.trim());
    final ticketLink = _ticketLinkController.text.trim().isEmpty
        ? null
        : _ticketLinkController.text.trim();
    final ticketStock = sellOnCampcon && !isFree && !hasMultipleTiers
        ? int.tryParse(_ticketStockController.text.trim())
        : null;

    // Clear text controllers
    _titleController.clear();
    _locationController.clear();
    _descriptionController.clear();
    _priceController.clear();
    _ticketLinkController.clear();
    _ticketStockController.clear();

    // Clear form in provider
    createProvider.clearForm();

    Navigator.of(context).pop();

    // Create event
    final success = await createProvider.createEventSilently(
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
      images: images.isNotEmpty ? images : null,
      sellOnCampcon: sellOnCampcon,
      ticketStock: ticketStock,
      ticketTiers: hasMultipleTiers ? ticketTiers : null,
      hasMultipleTiers: hasMultipleTiers,
    );

    if (success) {
      // Refresh events list
      eventProvider.refreshEvents(school);
    }

    debugPrint(success ? '✓ Event created' : '❌ Failed to create event');
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
    return Consumer<EventCreateProvider>(
      builder: (context, provider, child) {
        return Scaffold(
          backgroundColor: Theme.of(context).colorScheme.surface,
          body: SafeArea(
            child: Column(
              children: [
                const CreateEventHeader(),
                Expanded(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.all(20.w),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const CreateEventImages(),
                        SizedBox(height: 20.h),
                        CreateEventTextField(
                          label: 'Event Title *',
                          controller: _titleController,
                          hint: 'e.g. Campus Music Festival 2024',
                        ),
                        SizedBox(height: 16.h),
                        const CreateEventCategory(),
                        SizedBox(height: 16.h),
                        CreateEventTextField(
                          label: 'Location *',
                          controller: _locationController,
                          hint: 'e.g. Sports Complex, Main Hall',
                        ),
                        SizedBox(height: 16.h),
                        CreateEventTextField(
                          label: 'Description *',
                          controller: _descriptionController,
                          hint:
                              'Describe your event, activities, what to expect...',
                          maxLines: 5,
                        ),
                        SizedBox(height: 20.h),
                        const CreateEventDateTime(),
                        SizedBox(height: 20.h),
                        CreateEventPricing(
                          priceController: _priceController,
                          ticketStockController: _ticketStockController,
                          ticketLinkController: _ticketLinkController,
                        ),
                        // Ticket Tiers (shows only when sellOnCampcon && !isFree)
                        if (!provider.isFree && provider.sellOnCampcon) ...[
                          SizedBox(height: 20.h),
                          const CreateEventTicketTiers(),
                        ],
                      ],
                    ),
                  ),
                ),
                CreateEventButton(onPressed: _createEvent),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _locationController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _ticketLinkController.dispose();
    _ticketStockController.dispose();
    super.dispose();
  }
}
