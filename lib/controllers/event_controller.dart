import 'package:flutter/material.dart';
import '../models/event_model.dart';
import '../utils/brand_colors.dart';

class EventController {
  List<EventModel> _events = [];

  List<EventModel> get events => _events;

  // Load events from data source
  Future<void> loadEvents() async {
    await Future.delayed(const Duration(milliseconds: 500));
    
    _events = [
      EventModel(
        id: '1',
        title: 'Career Fair',
        date: 'Oct 15',
        location: 'Event Center',
        color: BrandColors.highlightBlue,
        description: '200+ employers attending',
      ),
      EventModel(
        id: '2',
        title: 'Campus Movie Night',
        date: 'Oct 18',
        location: 'Student Union',
        color: const Color(0xFFB794F6),
        description: 'Free movie screening for students',
      ),
      EventModel(
        id: '3',
        title: 'Football Game',
        date: 'Oct 22',
        location: 'CEFCU Stadium',
        color: BrandColors.successGreen,
        description: 'SJSU vs Fresno State',
      ),
      EventModel(
        id: '4',
        title: 'Tech Hackathon',
        date: 'Oct 25',
        location: 'Engineering Bldg',
        color: const Color(0xFFFF9F43),
        description: '24-hour coding competition',
      ),
    ];
  }

  // Get upcoming events (limited by count)
  List<EventModel> getUpcomingEvents({int limit = 10}) {
    return _events.take(limit).toList();
  }

  // Get event by ID
  EventModel? getEventById(String id) {
    try {
      return _events.firstWhere((event) => event.id == id);
    } catch (e) {
      return null;
    }
  }

  // Search events by query
  List<EventModel> searchEvents(String query) {
    if (query.isEmpty) return _events;
    
    return _events.where((event) {
      return event.title.toLowerCase().contains(query.toLowerCase()) ||
             event.location.toLowerCase().contains(query.toLowerCase()) ||
             (event.description?.toLowerCase().contains(query.toLowerCase()) ?? false);
    }).toList();
  }

  // Filter events by date range
  List<EventModel> filterEventsByDateRange(String startDate, String endDate) {
    // TODO: Implement actual date comparison
    return _events;
  }

  // RSVP for event (mock implementation)
  Future<bool> rsvpForEvent(String eventId) async {
    try {
      // TODO: Implement actual RSVP logic with API
      await Future.delayed(const Duration(seconds: 1));
      print('RSVP for event: $eventId');
      return true;
    } catch (e) {
      print('Error RSVP for event: $e');
      return false;
    }
  }

  // Get event count
  int get eventCount => _events.length;

  // Check if there are upcoming events
  bool get hasUpcomingEvents => _events.isNotEmpty;
}