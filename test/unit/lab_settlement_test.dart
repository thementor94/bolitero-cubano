import 'package:flutter_test/flutter_test.dart';
import 'package:bolitero_cubano/core/utils/lab_settlement_engine.dart';

void main() {
  group('LabSettlementEngine Tests', () {
    test('evaluatePlay win for Fijo pays 70x', () {
      final res = LabSettlementEngine.evaluatePlay(
        playType: 'fijo',
        betNumbers: '15',
        virtualPoints: 10.0,
        drawFijo: '15',
        drawCentena: '415',
        drawCorrido1: '31',
        drawCorrido2: '08',
      );

      expect(res['status'], 'won');
      expect(res['payoutMultiplier'], 70.0);
      expect(res['totalPayout'], 700.0);
    });

    test('evaluatePlay win for Centena pays 300x', () {
      final res = LabSettlementEngine.evaluatePlay(
        playType: 'centena',
        betNumbers: '415',
        virtualPoints: 5.0,
        drawFijo: '15',
        drawCentena: '415',
        drawCorrido1: '31',
        drawCorrido2: '08',
      );

      expect(res['status'], 'won');
      expect(res['payoutMultiplier'], 300.0);
      expect(res['totalPayout'], 1500.0);
    });

    test('evaluatePlay win for Parlé (Fijo + Corrido) pays 900x', () {
      final res = LabSettlementEngine.evaluatePlay(
        playType: 'parle',
        betNumbers: '15-31',
        virtualPoints: 2.0,
        drawFijo: '15',
        drawCentena: '415',
        drawCorrido1: '31',
        drawCorrido2: '08',
      );

      expect(res['status'], 'won');
      expect(res['payoutMultiplier'], 900.0);
      expect(res['totalPayout'], 1800.0);
    });

    test('evaluatePlay loss returns 0 payout and lost status', () {
      final res = LabSettlementEngine.evaluatePlay(
        playType: 'fijo',
        betNumbers: '99',
        virtualPoints: 10.0,
        drawFijo: '15',
        drawCentena: '415',
        drawCorrido1: '31',
        drawCorrido2: '08',
      );

      expect(res['status'], 'lost');
      expect(res['payoutMultiplier'], 0.0);
      expect(res['totalPayout'], 0.0);
    });
  });
}
