import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/offline_banner.dart';
import '../../../../data/models/lab_play_model.dart';
import '../../../../data/repositories/lab_repository.dart';

class LabScreen extends StatefulWidget {
  const LabScreen({super.key});

  @override
  State<LabScreen> createState() => _LabScreenState();
}

class _LabScreenState extends State<LabScreen> {
  final _labRepo = LabRepository();
  List<LabPlayModel> _plays = [];
  Map<String, dynamic> _stats = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final list = await _labRepo.getPlays();
    final st = await _labRepo.getStats();
    setState(() {
      _plays = list;
      _stats = st;
      _isLoading = false;
    });
  }

  void _showNewPlayDialog() {
    String playType = 'fijo';
    String numbers = '';
    String period = 'evening';

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: AppColors.sheet,
              title: const Text("Nueva Jugada de Práctica", style: TextStyle(color: AppColors.gold, fontSize: 16)),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DropdownButton<String>(
                    value: playType,
                    dropdownColor: AppColors.sheet,
                    style: const TextStyle(color: AppColors.text),
                    isExpanded: true,
                    items: const [
                      DropdownMenuItem(value: 'fijo', child: Text("Fijo (70x)")),
                      DropdownMenuItem(value: 'corrido', child: Text("Corrido (20x)")),
                      DropdownMenuItem(value: 'centena', child: Text("Centena (300x)")),
                      DropdownMenuItem(value: 'parle', child: Text("Parlé (900x / 100x)")),
                    ],
                    onChanged: (v) => setDialogState(() => playType = v!),
                  ),
                  const SizedBox(height: 8),
                  DropdownButton<String>(
                    value: period,
                    dropdownColor: AppColors.sheet,
                    style: const TextStyle(color: AppColors.text),
                    isExpanded: true,
                    items: const [
                      DropdownMenuItem(value: 'evening', child: Text("Florida Noche (9:45 PM)")),
                      DropdownMenuItem(value: 'midday', child: Text("Florida Tarde (1:30 PM)")),
                    ],
                    onChanged: (v) => setDialogState(() => period = v!),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    style: const TextStyle(color: AppColors.text, fontFamily: 'JetBrainsMono'),
                    decoration: const InputDecoration(
                      hintText: "Número(s) ej: 15 o 15-21",
                      hintStyle: TextStyle(color: AppColors.textMuted, fontSize: 13),
                    ),
                    onChanged: (v) => numbers = v,
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Cancelar", style: TextStyle(color: AppColors.textMuted)),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.gold),
                  onPressed: () async {
                    if (numbers.trim().isNotEmpty) {
                      await _labRepo.addPlay(
                        drawDate: "2026-11-09",
                        lottery: "florida",
                        period: period,
                        playType: playType,
                        numbers: numbers.trim(),
                      );
                      if (context.mounted) Navigator.pop(context);
                      await _loadData();
                    }
                  },
                  child: const Text("Guardar", style: TextStyle(color: AppColors.canvas, fontWeight: FontWeight.bold)),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.canvas,
      appBar: AppBar(
        backgroundColor: AppColors.canvas,
        elevation: 0,
        title: const Text("Mi Laboratorio", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.gold)),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.gold,
        onPressed: _showNewPlayDialog,
        child: const Icon(Icons.add, color: AppColors.canvas),
      ),
      body: Column(
        children: [
          const OfflineBanner(),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.card,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.border),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Column(
                    children: [
                      Text("${(_stats['winRate'] ?? 0.0).toStringAsFixed(0)}%", style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.turquoise)),
                      const Text("Aciertos", style: TextStyle(fontSize: 11, color: AppColors.textMuted)),
                    ],
                  ),
                  Column(
                    children: [
                      Text("${_stats['points'] ?? 0.0} pts", style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.gold)),
                      const Text("Puntos virtuales", style: TextStyle(fontSize: 11, color: AppColors.textMuted)),
                    ],
                  ),
                  Column(
                    children: [
                      Text("${_stats['total'] ?? 0}", style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.text)),
                      const Text("Jugadas", style: TextStyle(fontSize: 11, color: AppColors.textMuted)),
                    ],
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator(color: AppColors.gold))
                : _plays.isEmpty
                    ? const Center(
                        child: Text(
                          "Aún no tienes jugadas registradas.\nToca '+' para practicar sin dinero real.",
                          textAlign: TextAlign.center,
                          style: TextStyle(color: AppColors.textMuted),
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: _plays.length,
                        itemBuilder: (context, index) {
                          final play = _plays[index];
                          final isWon = play.status == 'won';
                          final isPending = play.status == 'pending';
                          return Container(
                            margin: const EdgeInsets.only(bottom: 8),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: AppColors.card,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: AppColors.border),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "${play.playType.toUpperCase()}: ${play.numbers}",
                                      style: const TextStyle(fontFamily: 'JetBrainsMono', fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.text),
                                    ),
                                    Text("${play.lottery.toUpperCase()} · ${play.period.toUpperCase()} · ${play.drawDate}", style: const TextStyle(fontSize: 10, color: AppColors.textMuted)),
                                  ],
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: isWon ? AppColors.ok.withOpacity(0.2) : isPending ? AppColors.gold.withOpacity(0.2) : AppColors.cold.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(999),
                                  ),
                                  child: Text(
                                    isWon ? "Ganada +${play.totalPayout.toInt()}" : isPending ? "Pendiente" : "No premiada",
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                      color: isWon ? AppColors.ok : isPending ? AppColors.gold : AppColors.cold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}
