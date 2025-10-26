import 'package:http/http.dart' as http;

class ICalService {
  // Fetch and parse iCal feed from Canvas
  Future<List<Map<String, dynamic>>> fetchCalendarFeed(String feedUrl) async {
    try {
      final response = await http.get(Uri.parse(feedUrl));
      
      if (response.statusCode == 200) {
        return _parseICalData(response.body);
      } else {
        throw Exception('Failed to load calendar feed: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching calendar feed: $e');
      rethrow;
    }
  }
  
  // Parse iCal format data
  List<Map<String, dynamic>> _parseICalData(String icalData) {
    final events = <Map<String, dynamic>>[];
    final lines = icalData.split('\n');
    
    Map<String, dynamic>? currentEvent;
    String? currentKey;
    String currentValue = '';
    
    for (var line in lines) {
      line = line.trim();
      
      // Start of new event
      if (line == 'BEGIN:VEVENT') {
        currentEvent = {};
        continue;
      }
      
      // End of event
      if (line == 'END:VEVENT') {
        if (currentEvent != null && currentEvent.isNotEmpty) {
          events.add(currentEvent);
        }
        currentEvent = null;
        currentKey = null;
        currentValue = '';
        continue;
      }
      
      // Skip if not in an event
      if (currentEvent == null) continue;
      
      // Handle multi-line values (lines starting with space or tab)
      if (line.startsWith(' ') || line.startsWith('\t')) {
        currentValue += line.substring(1);
        continue;
      }
      
      // Save previous key-value pair
      if (currentKey != null && currentValue.isNotEmpty) {
        currentEvent[currentKey] = _cleanValue(currentValue);
      }
      
      // Parse new key-value pair
      final colonIndex = line.indexOf(':');
      if (colonIndex > 0) {
        var key = line.substring(0, colonIndex);
        currentValue = line.substring(colonIndex + 1);
        
        // Remove parameters from key (e.g., "DTSTART;VALUE=DATE" -> "DTSTART")
        final semicolonIndex = key.indexOf(';');
        if (semicolonIndex > 0) {
          key = key.substring(0, semicolonIndex);
        }
        
        currentKey = key;
      }
    }
    
    return events;
  }
  
  // Clean and decode iCal values
  String _cleanValue(String value) {
    // Remove carriage returns
    value = value.replaceAll('\r', '');
    
    // Unescape special characters
    value = value.replaceAll('\\n', '\n');
    value = value.replaceAll('\\,', ',');
    value = value.replaceAll('\\;', ';');
    value = value.replaceAll('\\\\', '\\');
    
    return value;
  }
  
  // Parse date/time from iCal format
  DateTime? parseICalDateTime(String? dateTimeStr) {
    if (dateTimeStr == null || dateTimeStr.isEmpty) return null;
    
    try {
      // Remove timezone identifier if present (e.g., "20241015T120000Z" or "20241015")
      dateTimeStr = dateTimeStr.replaceAll('Z', '').replaceAll('T', '');
      
      // Parse different formats
      if (dateTimeStr.length >= 8) {
        final year = int.parse(dateTimeStr.substring(0, 4));
        final month = int.parse(dateTimeStr.substring(4, 6));
        final day = int.parse(dateTimeStr.substring(6, 8));
        
        // Check if time is included
        if (dateTimeStr.length >= 14) {
          final hour = int.parse(dateTimeStr.substring(8, 10));
          final minute = int.parse(dateTimeStr.substring(10, 12));
          final second = int.parse(dateTimeStr.substring(12, 14));
          return DateTime(year, month, day, hour, minute, second);
        } else {
          return DateTime(year, month, day);
        }
      }
    } catch (e) {
      print('Error parsing date: $dateTimeStr - $e');
    }
    
    return null;
  }
  
  // Convert iCal event to our format
  Map<String, dynamic> convertToAssignment(Map<String, dynamic> icalEvent) {
    final dtStart = parseICalDateTime(icalEvent['DTSTART']);
    final dtEnd = parseICalDateTime(icalEvent['DTEND']);
    
    return {
      'id': icalEvent['UID'] ?? DateTime.now().millisecondsSinceEpoch.toString(),
      'title': icalEvent['SUMMARY'] ?? 'Untitled',
      'description': icalEvent['DESCRIPTION'],
      'location': icalEvent['LOCATION'],
      'start_at': dtStart?.toIso8601String(),
      'end_at': dtEnd?.toIso8601String(),
      'url': icalEvent['URL'],
    };
  }
  
  // Test if URL is a valid iCal feed
  Future<bool> isValidICalFeed(String url) async {
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        // Check if it starts with iCal header
        return response.body.contains('BEGIN:VCALENDAR');
      }
      return false;
    } catch (e) {
      return false;
    }
  }
}