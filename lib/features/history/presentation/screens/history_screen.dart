import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/bola.dart';
import '../../../../core/widgets/offline_banner.dart';
import '../../../../data/models/draw_model.dart';
import '../../../../data/repositories/charada_repository.dart';
import '../../../../data/repositories/draw_repository.dart';

class HistoryScreen extends StatefulWidget {
  final DateTime? initialDate;

  const HistoryScreen({super.key, this.initialDate});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final _drawRepo = DrawRepository();
  final _charadaRepo = CharadaRepository();

  late DateTime _selectedDate;
  String _selectedLottery = 'Todos';
  List<DrawModel> _dayDraws = [];
  Map<int, String> _charadaNames = {};
  bool _isLoading = true;

  final List<String> _lotteries = ['Todos', 'Florida', 'Georgia', 'New_York'];

  @override
  void initState() {
    super.initState();
    _selectedDate = widget.initialDate ?? DateTime(2026, 11, 9);
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    final dateStr = "${_selectedDate.year}-${_selectedDate.month.toString().padLeft(2, '0')}-${_selectedDate.day.toString().padLeft(2, '0')}";
    final draws = await _drawRepo.getDrawsByDate(
      dateStr,
      lottery: _selectedLottery == 'Todos' ? null : _selectedLottery.toLowerCase(),
    );

    if (_charadaNames.isEmpty) {
      final allCharada = await _charadaRepo.getAllEntries();
      _charadaNames = {for (final c in allCharada) c.number: c.primaryName};
    }

    if (mounted) {
      setState(() {
        _dayDraws = draws;
        _isLoading = false;
      });
    }
  }

  String _formatDateYMD(DateTime d) {
    return "${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.canvas,
      appBar: AppBar(
        backgroundColor: AppColors.canvas,
        elevation: 0,
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Historial de Tiradas", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.gold)),
            Text("Archivo de 180 días verificados", style: TextStyle(fontSize: 11, color: AppColors.textMuted)),
          ],
        ),
      ),
      body: Column(
        children: [
          const OfflineBanner(),

          // Selector horizontal de fechas (carrusel de 30 días)
          Container(
            height: 72,
            padding: const EdgeInsets.symmetric(vertical: 8),
            decoration: const BoxDecoration(
              color: AppColors.card,
              border: Border(bottom: BorderSide(color: AppColors.border)),
            ),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              itemCount: 45,
              itemBuilder: (context, index) {
                final d = DateTime(2026, 11, 9).subtract(Duration(days: index));
                final isSelected = d.year == _selectedDate.year &&
                    d.month == _selectedDate.month &&
                    d.day == _selectedDate.day;

                const weekDays = ['Lun', 'Mar', 'Mié', 'Jue', 'Vie', 'Sáb', 'Dom'];
                final weekDay = weekDays[d.weekday - 1];

                return GestureDetector(
                  onTap: () {
                    setState(() => _selectedDate = d);
                    _loadData();
                  },
                  child: Container(
                    width: 54,
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    decoration: BoxDecoration(
                      color: isSelected ? AppColors.gold.withOpacity(0.2) : Colors.transparent,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected ? AppColors.gold : AppColors.border,
                        width: isSelected ? 1.5 : 1,
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          weekDay,
                          style: TextStyle(
                            fontSize: 10,
                            color: isSelected ? AppColors.gold : AppColors.textMuted,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          d.day.toString().padLeft(2, '0'),
                          style: TextStyle(
                            fontFamily: 'JetBrainsMono',
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: isSelected ? AppColors.gold : AppColors.text,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          // Chips de filtro por Lotería
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 6),
            child: Row(
              children: _lotteries.map((lot) {
                final isSelected = _selectedLottery == lot;
                final label = lot.replaceAll('_', ' ');
                return Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: ChoiceChip(
                    label: Text(label),
                    selected: isSelected,
                    onSelected: (selected) {
                      if (selected) {
                        setState(() => _selectedLottery = lot);
                        _loadData();
                      }
                    },
                    selectedColor: AppColors.turquoise.withOpacity(0.2),
                    backgroundColor: AppColors.card,
                    labelStyle: TextStyle(
                      color: isSelected ? AppColors.turquoise : AppColors.textMuted,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      fontSize: 12,
                    ),
                    side: BorderSide(color: isSelected ? AppColors.turquoise : AppColors.border),
                  ),
                );
              }).toList(),
            ),
          ),

          // Lista de sorteos para la fecha seleccionada
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator(color: AppColors.gold))
                : _dayDraws.isEmpty
                    ? Center(
                        child: Text(
                          "No hay sorteos registrados para el ${_formatDateYMD(_selectedDate)}",
                          style: const TextStyle(color: AppColors.textMuted),
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _dayDraws.length,
                        itemBuilder: (context, index) {
                          final draw = _dayDraws[index];
                          final fijoInt = int.tryParse(draw.fijo) ?? 0;
                          final charadaName = _charadaNames[fijoInt] ?? '—';

                          return Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: AppColors.card,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: AppColors.border),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      "${draw.lottery.toUpperCase()} · ${draw.period.toUpperCase()}",
                                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.text),
                                    ),
                                    Text(
                                      draw.drawTime ?? '',
                                      style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            BolaFijo(numero: draw.fijo, size: 44),
                                            const SizedBox(width: 12),
                                            Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  "Fijo: ${draw.fijo}",
                                                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.gold),
                                                ),
                                                Text(
                                                  charadaName,
                                                  style: const TextStyle(fontSize: 12, color: AppColors.turquoise, fontWeight: FontWeight.w500),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                    Row(
                                      children: [
                                        if (draw.corrido1 != null) ...[
                                          BolaCorrido(numero: draw.corrido1!, size: 36),
                                          const SizedBox(width: 6),
                                        ],
                                        if (draw.corrido2 != null)
                                          BolaCorrido(numero: draw.corrido2!, size: 36),
                                      ],
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  "Pick 3: ${draw.pick3Raw}  ·  Pick 4: ${draw.pick4Raw ?? '—'}",
                                  style: const TextStyle(fontFamily: 'JetBrainsMono', fontSize: 10, color: AppColors.textFaint),
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
