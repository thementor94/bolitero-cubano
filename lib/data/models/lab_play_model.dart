class LabPlayModel {
  final String id;
  final String drawDate;
  final String lottery;
  final String period;
  final String playType;
  final String numbers;
  final double virtualPoints;
  final String status;
  final double payoutMultiplier;
  final double totalPayout;
  final int createdAt;
  final int? settledAt;

  const LabPlayModel({
    required this.id,
    required this.drawDate,
    required this.lottery,
    required this.period,
    required this.playType,
    required this.numbers,
    this.virtualPoints = 10.0,
    this.status = 'pending',
    this.payoutMultiplier = 0.0,
    this.totalPayout = 0.0,
    required this.createdAt,
    this.settledAt,
  });

  factory LabPlayModel.fromMap(Map<String, dynamic> map) {
    return LabPlayModel(
      id: map['id'] as String,
      drawDate: map['draw_date'] as String,
      lottery: map['lottery'] as String,
      period: map['period'] as String,
      playType: map['play_type'] as String,
      numbers: map['numbers'] as String,
      virtualPoints: (map['virtual_points'] as num?)?.toDouble() ?? 10.0,
      status: (map['status'] as String?) ?? 'pending',
      payoutMultiplier: (map['payout_multiplier'] as num?)?.toDouble() ?? 0.0,
      totalPayout: (map['total_payout'] as num?)?.toDouble() ?? 0.0,
      createdAt: map['created_at'] as int,
      settledAt: map['settled_at'] as int?,
    );
  }
}
