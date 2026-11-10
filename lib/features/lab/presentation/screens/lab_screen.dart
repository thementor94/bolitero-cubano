import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/offline_banner.dart';
import '../../../../data/models/lab_play_model.dart';
import '../../../../data/repositories/lab_repository.dart';
import 'ticket_detail_screen.dart';

class LabScreen extends StatefulWidget {
  const LabScreen({super.key});

  @override
  State<LabScreen> createState() => _LabScreenState();
}

class _LabScreenState extends State<LabScreen> {
  final _labRepo = LabRepository();
  List<LabPlayModel> _plays = [];
  Map<String, dynamic> _stats = {};
  String _selectedFilter = 'todas';
  bool _isLoading = true;

  final List<String> _filters = ['todas', 'pending', 'won', 'lost'];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final list = await _labRepo.getPlays(filter: _selectedFilter);
    final st = await _labRepo.getStats();
    if (mounted) {
      setState(() {
        _plays = list;
        _stats = st;
        _isLoading = false;
      });
    }
  }

  Future<void> _settlePlays() async {
    final settled = await _labRepo.settlePendingPlays();
    await _loadData();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(settled > 0 ? "¡$settled jugadas liquidadas contra sorteos oficiales!" : "No hay jugadas pendientes con sorteo disponible."),
          backgroundColor: AppColors.cardElevated,
        ),
      );
    }
  }

  void _showNewPlayDialog() {
    String playType = 'fijo';
    String numbers = '';
    String period = 'evening';
    String lottery = 'florida';
    double points = 10.0;
    String dateStr = '2026-11-09';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.sheet,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom + 20,
                left: 20,
                right: 20,
                top: 20,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text("Registrar Jugada Virtual", style: TextStyle(color: AppColors.gold, fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 14),

                  // Modalidad
                  DropdownButtonFormField<String>(
                    value: playType,
                    dropdownColor: AppColors.card,
                    decoration: InputDecoration(
                      labelText: "Modalidad de Apuesta",
                      filled: true,
                      fillColor: AppColors.card,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    items: const [
                      DropdownMenuItem(value: 'fijo', child: Text("Fijo (Paga 70x)")),
                      DropdownMenuItem(value: 'corrido', child: Text("Corrido (Paga 20x)")),
                      DropdownMenuItem(value: 'centena', child: Text("Centena (Paga 300x)")),
                      DropdownMenuItem(value: 'parle', child: Text("Parlé (Paga 900x / 100x)")),
                    ],
                    onChanged: (v) => setSheetState(() => playType = v!),
                  ),
                  const SizedBox(height: 10),

                  // Sorteo
                  Row(
                    children: [
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          value: lottery,
                          dropdownColor: AppColors.card,
                          decoration: InputDecoration(
                            labelText: "Lotería",
                            filled: true,
                            fillColor: AppColors.card,
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                          items: const [
                            DropdownMenuItem(value: 'florida', child: Text("Florida")),
                            DropdownMenuItem(value: 'georgia', child: Text("Georgia")),
                            DropdownMenuItem(value: 'new_york', child: Text("New York")),
                          ],
                          onChanged: (v) => setSheetState(() => lottery = v!),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          value: period,
                          dropdownColor: AppColors.card,
                          decoration: InputDecoration(
                            labelText: "Horario",
                            filled: true,
                            fillColor: AppColors.card,
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                          items: const [
                            DropdownMenuItem(value: 'evening', child: Text("Noche")),
                            DropdownMenuItem(value: 'midday', child: Text("Tarde")),
                          ],
                          onChanged: (v) => setSheetState(() => period = v!),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),

                  // Número
                  TextField(
                    keyboardType: TextInputType.text,
                    style: const TextStyle(fontFamily: 'JetBrainsMono', fontSize: 18, color: AppColors.gold, fontWeight: FontWeight.bold),
                    decoration: InputDecoration(
                      labelText: "Número(s) Jugados",
                      hintText: playType == 'parle' ? "ej: 15-21" : playType == 'centena' ? "ej: 415" : "ej: 15",
                      filled: true,
                      fillColor: AppColors.card,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    onChanged: (v) => numbers = v,
                  ),
                  const SizedBox(height: 16),

                  SizedBox(
                    height: 48,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: AppColors.gold),
                      onPressed: () async {
                        if (numbers.trim().isNotEmpty) {
                          await _labRepo.addPlay(
                            drawDate: dateStr,
                            lottery: lottery,
                            period: period,
                            playType: playType,
                            numbers: numbers.trim(),
                            virtualPoints: points,
                          );
                          if (context.mounted) {
                            Navigator.pop(context);
                            _loadData();
                          }
                        }
                      },
                      child: const Text("Confirmar Jugada", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final netPoints = (_stats['netPoints'] as num?)?.toDouble() ?? 0.0;
    final totalWagered = (_stats['totalWagered'] as num?)?.toDouble() ?? 0.0;
    final winRate = (_stats['winRate'] as num?)?.toDouble() ?? 0.0;
    final balance = 1000.0 + netPoints;

    return Scaffold(
      backgroundColor: AppColors.canvas,
      appBar: AppBar(
        backgroundColor: AppColors.canvas,
        elevation: 0,
        title: const Text("Mi Laboratorio", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.gold)),
        actions: [
          TextButton.icon(
            icon: const Icon(Icons.flash_on, color: AppColors.gold, size: 18),
            label: const Text("Liquidar", style: TextStyle(color: AppColors.gold, fontWeight: FontWeight.bold)),
            onPressed: _settlePlays,
          ),
        ],
      ),
      body: Column(
        children: [
          const OfflineBanner(),

          // Tarjeta de Balance Virtual y Rendimiento
          Container(
            margin: const EdgeInsets.fromLTRB(16, 8, 16, 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.card, AppColors.cardElevated],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.gold.withOpacity(0.3)),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text("Balance Virtual", style: TextStyle(fontSize: 11, color: AppColors.textMuted)),
                        Text(
                          "${balance.toStringAsFixed(1)} pts",
                          style: TextStyle(
                            fontFamily: 'JetBrainsMono',
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: balance >= 1000.0 ? AppColors.gold : Colors.redAccent,
                          ),
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        const Text("Aciertos / Eficiencia", style: TextStyle(fontSize: 11, color: AppColors.textMuted)),
                        Text(
                          "${winRate.toStringAsFixed(1)}%",
                          style: const TextStyle(fontFamily: 'JetBrainsMono', fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.turquoise),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("Apostado: ${totalWagered.toStringAsFixed(1)} pts", style: const TextStyle(fontSize: 11, color: AppColors.textMuted)),
                    Text(
                      netPoints >= 0 ? "+${netPoints.toStringAsFixed(1)} pts ganados" : "${netPoints.toStringAsFixed(1)} pts",
                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: netPoints >= 0 ? AppColors.turquoise : Colors.redAccent),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Chips de filtro de estado
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: _filters.map((f) {
                final isSelected = _selectedFilter == f;
                final label = f == 'todas'
                    ? 'Todas'
                    : f == 'pending'
                        ? 'Pendientes'
                        : f == 'won'
                            ? 'Ganadas'
                            : 'Perdidas';
                return ChoiceChip(
                  label: Text(label),
                  selected: isSelected,
                  onSelected: (val) {
                    if (val) {
                      setState(() => _selectedFilter = f);
                      _loadData();
                    }
                  },
                  selectedColor: AppColors.gold.withOpacity(0.2),
                  backgroundColor: AppColors.card,
                  labelStyle: TextStyle(
                    color: isSelected ? AppColors.gold : AppColors.textMuted,
                    fontSize: 11,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                  side: BorderSide(color: isSelected ? AppColors.gold : AppColors.border),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 8),

          // Lista de Jugadas
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator(color: AppColors.gold))
                : _plays.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.science_outlined, size: 48, color: AppColors.textFaint),
                            const SizedBox(height: 12),
                            const Text("No hay jugadas registradas en este filtro.", style: TextStyle(color: AppColors.textMuted)),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _plays.length,
                        itemBuilder: (context, idx) {
                          final play = _plays[idx];
                          final isWon = play.status == 'won';
                          final isPending = play.status == 'pending';

                          return Card(
                            color: AppColors.card,
                            margin: const EdgeInsets.only(bottom: 10),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                              side: BorderSide(
                                color: isWon ? AppColors.gold.withOpacity(0.5) : AppColors.border,
                              ),
                            ),
                            child: InkWell(
                              borderRadius: BorderRadius.circular(12),
                              onTap: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(builder: (_) => TicketDetailScreen(play: play)),
                                );
                              },
                              child: Padding(
                                padding: const EdgeInsets.all(14),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 48,
                                      height: 48,
                                      decoration: BoxDecoration(
                                        color: isWon ? AppColors.gold.withOpacity(0.2) : AppColors.cardElevated,
                                        borderRadius: BorderRadius.circular(10),
                                        border: Border.all(color: isWon ? AppColors.gold : AppColors.border),
                                      ),
                                      alignment: Alignment.center,
                                      child: Text(
                                        play.numbers,
                                        style: TextStyle(
                                          fontFamily: 'JetBrainsMono',
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: isWon ? AppColors.gold : AppColors.text,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 14),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            "${play.playType.toUpperCase()} · ${play.lottery.toUpperCase()} (${play.period})",
                                            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.text),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            "Fecha: ${play.drawDate}  ·  ${play.virtualPoints.toStringAsFixed(1)} pts",
                                            style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.end,
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                          decoration: BoxDecoration(
                                            color: isWon
                                                ? AppColors.gold.withOpacity(0.2)
                                                : isPending
                                                    ? AppColors.turquoise.withOpacity(0.2)
                                                    : Colors.red.withOpacity(0.15),
                                            borderRadius: BorderRadius.circular(6),
                                          ),
                                          child: Text(
                                            isWon ? "+${play.totalPayout.toStringAsFixed(1)}" : isPending ? "PENDIENTE" : "PERDIDA",
                                            style: TextStyle(
                                              fontSize: 10,
                                              fontWeight: FontWeight.bold,
                                              color: isWon ? AppColors.gold : isPending ? AppColors.turquoise : Colors.redAccent,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.gold,
        onPressed: _showNewPlayDialog,
        child: const Icon(Icons.add, color: Colors.black),
      ),
    );
  }
}
