// import 'dart:convert';
// import 'package:http/http.dart' as http;
// import 'package:html/parser.dart' show parse;
// import '../models/bus_route_model.dart';
// import '../models/parking_model.dart';
// import '../utils/brand_colors.dart';

// class TransitService {
//   // VTA 511.org API configuration
//   static const String _vtaApiKey = 'YOUR_511_API_KEY'; // Get from https://511.org/developers
//   static const String _vtaBaseUrl = 'https://api.511.org/transit';
  
//   // SJSU Parking Status URL
//   static const String _sjsuParkingUrl = 'https://sjsuparkingstatus.sjsu.edu/';
  
//   // SJSU bus stops near campus
//   static const Map<String, String> _sjsuBusStops = {
//     '72': '53165', // Example stop ID for Route 72 near SJSU
//     '73': '53166', // Example stop ID for Route 73 near SJSU
//     '22': '53167', // Example stop ID for Route 22 near SJSU
//   };

//   /// Fetch real-time VTA bus arrival times
//   Future<List<BusRouteModel>> fetchBusRoutes() async {
//     try {
//       List<BusRouteModel> routes = [];
      
//       for (var entry in _sjsuBusStops.entries) {
//         String routeNumber = entry.key;
//         String stopId = entry.value;
        
//         // Fetch real-time arrivals from VTA 511 API
//         final response = await http.get(
//           Uri.parse(
//             '$_vtaBaseUrl/StopMonitoring?api_key=$_vtaApiKey&agency=VTA&stopCode=$stopId&format=json'
//           ),
//         ).timeout(const Duration(seconds: 10));

//         if (response.statusCode == 200) {
//           final data = json.decode(response.body);
          
//           // Parse VTA response
//           var route = _parseVTAResponse(data, routeNumber);
//           if (route != null) {
//             routes.add(route);
//           }
//         }
//       }
      
//       // If API fails, return mock data
//       if (routes.isEmpty) {
//         return _getMockBusRoutes();
//       }
      
//       return routes;
//     } catch (e) {
//       print('Error fetching VTA data: $e');
//       // Return mock data on error
//       return _getMockBusRoutes();
//     }
//   }

//   /// Parse VTA 511 API response
//   BusRouteModel? _parseVTAResponse(Map<String, dynamic> data, String routeNumber) {
//     try {
//       var deliveries = data['ServiceDelivery']?['StopMonitoringDelivery'];
//       if (deliveries == null || deliveries.isEmpty) return null;
      
//       var visits = deliveries[0]?['MonitoredStopVisit'];
//       if (visits == null || visits.isEmpty) return null;
      
//       var journey = visits[0]?['MonitoredVehicleJourney'];
//       if (journey == null) return null;
      
//       // Get arrival time
//       var aimedArrival = journey['MonitoredCall']?['AimedArrivalTime'];
//       var expectedArrival = journey['MonitoredCall']?['ExpectedArrivalTime'];
      
//       DateTime? arrivalTime = DateTime.tryParse(expectedArrival ?? aimedArrival ?? '');
//       String nextArrival = 'Unknown';
//       bool isOnTime = true;
      
//       if (arrivalTime != null) {
//         int minutesUntil = arrivalTime.difference(DateTime.now()).inMinutes;
//         nextArrival = minutesUntil <= 1 ? 'Arriving' : '$minutesUntil minutes';
        
//         // Check if delayed (more than 5 minutes from aimed time)
//         if (aimedArrival != null && expectedArrival != null) {
//           DateTime? aimedTime = DateTime.tryParse(aimedArrival);
//           if (aimedTime != null) {
//             isOnTime = arrivalTime.difference(aimedTime).inMinutes <= 5;
//           }
//         }
//       }
      
//       return BusRouteModel(
//         routeNumber: routeNumber,
//         name: 'Route $routeNumber',
//         description: _getRouteDescription(routeNumber),
//         nextArrival: nextArrival,
//         color: _getRouteColor(routeNumber),
//         isOnTime: isOnTime,
//       );
//     } catch (e) {
//       print('Error parsing VTA response: $e');
//       return null;
//     }
//   }

//   /// Fetch SJSU parking garage availability
//   Future<List<ParkingModel>> fetchParkingStatus() async {
//     try {
//       final response = await http.get(
//         Uri.parse(_sjsuParkingUrl),
//       ).timeout(const Duration(seconds: 10));

//       if (response.statusCode == 200) {
//         return _parseParkingHtml(response.body);
//       } else {
//         print('Error fetching parking data: ${response.statusCode}');
//         return _getMockParkingData();
//       }
//     } catch (e) {
//       print('Error fetching parking data: $e');
//       return _getMockParkingData();
//     }
//   }

//   /// Parse SJSU parking status HTML
//   List<ParkingModel> _parseParkingHtml(String htmlContent) {
//     try {
//       var document = html_parser.parse(htmlContent);
//       List<ParkingModel> parkingList = [];
      
//       // Find all parking garage entries (adjust selectors based on actual HTML structure)
//       var garages = document.querySelectorAll('.garage-status, .parking-garage, tr');
      
//       for (var garage in garages) {
//         String? name;
//         int? availablePercentage;
        
//         // Try to extract garage name and availability
//         // The actual selectors depend on the HTML structure of the website
//         var nameElement = garage.querySelector('.garage-name, .name, td:first-child');
//         var statusElement = garage.querySelector('.availability, .status, .percentage, td:nth-child(2)');
        
//         if (nameElement != null) {
//           name = nameElement.text.trim();
//         }
        
//         if (statusElement != null) {
//           String statusText = statusElement.text.trim();
//           // Try to extract percentage from text like "65% Available" or "65%"
//           RegExp percentageRegex = RegExp(r'(\d+)%');
//           var match = percentageRegex.firstMatch(statusText);
//           if (match != null) {
//             availablePercentage = int.tryParse(match.group(1)!);
//           }
//         }
        
//         // Create parking model if we have valid data
//         if (name != null && availablePercentage != null) {
//           // Match common SJSU garage names
//           if (name.toLowerCase().contains('south') && !name.toLowerCase().contains('campus')) {
//             parkingList.add(ParkingModel(
//               id: '1',
//               name: 'South Garage',
//               availablePercentage: availablePercentage,
//               color: _getParkingColor(availablePercentage),
//             ));
//           } else if (name.toLowerCase().contains('north')) {
//             parkingList.add(ParkingModel(
//               id: '2',
//               name: 'North Garage',
//               availablePercentage: availablePercentage,
//               color: _getParkingColor(availablePercentage),
//             ));
//           } else if (name.toLowerCase().contains('west')) {
//             parkingList.add(ParkingModel(
//               id: '3',
//               name: 'West Garage',
//               availablePercentage: availablePercentage,
//               color: _getParkingColor(availablePercentage),
//             ));
//           } else if (name.toLowerCase().contains('south campus')) {
//             parkingList.add(ParkingModel(
//               id: '4',
//               name: 'South Campus',
//               availablePercentage: availablePercentage,
//               color: _getParkingColor(availablePercentage),
//             ));
//           }
//         }
//       }
      
//       // If parsing failed, return mock data
//       return parkingList.isEmpty ? _getMockParkingData() : parkingList;
//     } catch (e) {
//       print('Error parsing parking HTML: $e');
//       return _getMockParkingData();
//     }
//   }

//   /// Get color based on parking availability
//   Color _getParkingColor(int percentage) {
//     if (percentage >= 50) return BrandColors.successGreen;
//     if (percentage >= 20) return BrandColors.alertYellow;
//     return const Color(0xFFFF6B6B);
//   }

//   /// Get route description
//   String _getRouteDescription(String routeNumber) {
//     switch (routeNumber) {
//       case '72':
//         return 'Downtown - SJSU';
//       case '73':
//         return 'Alum Rock - SJSU';
//       case '22':
//         return 'Palo Alto - SJSU';
//       default:
//         return 'SJSU Route';
//     }
//   }

//   /// Get route color
//   Color _getRouteColor(String routeNumber) {
//     switch (routeNumber) {
//       case '72':
//         return BrandColors.highlightBlue;
//       case '73':
//         return BrandColors.successGreen;
//       case '22':
//         return const Color(0xFFB794F6);
//       default:
//         return BrandColors.royalBlue;
//     }
//   }

//   /// Mock bus routes (fallback)
//   List<BusRouteModel> _getMockBusRoutes() {
//     return [
//       BusRouteModel(
//         routeNumber: '72',
//         name: 'Route 72',
//         description: 'Downtown - SJSU',
//         nextArrival: '5 minutes',
//         color: BrandColors.highlightBlue,
//         isOnTime: true,
//       ),
//       BusRouteModel(
//         routeNumber: '73',
//         name: 'Route 73',
//         description: 'Alum Rock - SJSU',
//         nextArrival: '12 minutes',
//         color: BrandColors.successGreen,
//         isOnTime: false,
//       ),
//       BusRouteModel(
//         routeNumber: '22',
//         name: 'Route 22',
//         description: 'Palo Alto - SJSU',
//         nextArrival: '8 minutes',
//         color: const Color(0xFFB794F6),
//         isOnTime: true,
//       ),
//     ];
//   }

//   /// Mock parking data (fallback)
//   List<ParkingModel> _getMockParkingData() {
//     return [
//       ParkingModel(
//         id: '1',
//         name: 'South Garage',
//         availablePercentage: 5,
//         color: const Color(0xFFFF6B6B),
//       ),
//       ParkingModel(
//         id: '2',
//         name: 'North Garage',
//         availablePercentage: 35,
//         color: const Color(0xFFFF9F43),
//       ),
//       ParkingModel(
//         id: '3',
//         name: 'West Garage',
//         availablePercentage: 62,
//         color: BrandColors.successGreen,
//       ),
//       ParkingModel(
//         id: '4',
//         name: 'South Campus',
//         availablePercentage: 48,
//         color: BrandColors.alertYellow,
//       ),
//     ];
//   }
// }