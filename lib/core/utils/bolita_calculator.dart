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

  /// Matriz 3x3 Tradicional de la Cruz de la Suerte Numérica a partir de una fecha DD/MM/YYYY.
  /// Fila 0: [d1, m1, y1]
  /// Fila 1: [d2, C,  m2]
  /// Fila 2: [s1, s2, y2]
  static List<List<int>> calculateLuckCross3x3(DateTime date) {
    final d1 = date.day ~/ 10;
    final d2 = date.day % 10;
    final m1 = date.month ~/ 10;
    final m2 = date.month % 10;
    final year2Digits = date.year % 100;
    final y1 = year2Digits ~/ 10;
    final y2 = year2Digits % 10;

    final center = (d1 + d2 + m1 + m2 + y1 + y2) % 10;
    final s1 = (d1 + d2) % 10;
    final s2 = (m1 + m2) % 10;

    return [
      [d1, m1, y1],
      [d2, center, m2],
      [s1, s2, y2],
    ];
  }

  /// Extrae las combinaciones de pares resultantes de la Cruz 3x3 (horizontales, verticales, diagonales y centro-cardinales)
  static List<String> extractCrossPairs3x3(List<List<int>> matrix) {
    if (matrix.length != 3 || matrix[0].length != 3) return [];
    final pairs = <String>{};

    // Horizontales
    for (int r = 0; r < 3; r++) {
      pairs.add("${matrix[r][0]}${matrix[r][1]}");
      pairs.add("${matrix[r][1]}${matrix[r][2]}");
    }

    // Verticales
    for (int c = 0; c < 3; c++) {
      pairs.add("${matrix[0][c]}${matrix[1][c]}");
      pairs.add("${matrix[1][c]}${matrix[2][c]}");
    }

    // Diagonales principales
    pairs.add("${matrix[0][0]}${matrix[1][1]}");
    pairs.add("${matrix[1][1]}${matrix[2][2]}");
    pairs.add("${matrix[0][2]}${matrix[1][1]}");
    pairs.add("${matrix[1][1]}${matrix[2][0]}");

    // Centro con esquinas
    final center = matrix[1][1];
    pairs.add("$center${matrix[0][1]}"); // Centro - Norte
    pairs.add("$center${matrix[2][1]}"); // Centro - Sur
    pairs.add("$center${matrix[1][0]}"); // Centro - Oeste
    pairs.add("$center${matrix[1][2]}"); // Centro - Este

    return pairs.toList();
  }

  /// Tabla de Equivalencias (+25, -25, Espejo e Inverso)
  static Map<String, String> calculateEquivalencies(int number) {
    final nClamped = number.clamp(0, 99);
    final p25 = (nClamped + 25) % 100;
    final m25 = (nClamped - 25 + 100) % 100;

    // Regla del Espejo tradicional de la Bolita: sumar 5 a cada dígito módulo 10
    final d = (nClamped ~/ 10 + 5) % 10;
    final u = (nClamped % 10 + 5) % 10;
    final espejo = d * 10 + u;

    // Regla del Inverso (virado)
    final inverso = (nClamped % 10) * 10 + (nClamped ~/ 10);

    return {
      'plus25': p25.toString().padLeft(2, '0'),
      'minus25': m25.toString().padLeft(2, '0'),
      'espejo': espejo.toString().padLeft(2, '0'),
      'inverso': inverso.toString().padLeft(2, '0'),
    };
  }

  /// Generador de Parlés C(n, 2)
  static List<String> generateParles(List<String> numbers) {
    final clean = numbers.map((n) => n.trim().padLeft(2, '0')).toSet().toList();
    clean.sort();
    final parles = <String>[];
    for (int i = 0; i < clean.length; i++) {
      for (int j = i + 1; j < clean.length; j++) {
        parles.add("${clean[i]} - ${clean[j]}");
      }
    }
    return parles;
  }

  /// Generador de Candados (terna de 3 números con todas sus combinaciones de pares cerradas)
  static List<String> generateCandados(List<String> numbers) {
    return generateParles(numbers);
  }
}
