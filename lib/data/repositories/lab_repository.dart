import 'package:uuid/uuid.dart';
import '../../core/database/database_helper.dart';
import '../models/lab_play_model.dart';

class LabRepository {
  final _uuid = const Uuid();

  Future<List<LabPlayModel>> getPlays({String? filter}) async {
    final db = await DatabaseHelper.database;
    String? where;
    List<dynamic>? whereArgs;

    if (filter != null && filter != 'todas') {
      where = 'status = ?';
      whereArgs = [filter];
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

  Future<Map<String, dynamic>> getStats() async {
    final db = await DatabaseHelper.database;
    final plays = await db.query('lab_plays');
    if (plays.isEmpty) {
      return {'total': 0, 'won': 0, 'winRate': 0.0, 'points': 0.0};
    }

    int total = plays.length;
    int won = 0;
    double points = 0.0;

    for (final p in plays) {
      final status = p['status'] as String;
      final stake = (p['virtual_points'] as num).toDouble();
      if (status == 'won') {
        won++;
        final payout = (p['total_payout'] as num).toDouble();
        points += (payout - stake);
      } else if (status == 'lost') {
        points -= stake;
      }
    }

    return {
      'total': total,
      'won': won,
      'winRate': (won / total) * 100,
      'points': points,
    };
  }
}
