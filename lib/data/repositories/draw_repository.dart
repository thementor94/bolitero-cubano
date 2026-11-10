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

  Future<List<DrawModel>> getDrawsByDate(String dateYMD, {String? lottery}) async {
    final db = await DatabaseHelper.database;
    String where = 'draw_date = ?';
    List<dynamic> whereArgs = [dateYMD];

    if (lottery != null && lottery.toLowerCase() != 'todos') {
      where += ' AND lottery = ?';
      whereArgs.add(lottery.toLowerCase());
    }

    final maps = await db.query(
      'local_draws',
      where: where,
      whereArgs: whereArgs,
      orderBy: 'draw_time DESC',
    );
    return maps.map(DrawModel.fromMap).toList();
  }

  /// Consulta analítica de Números Calientes (Mayor frecuencia en N días)
  Future<List<Map<String, dynamic>>> getHotNumbers({
    required String lottery,
    int days = 30,
    int limit = 10,
  }) async {
    final db = await DatabaseHelper.database;
    final cutoffDate = DateTime.now().subtract(Duration(days: days)).toIso8601String().substring(0, 10);
    
    String where = 'draw_date >= ?';
    List<dynamic> args = [cutoffDate];

    if (lottery.toLowerCase() != 'todos') {
      where += ' AND lottery = ?';
      args.add(lottery.toLowerCase());
    }

    final result = await db.rawQuery('''
      SELECT fijo, COUNT(*) as freq, MAX(draw_date) as last_date
      FROM local_draws
      WHERE $where
      GROUP BY fijo
      ORDER BY freq DESC, last_date DESC
      LIMIT ?
    ''', [...args, limit]);

    return result;
  }

  /// Consulta analítica de Números Atrasados (Mayor cantidad de tiros sin salir en la fija)
  Future<List<Map<String, dynamic>>> getDelayedNumbers({
    required String lottery,
    int limit = 10,
  }) async {
    final db = await DatabaseHelper.database;
    
    // Obtener todos los tiros ordenados cronológicamente inverso para la lotería
    String where = lottery.toLowerCase() != 'todos' ? 'lottery = ?' : '1=1';
    List<dynamic> args = lottery.toLowerCase() != 'todos' ? [lottery.toLowerCase()] : [];

    final draws = await db.query(
      'local_draws',
      columns: ['fijo', 'draw_date', 'draw_time'],
      where: where,
      whereArgs: args,
      orderBy: 'draw_date DESC, draw_time DESC',
    );

    // Calcular distancia en tiros desde la última aparición de cada número del 00 al 99
    final lastSeenIndex = <String, int>{};
    final lastSeenDate = <String, String>{};

    for (int i = 0; i < draws.length; i++) {
      final fijo = draws[i]['fijo'] as String;
      if (!lastSeenIndex.containsKey(fijo)) {
        lastSeenIndex[fijo] = i;
        lastSeenDate[fijo] = draws[i]['draw_date'] as String;
      }
    }

    // Para números que nunca han salido en la ventana analizada, atraso = draws.length
    final delayedList = <Map<String, dynamic>>[];
    for (int n = 0; n <= 99; n++) {
      final numStr = n.toString().padLeft(2, '0');
      final delay = lastSeenIndex[numStr] ?? (draws.length + 1);
      final lastDate = lastSeenDate[numStr] ?? 'Nunca';
      delayedList.add({
        'fijo': numStr,
        'delay': delay,
        'last_date': lastDate,
      });
    }

    delayedList.sort((a, b) => (b['delay'] as int).compareTo(a['delay'] as int));
    return delayedList.take(limit).toList();
  }

  /// Genera matriz de frecuencia para el Cartón Heatmap 10x10 en un mes dado
  Future<Map<String, int>> getMonthlyHeatmap({
    required String lottery,
    required int year,
    required int month,
  }) async {
    final db = await DatabaseHelper.database;
    final monthStr = month.toString().padLeft(2, '0');
    final start = '$year-$monthStr-01';
    final end = '$year-$monthStr-31';

    String where = 'draw_date BETWEEN ? AND ?';
    List<dynamic> args = [start, end];

    if (lottery.toLowerCase() != 'todos') {
      where += ' AND lottery = ?';
      args.add(lottery.toLowerCase());
    }

    final rows = await db.rawQuery('''
      SELECT fijo, COUNT(*) as count
      FROM local_draws
      WHERE $where
      GROUP BY fijo
    ''', args);

    final heatmap = <String, int>{};
    for (int i = 0; i <= 99; i++) {
      heatmap[i.toString().padLeft(2, '0')] = 0;
    }
    for (final r in rows) {
      final fijo = r['fijo'] as String;
      final count = (r['count'] as num).toInt();
      heatmap[fijo] = count;
    }
    return heatmap;
  }

  /// Historial específico de un número (fijo y corridos)
  Future<List<Map<String, dynamic>>> getNumberHistory(String number, {int limit = 50}) async {
    final db = await DatabaseHelper.database;
    final padNum = number.padLeft(2, '0');
    final rows = await db.query(
      'local_draws',
      where: 'fijo = ? OR corrido1 = ? OR corrido2 = ?',
      whereArgs: [padNum, padNum, padNum],
      orderBy: 'draw_date DESC, draw_time DESC',
      limit: limit,
    );
    return rows;
  }

  /// Sincronización bifásica con detección de brecha (Gap Detection)
  Future<bool> syncFromCdn() async {
    try {
      final db = await DatabaseHelper.database;
      
      // 1. Consultar fecha máxima local
      final maxDateRow = await db.rawQuery('SELECT MAX(draw_date) as max_date FROM local_draws');
      final localMaxDateStr = maxDateRow.isNotEmpty ? maxDateRow.first['max_date'] as String? : null;

      // 2. Descargar latest.json
      final response = await http
          .get(Uri.parse(ApiConstants.latestCdnUrl))
          .timeout(ApiConstants.networkTimeout);

      if (response.statusCode != 200) return false;

      final data = json.decode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
      final latestDraws = (data['draws'] as List<dynamic>?) ?? [];
      if (latestDraws.isEmpty) return false;

      // 3. Gap Detection: Si localMaxDate tiene más de 2 días de desfase respecto al sorteo más antiguo en latest.json, descargar history.json
      if (localMaxDateStr != null && latestDraws.isNotEmpty) {
        final oldestInLatest = latestDraws.last['draw_date'] as String?;
        if (oldestInLatest != null) {
          final localMax = DateTime.tryParse(localMaxDateStr);
          final oldestLatest = DateTime.tryParse(oldestInLatest);
          if (localMax != null && oldestLatest != null && oldestLatest.difference(localMax).inDays > 2) {
            // Se detectó brecha: Descargar histórico completo de respaldo
            try {
              final hResp = await http
                  .get(Uri.parse(ApiConstants.historyCdnUrl))
                  .timeout(ApiConstants.networkTimeout);
              if (hResp.statusCode == 200) {
                final hData = json.decode(utf8.decode(hResp.bodyBytes)) as Map<String, dynamic>;
                final hDraws = (hData['draws'] as List<dynamic>?) ?? [];
                await _insertDrawsAndSettle(db, hDraws);
                return true;
              }
            } catch (_) {
              // Si history.json falla, continuamos procesando latestDraws
            }
          }
        }
      }

      await _insertDrawsAndSettle(db, latestDraws);
      return true;
    } catch (_) {
      // Sin conexión: SQLite continúa operando transparentemente
      return false;
    }
  }

  Future<void> _insertDrawsAndSettle(Database db, List<dynamic> rawDraws) async {
    await db.transaction((txn) async {
      for (final raw in rawDraws) {
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
  }
}
