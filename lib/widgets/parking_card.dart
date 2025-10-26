import 'package:flutter/material.dart';
import '../models/parking_model.dart';
import '../utils/brand_colors.dart';

class ParkingCard extends StatelessWidget {
  final ParkingModel parking;

  const ParkingCard({
    super.key,
    required this.parking,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: parking.color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(Icons.local_parking, color: parking.color, size: 28),
          ),
          const SizedBox(height: 12),
          Text(
            parking.name,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: BrandColors.textDark,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '${parking.availablePercentage}%',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w700,
              color: parking.color,
            ),
          ),
          const Text(
            'Available',
            style: TextStyle(
              fontSize: 11,
              color: BrandColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}