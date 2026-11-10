import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:sqflite/sqflite.dart';
import '../../core/constants/api_constants.dart';
import '../../core/database/database_helper.dart';
import '../../core/utils/lab_settlement_engine.dart';
import '../models/draw_model.dart';

class DrawRepository {
  Future<List<DrawModel>> getRecentDraws({int limit = 30}) async {
    final db = await DatabaseHelper.database;
    final maps = await db.query(
      'local_draws',
      orderBy: 'draw_date DESC, draw_time DESC',
      limit: limit,
    );
    return maps.map(DrawModel.fromMap).toList();
  }

  Future<DrawModel?> getLatestDraw({String lottery = 'florida', String? period}) async {
    final db = await DatabaseHelper.database;
    String where = 'lottery = ?';
    List<dynamic> whereArgs = [lottery];

    if (period != null) {
      where += ' AND period = ?';
      whereArgs.add(period);
    }

    final maps = await db.query(
      'local_draws',
      where: where,
      whereArgs: whereArgs,
      orderBy: 'draw_date DESC, draw_time DESC',
      limit: 1,
    );

    if (maps.isEmpty) return null;
    return DrawModel.fromMap(maps.first);
  }

  /// Sincronización delta ultra-ligera desde CDN (< 1 KB)
  Future<bool> syncFromCdn() async {
    try {
      final response = await http
          .get(Uri.parse(ApiConstants.latestCdnUrl))
          .timeout(ApiConstants.networkTimeout);

      if (response.statusCode == 200) {
        final data = json.decode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
        final draws = (data['draws'] as List<dynamic>?) ?? [];
        if (draws.isEmpty) return false;

        final db = await DatabaseHelper.database;
        await db.transaction((txn) async {
          for (final raw in draws) {
            final drawMap = raw as Map<String, dynamic>;
            final draw = DrawModel.fromMap(drawMap);

            await txn.insert(
              'local_draws',
              draw.toMap(),
              conflictAlgorithm: ConflictAlgorithm.replace,
            );

            // Transacción atómica de liquidación automática de jugadas pendientes
            final pendingPlays = await txn.query(
              'lab_plays',
              where: 'draw_date = ? AND lottery = ? AND period = ? AND status = "pending"',
              whereArgs: [draw.drawDate, draw.lottery, draw.period],
            );

            for (final play in pendingPlays) {
              final result = LabSettlementEngine.evaluatePlay(
                playType: play['play_type'] as String,
                betNumbers: play['numbers'] as String,
                virtualPoints: (play['virtual_points'] as num).toDouble(),
                drawFijo: draw.fijo,
                drawCentena: draw.centena,
                drawCorrido1: draw.corrido1,
                drawCorrido2: draw.corrido2,
              );

              await txn.update(
                'lab_plays',
                {
                  'status': result['status'],
                  'payout_multiplier': result['payoutMultiplier'],
                  'total_payout': result['totalPayout'],
                  'settled_at': result['settledAt'],
                },
                where: 'id = ?',
                whereArgs: [play['id']],
              );
            }
          }
        });
        return true;
      }
      return false;
    } catch (_) {
      // Sin conexión: SQLite continúa operando transparentemente
      return false;
    }
  }
}
