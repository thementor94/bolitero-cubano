class CharadaModel {
  final int number;
  final String primaryName;
  final String category;
  final List<String> synonyms;
  final String? description;

  const CharadaModel({
    required this.number,
    required this.primaryName,
    this.category = 'clasica',
    required this.synonyms,
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
      description: map['description'] as String?,
    );
  }
}
