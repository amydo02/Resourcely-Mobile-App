import 'package:flutter/material.dart';
import '../models/bus_route_model.dart';
import '../models/parking_model.dart';
import '../utils/brand_colors.dart';

class TransitController {
  List<BusRouteModel> _busRoutes = [];
  List<ParkingModel> _parkingGarages = [];

  List<BusRouteModel> get busRoutes => _busRoutes;
  List<ParkingModel> get parkingGarages => _parkingGarages;

  // Load bus routes from data source
  Future<void> loadBusRoutes() async {
    await Future.delayed(const Duration(milliseconds: 500));
    
    _busRoutes = [
      BusRouteModel(
        routeNumber: '72',
        name: 'Route 72',
        description: 'Downtown - SJSU',
        nextArrival: '5 minutes',
        color: BrandColors.highlightBlue,
        isOnTime: true,
      ),
      BusRouteModel(
        routeNumber: '73',
        name: 'Route 73',
        description: 'Alum Rock - SJSU',
        nextArrival: '12 minutes',
        color: BrandColors.successGreen,
        isOnTime: false,
      ),
      BusRouteModel(
        routeNumber: '22',
        name: 'Route 22',
        description: 'Palo Alto - SJSU',
        nextArrival: '8 minutes',
        color: const Color(0xFFB794F6),
        isOnTime: true,
      ),
    ];
  }

  // Load parking garages from data source
  Future<void> loadParkingGarages() async {
    // TODO: Load from real-time API
    await Future.delayed(const Duration(milliseconds: 500));
    
    _parkingGarages = [
      ParkingModel(
        id: '1',
        name: 'South Garage',
        availablePercentage: 5,
        color: const Color(0xFFFF6B6B),
      ),
      ParkingModel(
        id: '2',
        name: 'North Garage',
        availablePercentage: 35,
        color: const Color(0xFFFF9F43),
      ),
      ParkingModel(
        id: '3',
        name: 'West Garage',
        availablePercentage: 62,
        color: BrandColors.successGreen,
      ),
      ParkingModel(
        id: '4',
        name: 'South Campus',
        availablePercentage: 48,
        color: BrandColors.alertYellow,
      ),
    ];
  }

  // Refresh all transit data
  Future<void> refreshTransitData() async {
    await Future.wait([
      loadBusRoutes(),
      loadParkingGarages(),
    ]);
  }

  // Get bus route by number
  BusRouteModel? getBusRouteByNumber(String routeNumber) {
    try {
      return _busRoutes.firstWhere((route) => route.routeNumber == routeNumber);
    } catch (e) {
      return null;
    }
  }

  // Get parking garage by ID
  ParkingModel? getParkingById(String id) {
    try {
      return _parkingGarages.firstWhere((parking) => parking.id == id);
    } catch (e) {
      return null;
    }
  }

  // Get available parking garages (>20% available)
  List<ParkingModel> getAvailableParkingGarages() {
    return _parkingGarages
        .where((parking) => parking.availablePercentage >= 20)
        .toList();
  }

  // Get on-time bus routes
  List<BusRouteModel> getOnTimeBusRoutes() {
    return _busRoutes.where((route) => route.isOnTime).toList();
  }
}