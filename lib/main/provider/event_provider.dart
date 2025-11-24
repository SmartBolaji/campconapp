


import 'package:flutter/material.dart';

class EventProvider extends ChangeNotifier {
  // A list to hold all the events
  final List<Map<String, String>> _events = [];

  // Getters for the event data
  List<Map<String, String>> get events => _events;

  // Your existing state variables
  String _eventName = '';
  String _eventDescription = '';
  String _location = '';
  String _ticketLink = '';
  String? _eventImage;

  String get eventName => _eventName;
  String get eventDescription => _eventDescription;
  String get location => _location;
  String get ticketLink => _ticketLink;
  String? get eventImage => _eventImage;

  // Your existing update methods
  void updateEventName(String name) {
    _eventName = name;
    notifyListeners();
  }

  void updateEventDescription(String description) {
    _eventDescription = description;
    notifyListeners();
  }

  void updateLocation(String location) {
    _location = location;
    notifyListeners();
  }

  void updateTicketLink(String link) {
    _ticketLink = link;
    notifyListeners();
  }

  void updateEventImage(String? image) {
    _eventImage = image;
    notifyListeners();
  }

  void createEvent() {
    // Create a map with the current form data
    final newEvent = {
      'name': _eventName,
      'description': _eventDescription,
      'location': _location,
      'ticketLink': _ticketLink,
      'image': _eventImage ?? '', // Handle the nullable image
    };
    // Add the new event to the list
    _events.add(newEvent);
    // Clear the form fields after creation
    clearForm();
    // Notify listeners to rebuild the UI
    notifyListeners();
  }

  void clearForm() {
    _eventName = '';
    _eventDescription = '';
    _location = '';
    _ticketLink = '';
    _eventImage = null;
    notifyListeners();
  }
}