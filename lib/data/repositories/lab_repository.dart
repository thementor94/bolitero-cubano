import 'package:uuid/uuid.dart';
import '../../core/database/database_helper.dart';
import '../../core/utils/lab_settlement_engine.dart';
import '../models/draw_model.dart';
import '../models/lab_play_model.dart';

class LabRepository {
  final _uuid = const Uuid();

  Future<List<LabPlayModel>> getPlays({String? filter}) async {
    final db = await DatabaseHelper.database;
    String? where;
    List<dynamic>? whereArgs;

    if (filter != null && filter.toLowerCase() != 'todas') {
      where = 'status = ?';
      whereArgs = [filter.toLowerCase()];
    }

    final maps = await db.query(
      'lab_plays',
      where: where,
      whereArgs: whereArgs,
      orderBy: 'created_at DESC',
    );
    return maps.map(LabPlayModel.fromMap).toList();
  }

  Future<void> addPlay({
    required String drawDate,
    required String lottery,
    required String period,
    required String playType,
    required String numbers,
    double virtualPoints = 10.0,
  }) async {
    final db = await DatabaseHelper.database;
    final play = LabPlayModel(
      id: _uuid.v4(),
      drawDate: drawDate,
      lottery: lottery,
      period: period,
      playType: playType,
      numbers: numbers,
      virtualPoints: virtualPoints,
      createdAt: DateTime.now().millisecondsSinceEpoch,
    );

    await db.insert('lab_plays', {
      'id': play.id,
      'draw_date': play.drawDate,
      'lottery': play.lottery,
      'period': play.period,
      'play_type': play.playType,
      'numbers': play.numbers,
      'virtual_points': play.virtualPoints,
      'status': play.status,
      'payout_multiplier': play.payoutMultiplier,
      'total_payout': play.totalPayout,
      'created_at': play.createdAt,
    });
  }

  /// Liquida todas las jugadas pendientes contra los tiros existentes en local_draws
  Future<int> settlePendingPlays() async {
    final db = await DatabaseHelper.database;
    final pendingPlays = await db.query(
      'lab_plays',
      where: 'status = ?',
      whereArgs: ['pending'],
    );

    if (pendingPlays.isEmpty) return 0;
    int settledCount = 0;

    for (final play in pendingPlays) {
      final draws = await db.query(
        'local_draws',
        where: 'draw_date = ? AND lottery = ? AND period = ?',
        whereArgs: [play['draw_date'], play['lottery'], play['period']],
        limit: 1,
      );

      if (draws.isNotEmpty) {
        final draw = DrawModel.fromMap(draws.first);
        final result = LabSettlementEngine.evaluatePlay(
          playType: play['play_type'] as String,
          betNumbers: play['numbers'] as String,
          virtualPoints: (play['virtual_points'] as num).toDouble(),
          drawFijo: draw.fijo,
          drawCentena: draw.centena,
          drawCorrido1: draw.corrido1,
          drawCorrido2: draw.corrido2,
        );

        await db.update(
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
        settledCount++;
      }
    }
    return settledCount;
  }

  Future<Map<String, dynamic>> getStats() async {
    final db = await DatabaseHelper.database;
    final plays = await db.query('lab_plays');
    if (plays.isEmpty) {
      return {
        'total': 0,
        'won': 0,
        'lost': 0,
        'pending': 0,
        'winRate': 0.0,
        'netPoints': 0.0,
        'totalWagered': 0.0,
      };
    }

    int total = plays.length;
    int won = 0;
    int lost = 0;
    int pending = 0;
    double netPoints = 0.0;
    double totalWagered = 0.0;

    for (final p in plays) {
      final status = p['status'] as String;
      final stake = (p['virtual_points'] as num).toDouble();
      totalWagered += stake;

      if (status == 'won') {
        won++;
        final payout = (p['total_payout'] as num).toDouble();
        netPoints += (payout - stake);
      } else if (status == 'lost') {
        lost++;
        netPoints -= stake;
      } else {
        pending++;
      }
    }

    return {
      'total': total,
      'won': won,
      'lost': lost,
      'pending': pending,
      'winRate': total > 0 ? (won / (won + lost == 0 ? 1 : (won + lost))) * 100 : 0.0,
      'netPoints': netPoints,
      'totalWagered': totalWagered,
    };
  }
}
