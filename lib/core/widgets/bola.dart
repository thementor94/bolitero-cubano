import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class BolaFijo extends StatelessWidget {
  final String numero;
  final double size;

  const BolaFijo({
    super.key,
    required this.numero,
    this.size = 48.0,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: const BoxDecoration(
        color: AppColors.gold,
        shape: BoxShape.circle,
      ),
      alignment: Alignment.center,
      child: Text(
        numero.padLeft(2, '0'),
        style: TextStyle(
          fontFamily: 'JetBrainsMono',
          fontSize: size * 0.46,
          fontWeight: FontWeight.bold,
          color: AppColors.canvas,
        ),
      ),
    );
  }
}

class BolaCorrido extends StatelessWidget {
  final String numero;
  final double size;

  const BolaCorrido({
    super.key,
    required this.numero,
    this.size = 44.0,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: AppColors.card,
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.turquoise, width: 2.0),
      ),
      alignment: Alignment.center,
      child: Text(
        numero.padLeft(2, '0'),
        style: TextStyle(
          fontFamily: 'JetBrainsMono',
          fontSize: size * 0.42,
          fontWeight: FontWeight.bold,
          color: AppColors.text,
        ),
      ),
    );
  }
}

class CentenaPill extends StatelessWidget {
  final String centena;

  const CentenaPill({
    super.key,
    required this.centena,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.border,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        centena,
        style: const TextStyle(
          fontFamily: 'JetBrainsMono',
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: AppColors.gold,
        ),
      ),
    );
  }
}
