import 'package:flutter/material.dart';
import '../../controllers/transit_controller.dart';
import '../../utils/brand_colors.dart';
import '../../widgets/bus_route_card.dart';
import '../../widgets/parking_card.dart';

class TransitScreen extends StatefulWidget {
  const TransitScreen({super.key});

  @override
  State<TransitScreen> createState() => _TransitScreenState();
}

class _TransitScreenState extends State<TransitScreen> {
  final _transitController = TransitController();
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadTransitData();
  }

  Future<void> _loadTransitData() async {
    await _transitController.refreshTransitData();
    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _refreshData() async {
    setState(() => _isLoading = true);
    await _loadTransitData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: BrandColors.lightSurface,
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : RefreshIndicator(
                onRefresh: _refreshData,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Transit & Parking',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w700,
                          color: BrandColors.textDark,
                        ),
                      ),
                      const SizedBox(height: 20),
                      
                      // VTA Bus Routes Section
                      const Text(
                        'VTA Bus Routes',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: BrandColors.textDark,
                        ),
                      ),
                      const SizedBox(height: 16),
                      
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _transitController.busRoutes.length,
                        itemBuilder: (context, index) {
                          return BusRouteCard(
                            busRoute: _transitController.busRoutes[index],
                          );
                        },
                      ),
                      
                      const SizedBox(height: 32),
                      
                      // Campus Parking Section
                      const Text(
                        'Campus Parking',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: BrandColors.textDark,
                        ),
                      ),
                      const SizedBox(height: 16),
                      
                      GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                        ),
                        itemCount: _transitController.parkingGarages.length,
                        itemBuilder: (context, index) {
                          return ParkingCard(
                            parking: _transitController.parkingGarages[index],
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
      ),
    );
  }
}