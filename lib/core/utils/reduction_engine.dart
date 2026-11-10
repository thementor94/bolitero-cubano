enum ParityFilter {
  all,
  pairsOnly,
  oddsOnly,
}

class ReductionEngine {
  /// Motor de combinatoria y reducción numérica por decenas, terminales y paridad.
  /// Si el conjunto de decenas está vacío, se asumen todas las decenas (0 al 9).
  /// Si el conjunto de terminales está vacío, se asumen todos los terminales (0 al 9).
  static Set<String> generate({
    required Set<int> tens,
    required Set<int> terminals,
    required ParityFilter parity,
  }) {
    final activeTens = tens.isEmpty ? {0, 1, 2, 3, 4, 5, 6, 7, 8, 9} : tens;
    final activeTerminals = terminals.isEmpty ? {0, 1, 2, 3, 4, 5, 6, 7, 8, 9} : terminals;

    final results = <String>{};

    for (final d in activeTens) {
      if (d < 0 || d > 9) continue;
      for (final u in activeTerminals) {
        if (u < 0 || u > 9) continue;
        final value = d * 10 + u;

        switch (parity) {
          case ParityFilter.all:
            results.add(value.toString().padLeft(2, '0'));
            break;
          case ParityFilter.pairsOnly:
            if (value % 2 == 0) {
              results.add(value.toString().padLeft(2, '0'));
            }
            break;
          case ParityFilter.oddsOnly:
            if (value % 2 != 0) {
              results.add(value.toString().padLeft(2, '0'));
            }
            break;
        }
      }
    }

    return results;
  }
}
