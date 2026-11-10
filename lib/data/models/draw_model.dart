class DrawModel {
  final String id;
  final String lottery;
  final String period;
  final String drawDate;
  final String? drawTime;
  final String pick3Raw;
  final String? pick4Raw;
  final String fijo;
  final String centena;
  final String? corrido1;
  final String? corrido2;
  final String status;
  final int createdAt;

  const DrawModel({
    required this.id,
    required this.lottery,
    required this.period,
    required this.drawDate,
    this.drawTime,
    required this.pick3Raw,
    this.pick4Raw,
    required this.fijo,
    required this.centena,
    this.corrido1,
    this.corrido2,
    this.status = 'official',
    required this.createdAt,
  });

  factory DrawModel.fromMap(Map<String, dynamic> map) {
    return DrawModel(
      id: map['id'] as String,
      lottery: map['lottery'] as String,
      period: map['period'] as String,
      drawDate: map['draw_date'] as String,
      drawTime: map['draw_time'] as String?,
      pick3Raw: map['pick3_raw'] as String,
      pick4Raw: map['pick4_raw'] as String?,
      fijo: map['fijo'] as String,
      centena: map['centena'] as String,
      corrido1: map['corrido1'] as String?,
      corrido2: map['corrido2'] as String?,
      status: (map['status'] as String?) ?? 'official',
      createdAt: (map['created_at'] as int?) ?? DateTime.now().millisecondsSinceEpoch,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'lottery': lottery,
      'period': period,
      'draw_date': drawDate,
      'draw_time': drawTime,
      'pick3_raw': pick3Raw,
      'pick4_raw': pick4Raw,
      'fijo': fijo,
      'centena': centena,
      'corrido1': corrido1,
      'corrido2': corrido2,
      'status': status,
      'created_at': createdAt,
    };
  }
}
