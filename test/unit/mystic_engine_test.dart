import 'package:flutter_test/flutter_test.dart';
import 'package:bolitero_cubano/core/utils/mystic_engine.dart';

void main() {
  group('MysticEngine Tests', () {
    test('generateDailyHoroscope should be strictly deterministic for same sign and date', () {
      final date = DateTime(2026, 11, 10);
      final h1 = MysticEngine.generateDailyHoroscope(sign: 'Aries', date: date);
      final h2 = MysticEngine.generateDailyHoroscope(sign: 'Aries', date: date);

      expect(h1['luckyNumbers'], h2['luckyNumbers']);
      expect(h1['advice'], h2['advice']);
      expect((h1['luckyNumbers'] as List).length, 3);
    });

    test('getResonatingOrisha should return valid Orisha with sacred numbers', () {
      final orisha = MysticEngine.getResonatingOrisha(15);
      expect(orisha.name.isNotEmpty, true);
      expect(orisha.sacredNumbers.isNotEmpty, true);
    });

    test('all 8 Orishas exist and have sacred numbers', () {
      expect(MysticEngine.orishas.length, 8);
      expect(MysticEngine.orishas.containsKey('Eleguá'), true);
      expect(MysticEngine.orishas.containsKey('Changó'), true);
    });
  });
}
