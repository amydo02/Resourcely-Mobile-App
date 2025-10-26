import 'package:flutter/material.dart';
import '../models/bus_route_model.dart';
import '../utils/brand_colors.dart';

class BusRouteCard extends StatelessWidget {
  final BusRouteModel busRoute;

  const BusRouteCard({
    super.key,
    required this.busRoute,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: BrandColors.slateGray.withOpacity(0.1),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: busRoute.color,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              busRoute.routeNumber,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: 18,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  busRoute.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                    color: BrandColors.textDark,
                  ),
                ),
                Text(
                  busRoute.description,
                  style: const TextStyle(
                    fontSize: 12,
                    color: BrandColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Next: ${busRoute.nextArrival}',
                  style: const TextStyle(
                    fontSize: 12,
                    color: BrandColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: busRoute.isOnTime
                  ? BrandColors.successGreen.withOpacity(0.2)
                  : BrandColors.alertYellow.withOpacity(0.3),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              busRoute.isOnTime ? 'On Time' : 'Delayed',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: busRoute.isOnTime ? BrandColors.successGreen : const Color(0xFFE6A800),
              ),
            ),
          ),
        ],
      ),
    );
  }
}