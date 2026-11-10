import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class OfflineBanner extends StatelessWidget {
  final String lastSyncText;

  const OfflineBanner({
    super.key,
    this.lastSyncText = "09/11 21:48",
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: AppColors.canvas,
      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: const BoxDecoration(
              color: AppColors.turquoise,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            "100% Offline · Datos del $lastSyncText",
            style: const TextStyle(
              fontSize: 11,
              color: AppColors.textMuted,
            ),
          ),
        ],
      ),
    );
  }
}
