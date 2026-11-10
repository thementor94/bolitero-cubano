class BolitaCalculator {
  /// Calcula la Pirámide Pascal Modulo 10 a partir de una cadena de dígitos.
  /// Ejemplo para Pick 3 "415":
  /// Nivel 0: [4, 1, 5]
  /// Nivel 1: [(4+1)%10, (1+5)%10] = [5, 6]
  /// Nivel 2: [(5+6)%10] = [1]
  static List<List<int>> calculatePyramid(String rawNumbers) {
    if (rawNumbers.isEmpty) return [];
    final digits = rawNumbers
        .replaceAll(RegExp(r'\D'), '')
        .split('')
        .map(int.parse)
        .toList();
    if (digits.isEmpty) return [];

    final pyramid = <List<int>>[digits];
    while (pyramid.last.length > 1) {
      final current = pyramid.last;
      final next = <int>[];
      for (int i = 0; i < current.length - 1; i++) {
        next.add((current[i] + current[i + 1]) % 10);
      }
      pyramid.add(next);
    }
    return pyramid;
  }

  /// Extrae los números sugeridos a partir de los niveles de la pirámide
  static List<String> extractPyramidSuggestions(List<List<int>> pyramid) {
    if (pyramid.length < 2) return [];
    final suggestions = <String>{};
    for (int i = 0; i < pyramid.length; i++) {
      final row = pyramid[i];
      if (row.length >= 2) {
        for (int j = 0; j < row.length - 1; j++) {
          suggestions.add("${row[j]}${row[j + 1]}");
        }
      }
    }
    final top = pyramid.last.first;
    final baseFirst = pyramid.first.first;
    final baseLast = pyramid.first.last;
    suggestions.add("$baseFirst$top");
    suggestions.add("$top$baseLast");
    return suggestions.toList();
  }

  /// Calcula la Cruz de la Suerte Numérica para una fecha dada.
  static Map<String, int> calculateLuckCross(DateTime date) {
    final c = (date.day + 3) % 10;
    final n = (c + 3) % 10;
    final s = (c + 6) % 10;
    final e = (n + s) % 10;
    final w = (n - s).abs() % 10;
    return {'center': c, 'north': n, 'south': s, 'east': e, 'west': w};
  }

  /// Parejas resultantes cruzadas
  static List<String> calculateCrossPairs(Map<String, int> cross) {
    final c = cross['center']!;
    final n = cross['north']!;
    final s = cross['south']!;
    final e = cross['east']!;
    final w = cross['west']!;
    return ["$c$n", "$c$w", "$c$e", "$c$s"];
  }

  /// Tabla de Equivalencias (+25, -25, Espejo e Inverso)
  static Map<String, String> calculateEquivalencies(int number) {
    final p25 = (number + 25) % 100;
    final m25 = (number - 25 + 100) % 100;
    
    // Regla del Espejo tradicional de la Bolita: sumar 5 a cada dígito módulo 10
    final d = (number ~/ 10 + 5) % 10;
    final u = (number % 10 + 5) % 10;
    final espejo = d * 10 + u;

    // Regla del Inverso (virado)
    final inverso = (number % 10) * 10 + (number ~/ 10);

    return {
      'plus25': p25.toString().padLeft(2, '0'),
      'minus25': m25.toString().padLeft(2, '0'),
      'espejo': espejo.toString().padLeft(2, '0'),
      'inverso': inverso.toString().padLeft(2, '0'),
    };
  }

  /// Generador de Candados C(n, 2) a partir de una lista de números
  static List<String> generateCandados(List<String> numbers) {
    final clean = numbers.toSet().toList();
    final pairs = <String>[];
    for (int i = 0; i < clean.length; i++) {
      for (int j = i + 1; j < clean.length; j++) {
        pairs.add("${clean[i]}-${clean[j]}");
      }
    }
    return pairs;
  }
}
