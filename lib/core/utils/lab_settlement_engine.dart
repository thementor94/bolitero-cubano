class LabSettlementEngine {
  /// Máquina de estados para calificar apuestas virtuales sin intervención manual.
  /// Reglas estándar de la bolita:
  /// - Fijo: 70x
  /// - Centena: 300x
  /// - Corrido: 20x por cada aparición en corridos (hasta 40x)
  /// - Parlé Fijo + Corrido: 900x (o 1000x según banquero/región)
  /// - Parlé Corrido + Corrido: 100x (o 200x según banquero/región)
  static Map<String, dynamic> evaluatePlay({
    required String playType,
    required String betNumbers,
    required double virtualPoints,
    required String drawFijo,
    required String drawCentena,
    required String? drawCorrido1,
    required String? drawCorrido2,
    double parleFijoMultiplier = 900.0,
    double parleCorridoMultiplier = 100.0,
  }) {
    bool isWon = false;
    double payoutMultiplier = 0.0;

    final bet = betNumbers.trim();
    switch (playType.toLowerCase()) {
      case 'fijo':
        if (bet.padLeft(2, '0') == drawFijo.padLeft(2, '0')) {
          isWon = true;
          payoutMultiplier = 70.0;
        }
        break;

      case 'centena':
        // Centena de 3 dígitos (ej: "415")
        if (bet == drawCentena || (bet.length == 1 && drawCentena.startsWith(bet))) {
          isWon = true;
          payoutMultiplier = 300.0;
        }
        break;

      case 'corrido':
        int hits = 0;
        final padBet = bet.padLeft(2, '0');
        if (padBet == drawCorrido1?.padLeft(2, '0')) hits++;
        if (padBet == drawCorrido2?.padLeft(2, '0')) hits++;
        if (hits > 0) {
          isWon = true;
          payoutMultiplier = 20.0 * hits;
        }
        break;

      case 'parle':
        final parts = bet.split(RegExp(r'[-x✕\s]+'));
        if (parts.length >= 2) {
          final n1 = parts[0].padLeft(2, '0');
          final n2 = parts[1].padLeft(2, '0');
          final winners = {drawFijo, drawCorrido1, drawCorrido2}..remove(null);
          if (winners.contains(n1) && winners.contains(n2)) {
            isWon = true;
            final hasFijo = (n1 == drawFijo || n2 == drawFijo);
            payoutMultiplier = hasFijo ? parleFijoMultiplier : parleCorridoMultiplier;
          }
        }
        break;
    }

    final totalPayout = isWon ? (virtualPoints * payoutMultiplier) : 0.0;
    return {
      'status': isWon ? 'won' : 'lost',
      'payoutMultiplier': payoutMultiplier,
      'totalPayout': totalPayout,
      'settledAt': DateTime.now().millisecondsSinceEpoch,
    };
  }
}
