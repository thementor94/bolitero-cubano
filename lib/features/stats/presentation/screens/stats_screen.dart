import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/offline_banner.dart';
import '../../../../data/repositories/charada_repository.dart';
import '../../../../data/repositories/draw_repository.dart';

class StatsScreen extends StatefulWidget {
  const StatsScreen({super.key});

  @override
  State<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends State<StatsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _drawRepo = DrawRepository();
  final _charadaRepo = CharadaRepository();

  String _lottery = 'florida';
  int _days = 30;
  int _statsSubTab = 0; // 0: Calientes, 1: Atrasados

  List<Map<String, dynamic>> _hotNumbers = [];
  List<Map<String, dynamic>> _delayedNumbers = [];
  Map<String, int> _heatmap = {};
  Map<int, String> _charadaNames = {};
  bool _isLoading = true;

  int _heatmapYear = 2026;
  int _heatmapMonth = 11;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        setState(() {});
      }
    });
    _loadAll();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadAll() async {
    setState(() => _isLoading = true);

    if (_charadaNames.isEmpty) {
      final allCharada = await _charadaRepo.getAllEntries();
      _charadaNames = {for (final c in allCharada) c.number: c.primaryName};
    }

    final hot = await _drawRepo.getHotNumbers(lottery: _lottery, days: _days, limit: 10);
    final delayed = await _drawRepo.getDelayedNumbers(lottery: _lottery, limit: 10);
    final heat = await _drawRepo.getMonthlyHeatmap(
      lottery: _lottery,
      year: _heatmapYear,
      month: _heatmapMonth,
    );

    if (mounted) {
      setState(() {
        _hotNumbers = hot;
        _delayedNumbers = delayed;
        _heatmap = heat;
        _isLoading = false;
      });
    }
  }

  Widget _buildAtrasadosCalientesTab() {
    return Column(
      children: [
        // Controles de Lotería y Días
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
          child: Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: AppColors.card,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _lottery,
                      dropdownColor: AppColors.card,
                      style: const TextStyle(color: AppColors.text, fontSize: 13),
                      items: const [
                        DropdownMenuItem(value: 'florida', child: Text("Florida")),
                        DropdownMenuItem(value: 'georgia', child: Text("Georgia")),
                        DropdownMenuItem(value: 'new_york', child: Text("New York")),
                        DropdownMenuItem(value: 'todos', child: Text("Todas las Loterías")),
                      ],
                      onChanged: (val) {
                        if (val != null) {
                          setState(() => _lottery = val);
                          _loadAll();
                        }
                      },
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: AppColors.card,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<int>(
                      value: _days,
                      dropdownColor: AppColors.card,
                      style: const TextStyle(color: AppColors.text, fontSize: 13),
                      items: const [
                        DropdownMenuItem(value: 30, child: Text("Últimos 30 días")),
                        DropdownMenuItem(value: 90, child: Text("Últimos 90 días")),
                        DropdownMenuItem(value: 180, child: Text("Últimos 180 días")),
                      ],
                      onChanged: (val) {
                        if (val != null) {
                          setState(() => _days = val);
                          _loadAll();
                        }
                      },
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),

        // Selector Calientes vs Atrasados
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          child: Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _statsSubTab = 0),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                      color: _statsSubTab == 0 ? AppColors.gold.withOpacity(0.2) : AppColors.card,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: _statsSubTab == 0 ? AppColors.gold : AppColors.border),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      "🔥 Calientes (Top 10)",
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: _statsSubTab == 0 ? AppColors.gold : AppColors.textMuted,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _statsSubTab = 1),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                      color: _statsSubTab == 1 ? AppColors.turquoise.withOpacity(0.2) : AppColors.card,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: _statsSubTab == 1 ? AppColors.turquoise : AppColors.border),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      "⏳ Atrasados (Top 10)",
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: _statsSubTab == 1 ? AppColors.turquoise : AppColors.textMuted,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),

        Expanded(
          child: _isLoading
              ? const Center(child: CircularProgressIndicator(color: AppColors.gold))
              : _statsSubTab == 0
                  ? _buildHotList()
                  : _buildDelayedList(),
        ),
      ],
    );
  }

  Widget _buildHotList() {
    if (_hotNumbers.isEmpty) {
      return const Center(child: Text("Sin datos de frecuencia suficientes.", style: TextStyle(color: AppColors.textMuted)));
    }
    final maxFreq = (_hotNumbers.first['freq'] as num).toDouble();

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _hotNumbers.length,
      itemBuilder: (context, idx) {
        final item = _hotNumbers[idx];
        final fijo = item['fijo'] as String;
        final freq = item['freq'] as int;
        final lastDate = item['last_date'] as String? ?? '—';
        final name = _charadaNames[int.tryParse(fijo) ?? 0] ?? '—';
        final progress = maxFreq > 0 ? (freq / maxFreq) : 0.0;

        return Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 38,
                        height: 38,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.gold.withOpacity(0.15),
                          border: Border.all(color: AppColors.gold),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          fijo,
                          style: const TextStyle(fontFamily: 'JetBrainsMono', fontWeight: FontWeight.bold, color: AppColors.gold, fontSize: 16),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(name, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.text)),
                          Text("Última salida: $lastDate", style: const TextStyle(fontSize: 11, color: AppColors.textMuted)),
                        ],
                      ),
                    ],
                  ),
                  Text(
                    "$freq veces",
                    style: const TextStyle(fontFamily: 'JetBrainsMono', fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.gold),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: progress,
                  backgroundColor: AppColors.cardElevated,
                  color: AppColors.gold,
                  minHeight: 6,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDelayedList() {
    if (_delayedNumbers.isEmpty) {
      return const Center(child: Text("Sin datos de atraso suficientes.", style: TextStyle(color: AppColors.textMuted)));
    }
    final maxDelay = (_delayedNumbers.first['delay'] as num).toDouble();

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _delayedNumbers.length,
      itemBuilder: (context, idx) {
        final item = _delayedNumbers[idx];
        final fijo = item['fijo'] as String;
        final delay = item['delay'] as int;
        final lastDate = item['last_date'] as String? ?? '—';
        final name = _charadaNames[int.tryParse(fijo) ?? 0] ?? '—';
        final progress = maxDelay > 0 ? (delay / maxDelay) : 0.0;

        return Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 38,
                        height: 38,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.turquoise.withOpacity(0.15),
                          border: Border.all(color: AppColors.turquoise),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          fijo,
                          style: const TextStyle(fontFamily: 'JetBrainsMono', fontWeight: FontWeight.bold, color: AppColors.turquoise, fontSize: 16),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(name, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.text)),
                          Text("Última vez: $lastDate", style: const TextStyle(fontSize: 11, color: AppColors.textMuted)),
                        ],
                      ),
                    ],
                  ),
                  Text(
                    "$delay tiros",
                    style: const TextStyle(fontFamily: 'JetBrainsMono', fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.turquoise),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: progress,
                  backgroundColor: AppColors.cardElevated,
                  color: AppColors.turquoise,
                  minHeight: 6,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHeatmapTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Selector de Mes y Año
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Cartón: Noviembre $_heatmapYear",
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.gold),
              ),
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.chevron_left, color: AppColors.text),
                    onPressed: () {
                      setState(() {
                        if (_heatmapMonth == 1) {
                          _heatmapMonth = 12;
                          _heatmapYear--;
                        } else {
                          _heatmapMonth--;
                        }
                      });
                      _loadAll();
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.chevron_right, color: AppColors.text),
                    onPressed: () {
                      setState(() {
                        if (_heatmapMonth == 12) {
                          _heatmapMonth = 1;
                          _heatmapYear++;
                        } else {
                          _heatmapMonth++;
                        }
                      });
                      _loadAll();
                    },
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Leyenda de colores
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildLegendItem(const Color(0xFF161B22), "0 veces"),
              _buildLegendItem(const Color(0xFF1B4942), "1 vez"),
              _buildLegendItem(AppColors.turquoise, "2 veces"),
              _buildLegendItem(AppColors.gold, "3+ veces"),
            ],
          ),
          const SizedBox(height: 16),

          // Matriz 10x10 del Cartón
          AspectRatio(
            aspectRatio: 1.0,
            child: GridView.builder(
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 10,
                crossAxisSpacing: 4,
                mainAxisSpacing: 4,
              ),
              itemCount: 100,
              itemBuilder: (context, idx) {
                final numStr = idx.toString().padLeft(2, '0');
                final count = _heatmap[numStr] ?? 0;

                Color bgColor;
                Color textColor;
                if (count == 0) {
                  bgColor = const Color(0xFF161B22);
                  textColor = AppColors.textMuted;
                } else if (count == 1) {
                  bgColor = const Color(0xFF1B4942);
                  textColor = Colors.white;
                } else if (count == 2) {
                  bgColor = AppColors.turquoise;
                  textColor = Colors.black;
                } else {
                  bgColor = AppColors.gold;
                  textColor = Colors.black;
                }

                return GestureDetector(
                  onTap: () => _showCellDetails(numStr, count),
                  child: Container(
                    decoration: BoxDecoration(
                      color: bgColor,
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(color: AppColors.border.withOpacity(0.5)),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      numStr,
                      style: TextStyle(
                        fontFamily: 'JetBrainsMono',
                        fontSize: 10,
                        fontWeight: count > 0 ? FontWeight.bold : FontWeight.normal,
                        color: textColor,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem(Color color, String text) {
    return Row(
      children: [
        Container(
          width: 14,
          height: 14,
          decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(3)),
        ),
        const SizedBox(width: 6),
        Text(text, style: const TextStyle(fontSize: 11, color: AppColors.textMuted)),
      ],
    );
  }

  void _showCellDetails(String numStr, int count) {
    final name = _charadaNames[int.tryParse(numStr) ?? 0] ?? '—';
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.sheet,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) {
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.gold.withOpacity(0.2),
                      border: Border.all(color: AppColors.gold),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      numStr,
                      style: const TextStyle(fontFamily: 'JetBrainsMono', fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.gold),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.text)),
                      Text("Salidas este mes: $count veces", style: const TextStyle(fontSize: 13, color: AppColors.turquoise)),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Text("Consulta en la pestaña Historial para verificar fechas exactas y combinaciones de corridos.",
                  style: TextStyle(fontSize: 12, color: AppColors.textMuted)),
            ],
          ),
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
        title: const Text("Estadísticas & Tendencias", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.gold)),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.gold,
          labelColor: AppColors.gold,
          unselectedLabelColor: AppColors.textMuted,
          tabs: const [
            Tab(text: "Atrasos & Calientes"),
            Tab(text: "Cartón 10x10"),
          ],
        ),
      ),
      body: Column(
        children: [
          const OfflineBanner(),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildAtrasadosCalientesTab(),
                _buildHeatmapTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
