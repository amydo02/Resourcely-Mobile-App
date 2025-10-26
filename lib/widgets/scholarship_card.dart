import 'package:flutter/material.dart';
import '../models/scholarship_model.dart';
import '../utils/brand_colors.dart';

class ScholarshipCard extends StatelessWidget {
  final ScholarshipModel scholarship;
  final VoidCallback? onApplyPressed;

  const ScholarshipCard({
    super.key,
    required this.scholarship,
    this.onApplyPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
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
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: scholarship.color.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.card_giftcard, color: scholarship.color, size: 24),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: scholarship.isOpen
                      ? BrandColors.successGreen.withOpacity(0.2)
                      : BrandColors.slateGray.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  scholarship.isOpen ? 'Open' : 'Closed',
                  style: TextStyle(
                    color: scholarship.isOpen ? BrandColors.successGreen : BrandColors.slateGray,
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            scholarship.title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: BrandColors.textDark,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            scholarship.description,
            style: const TextStyle(
              color: BrandColors.textSecondary,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.access_time, size: 16, color: BrandColors.textSecondary),
                  const SizedBox(width: 4),
                  Text(
                    'Deadline: ${scholarship.deadline}',
                    style: const TextStyle(
                      fontSize: 12,
                      color: BrandColors.textSecondary,
                    ),
                  ),
                ],
              ),
              GestureDetector(
                onTap: onApplyPressed,
                child: const Text(
                  'Apply →',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: BrandColors.royalBlue,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}