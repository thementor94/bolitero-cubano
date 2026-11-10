import 'package:flutter_test/flutter_test.dart';
import 'package:bolitero_cubano/core/utils/bolita_calculator.dart';

void main() {
  group('BolitaCalculator Tests', () {
    test('calculatePyramid should calculate Pascal modulo 10 correctly', () {
      final pyramid = BolitaCalculator.calculatePyramid('415');
      expect(pyramid.length, 3);
      expect(pyramid[0], [4, 1, 5]);
      expect(pyramid[1], [5, 6]); // (4+1)%10=5, (1+5)%10=6
      expect(pyramid[2], [1]);    // (5+6)%10=1
    });

    test('calculateEquivalencies should compute +25, -25, espejo and inverso', () {
      final eq = BolitaCalculator.calculateEquivalencies(15);
      expect(eq['plus25'], '40');
      expect(eq['minus25'], '90');
      expect(eq['espejo'], '60'); // 1->6, 5->0
      expect(eq['inverso'], '51');
    });

    test('calculateLuckCross3x3 should produce a valid 3x3 matrix', () {
      final date = DateTime(2026, 11, 10);
      final matrix = BolitaCalculator.calculateLuckCross3x3(date);
      expect(matrix.length, 3);
      expect(matrix[0].length, 3);
      expect(matrix[1].length, 3);
      expect(matrix[2].length, 3);

      final pairs = BolitaCalculator.extractCrossPairs3x3(matrix);
      expect(pairs.isNotEmpty, true);
    });

    test('generateParles should produce unique combinations', () {
      final parles = BolitaCalculator.generateParles(['15', '31', '46']);
      expect(parles.length, 3);
      expect(parles.contains('15 - 31'), true);
      expect(parles.contains('15 - 46'), true);
      expect(parles.contains('31 - 46'), true);
    });
  });
}
