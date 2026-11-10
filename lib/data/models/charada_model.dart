class CharadaModel {
  final int number;
  final String primaryName;
  final String category;
  final List<String> synonyms;
  final String? deity;
  final String? accompanying;
  final String? description;

  const CharadaModel({
    required this.number,
    required this.primaryName,
    this.category = 'clasica',
    required this.synonyms,
    this.deity,
    this.accompanying,
    this.description,
  });

  factory CharadaModel.fromMap(Map<String, dynamic> map) {
    final rawSynonyms = map['synonyms'] as String? ?? '';
    final synList = rawSynonyms.split(',').map((s) => s.trim()).where((s) => s.isNotEmpty).toList();
    return CharadaModel(
      number: map['number'] as int,
      primaryName: map['primary_name'] as String,
      category: (map['category'] as String?) ?? 'clasica',
      synonyms: synList,
      deity: map['deity'] as String?,
      accompanying: map['accompanying'] as String?,
      description: map['description'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'number': number,
      'primary_name': primaryName,
      'category': category,
      'synonyms': synonyms.join(', '),
      'deity': deity,
      'accompanying': accompanying,
      'description': description,
    };
  }
}
