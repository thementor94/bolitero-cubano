import '../../core/database/database_helper.dart';
import '../models/charada_model.dart';

class CharadaRepository {
  Future<List<CharadaModel>> getAllEntries() async {
    final db = await DatabaseHelper.database;
    final maps = await db.query('charada_entries', orderBy: 'number ASC');
    return maps.map(CharadaModel.fromMap).toList();
  }

  Future<CharadaModel?> getByNumber(int number) async {
    final db = await DatabaseHelper.database;
    final maps = await db.query(
      'charada_entries',
      where: 'number = ?',
      whereArgs: [number],
      limit: 1,
    );
    if (maps.isEmpty) return null;
    return CharadaModel.fromMap(maps.first);
  }

  Future<List<CharadaModel>> search(String query, {String? category}) async {
    final q = query.trim().toLowerCase();
    final db = await DatabaseHelper.database;

    String where = '';
    List<dynamic> whereArgs = [];

    final asInt = int.tryParse(q);
    if (asInt != null && asInt >= 1 && asInt <= 100) {
      final direct = await getByNumber(asInt);
      if (direct != null) return [direct];
    }

    if (q.isNotEmpty) {
      where = '(LOWER(primary_name) LIKE ? OR LOWER(synonyms) LIKE ? OR LOWER(COALESCE(deity, "")) LIKE ?)';
      whereArgs.addAll(['%$q%', '%$q%', '%$q%']);
    }

    if (category != null && category.toLowerCase() != 'todos') {
      if (where.isNotEmpty) where += ' AND ';
      where += 'category = ?';
      whereArgs.add(category.toLowerCase());
    }

    final maps = await db.query(
      'charada_entries',
      where: where.isEmpty ? null : where,
      whereArgs: whereArgs.isEmpty ? null : whereArgs,
      orderBy: 'number ASC',
    );
    return maps.map(CharadaModel.fromMap).toList();
  }
}
