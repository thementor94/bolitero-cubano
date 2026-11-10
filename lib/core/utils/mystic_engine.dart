class OrishaInfo {
  final String name;
  final String domain;
  final String syncretism;
  final List<int> sacredNumbers;
  final String description;

  const OrishaInfo({
    required this.name,
    required this.domain,
    required this.syncretism,
    required this.sacredNumbers,
    required this.description,
  });
}

class MysticEngine {
  /// Diccionario canónico de los 8 Orishas principales del panteón yoruba
  static const Map<String, OrishaInfo> orishas = {
    'Eleguá': OrishaInfo(
      name: 'Eleguá',
      domain: 'Caminos, crucijadas y destino',
      syncretism: 'San Antonio de Padua / Niño de Atocha',
      sacredNumbers: [3, 21, 54, 73],
      description: 'Dueño de todas las llaves, abre las puertas de la prosperidad y la suerte.',
    ),
    'Ogún': OrishaInfo(
      name: 'Ogún',
      domain: 'Hierro, metales, trabajo y fuerza',
      syncretism: 'San Pedro / San Pablo',
      sacredNumbers: [4, 24, 40, 84],
      description: 'Patrón de los herreros y cirujanos; corta obstáculos con su machete.',
    ),
    'Ochosi': OrishaInfo(
      name: 'Ochosi',
      domain: 'Justicia, caza y puntería mental',
      syncretism: 'San Norberto',
      sacredNumbers: [7, 28, 39, 77],
      description: 'El gran cazador cuya flecha no erra el blanco.',
    ),
    'Changó': OrishaInfo(
      name: 'Changó',
      domain: 'Trueno, fuego, tambor y liderazgo',
      syncretism: 'Santa Bárbara',
      sacredNumbers: [6, 36, 42, 88],
      description: 'Rey de reyes, pasión arrolladora y victoria en pleitos.',
    ),
    'Yemayá': OrishaInfo(
      name: 'Yemayá',
      domain: 'Mares, maternidad y vida',
      syncretism: 'Virgen de Regla',
      sacredNumbers: [7, 14, 49, 70],
      description: 'Madre nutricia del mundo, abundancia infinita de las olas.',
    ),
    'Ochún': OrishaInfo(
      name: 'Ochún',
      domain: 'Ríos, oro, miel, amor y dulzura',
      syncretism: 'Virgen de la Caridad del Cobre',
      sacredNumbers: [5, 15, 25, 55],
      description: 'Dueña del oro y la felicidad, bendición de riqueza material y afectiva.',
    ),
    'Oyá': OrishaInfo(
      name: 'Oyá',
      domain: 'Vientos, centellas y camposantos',
      syncretism: 'Virgen de la Candelaria',
      sacredNumbers: [9, 19, 45, 90],
      description: 'Guerrera del viento y los cambios súbitos y transformadores.',
    ),
    'Obatalá': OrishaInfo(
      name: 'Obatalá',
      domain: 'Pureza, mente, paz y sabiduría',
      syncretism: 'Virgen de las Mercedes',
      sacredNumbers: [8, 16, 24, 64, 80],
      description: 'Creador supremo, calma los pensamientos y aclara los caminos.',
    ),
  };

  /// Encuentra el orisha protector asociado a un número fijo (00–99)
  static OrishaInfo getResonatingOrisha(int number) {
    for (final orisha in orishas.values) {
      if (orisha.sacredNumbers.contains(number)) {
        return orisha;
      }
    }
    // Mapeo por reducción numerológica modular
    final root = (number % 8);
    final keys = orishas.keys.toList();
    return orishas[keys[root]]!;
  }

  /// Lista de signos zodiacales
  static const List<String> zodiacSigns = [
    'Aries', 'Tauro', 'Géminis', 'Cáncer',
    'Leo', 'Virgo', 'Libra', 'Escorpio',
    'Sagitario', 'Capricornio', 'Acuario', 'Piscis'
  ];

  /// Generador determinista de horóscopo diario sin dependencias de red.
  /// Genera 3 números únicos de la suerte en rango '00'..'99' a partir de (signo + fecha).
  static Map<String, dynamic> generateDailyHoroscope({
    required String sign,
    required DateTime date,
  }) {
    final dateStr = "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
    final seedString = "${sign.toLowerCase()}-$dateStr";

    // Hash FNV-1a determinista de 64 bits simulado
    int hash = 0x811c9dc5;
    for (final codeUnit in seedString.codeUnits) {
      hash ^= codeUnit;
      hash = (hash * 0x01000193) & 0x7FFFFFFF;
    }

    // Generador de congruencia lineal
    int nextRandom() {
      hash = (hash * 1103515245 + 12345) & 0x7FFFFFFF;
      return hash;
    }

    final luckyNumbers = <String>{};
    int attempts = 0;
    while (luckyNumbers.length < 3 && attempts < 20) {
      attempts++;
      final val = nextRandom() % 100;
      luckyNumbers.add(val.toString().padLeft(2, '0'));
    }

    final messages = [
      "Las vibraciones del día señalan movimientos audaces en tus jugadas.",
      "La constancia y la intuición revelan combinaciones ganadoras.",
      "Cuidado con distracciones; el primer número que vino a tu mente es la clave.",
      "El flujo de energía astral favorece los números acompañantes hoy.",
      "Momento propicio para candados y combinaciones cerradas.",
      "La serenidad abre el camino a la buena fortuna.",
    ];
    final msgIndex = nextRandom() % messages.length;

    return {
      'sign': sign,
      'date': dateStr,
      'luckyNumbers': luckyNumbers.toList(),
      'advice': messages[msgIndex],
    };
  }
}
