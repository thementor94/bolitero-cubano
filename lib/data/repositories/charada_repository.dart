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

  Future<List<CharadaModel>> search(String query) async {
    final q = query.trim().toLowerCase();
    if (q.isEmpty) return getAllEntries();

    final db = await DatabaseHelper.database;
    // Búsqueda por número directo o por coincidencia difusa en nombres/sinónimos
    final asInt = int.tryParse(q);
    if (asInt != null && asInt >= 1 && asInt <= 100) {
      final direct = await getByNumber(asInt);
      if (direct != null) return [direct];
    }

    final maps = await db.query(
      'charada_entries',
      where: 'LOWER(primary_name) LIKE ? OR LOWER(synonyms) LIKE ?',
      whereArgs: ['%$q%', '%$q%'],
      orderBy: 'number ASC',
    );
    return maps.map(CharadaModel.fromMap).toList();
  }
}
