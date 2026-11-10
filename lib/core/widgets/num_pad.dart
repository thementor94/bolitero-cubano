import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class NumPad extends StatelessWidget {
  final Function(String) onDigit;
  final VoidCallback onDelete;
  final VoidCallback? onClear;

  const NumPad({
    super.key,
    required this.onDigit,
    required this.onDelete,
    this.onClear,
  });

  Widget _buildKey(String label, {VoidCallback? onTap, Color? color}) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(4.0),
        child: Material(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(12),
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: onTap ?? () => onDigit(label),
            child: Container(
              height: 52,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.border, width: 1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                label,
                style: TextStyle(
                  fontFamily: 'JetBrainsMono',
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: color ?? AppColors.text,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            _buildKey("1"),
            _buildKey("2"),
            _buildKey("3"),
          ],
        ),
        Row(
          children: [
            _buildKey("4"),
            _buildKey("5"),
            _buildKey("6"),
          ],
        ),
        Row(
          children: [
            _buildKey("7"),
            _buildKey("8"),
            _buildKey("9"),
          ],
        ),
        Row(
          children: [
            _buildKey("C", onTap: onClear ?? onDelete, color: AppColors.cold),
            _buildKey("0"),
            _buildKey("⌫", onTap: onDelete, color: AppColors.gold),
          ],
        ),
      ],
    );
  }
}
