import 'package:flutter_test/flutter_test.dart';
import 'package:bolitero_cubano/core/utils/reduction_engine.dart';

void main() {
  group('ReductionEngine Tests', () {
    test('generate should intersect tens and terminals', () {
      final res = ReductionEngine.generate(
        tens: {1, 4},
        terminals: {5},
        parity: ParityFilter.all,
      );
      expect(res, {'15', '45'});
    });

    test('generate with pairsOnly should filter out odd numbers', () {
      final res = ReductionEngine.generate(
        tens: {2},
        terminals: {0, 1, 2, 3},
        parity: ParityFilter.pairsOnly,
      );
      expect(res, {'20', '22'});
    });

    test('generate with empty sets should default to 0-9', () {
      final res = ReductionEngine.generate(
        tens: {},
        terminals: {5},
        parity: ParityFilter.all,
      );
      expect(res.length, 10);
      expect(res.contains('05'), true);
      expect(res.contains('95'), true);
    });
  });
}
