import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/bola.dart';
import '../../../../core/widgets/offline_banner.dart';
import '../../../../data/models/draw_model.dart';
import '../../../../data/repositories/draw_repository.dart';
import '../../../community/presentation/screens/poll_screen.dart';
import '../../../history/presentation/screens/history_screen.dart';
import '../../../more/presentation/screens/settings_screen.dart';
import '../../../tools/presentation/screens/tools_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _drawRepo = DrawRepository();
  DrawModel? _flNight;
  DrawModel? _flMidday;
  List<DrawModel> _otherDraws = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    final flN = await _drawRepo.getLatestDraw(lottery: 'florida', period: 'evening');
    final flM = await _drawRepo.getLatestDraw(lottery: 'florida', period: 'midday');
    final all = await _drawRepo.getRecentDraws(limit: 15);
    final others = all.where((d) => d.lottery != 'florida').toList();

    if (mounted) {
      setState(() {
        _flNight = flN;
        _flMidday = flM;
        _otherDraws = others;
        _isLoading = false;
      });
    }
  }

  Widget _buildFeaturedCard(String title, DrawModel? draw, String fallbackTime) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: AppColors.text,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.turquoise.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(color: AppColors.turquoise, width: 1),
                ),
                child: Text(
                  draw != null ? "Oficial · ${draw.drawTime ?? fallbackTime}" : "Esperando · $fallbackTime",
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: AppColors.turquoise,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (draw != null) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Column(
                  children: [
                    CentenaPill(centena: draw.centena),
                    const SizedBox(height: 4),
                    const Text("Centena", style: TextStyle(fontSize: 10, color: AppColors.textMuted)),
                  ],
                ),
                Column(
                  children: [
                    BolaFijo(numero: draw.fijo, size: 54),
                    const SizedBox(height: 4),
                    const Text("Fijo", style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.gold)),
                  ],
                ),
                Column(
                  children: [
                    Row(
                      children: [
                        if (draw.corrido1 != null) BolaCorrido(numero: draw.corrido1!, size: 44),
                        const SizedBox(width: 8),
                        if (draw.corrido2 != null) BolaCorrido(numero: draw.corrido2!, size: 44),
                      ],
                    ),
                    const SizedBox(height: 4),
                    const Text("Corridos", style: TextStyle(fontSize: 10, color: AppColors.textMuted)),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            Center(
              child: Text(
                "Pick 3: ${draw.pick3Raw}  ·  Pick 4: ${draw.pick4Raw ?? '—'}",
                style: const TextStyle(
                  fontFamily: 'JetBrainsMono',
                  fontSize: 11,
                  color: AppColors.textFaint,
                ),
              ),
            ),
            const SizedBox(height: 12),
            const Divider(color: AppColors.border, height: 1),
            const SizedBox(height: 8),

            // Botones de acción rápida
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton.icon(
                  icon: const Icon(Icons.calculate_outlined, size: 14, color: AppColors.gold),
                  label: const Text("En Pirámide", style: TextStyle(fontSize: 11, color: AppColors.gold)),
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => ToolsScreen(initialPyramidSeed: draw.centena),
                      ),
                    );
                  },
                ),
                const SizedBox(width: 8),
                TextButton.icon(
                  icon: const Icon(Icons.history, size: 14, color: AppColors.turquoise),
                  label: const Text("En Historial", style: TextStyle(fontSize: 11, color: AppColors.turquoise)),
                  onPressed: () {
                    final d = DateTime.tryParse(draw.drawDate);
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => HistoryScreen(initialDate: d),
                      ),
                    );
                  },
                ),
              ],
            ),
          ] else ...[
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 16.0),
              child: Center(
                child: Text("Sorteo en espera de confirmación oficial", style: TextStyle(color: AppColors.textMuted, fontSize: 13)),
              ),
            ),
          ],
        ],
      ),
    );
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
            Text("Bolitero Libre", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.gold)),
            Text("Resultados de la Bolita Cubana", style: TextStyle(fontSize: 11, color: AppColors.textMuted)),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.poll_outlined, color: AppColors.text),
            tooltip: "Encuesta del Día",
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const PollScreen()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.settings_outlined, color: AppColors.text),
            tooltip: "Configuración",
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const SettingsScreen()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.refresh, color: AppColors.gold),
            tooltip: "Actualizar Sorteos",
            onPressed: () async {
              await _drawRepo.syncFromCdn();
              await _loadData();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          const OfflineBanner(),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator(color: AppColors.gold))
                : RefreshIndicator(
                    color: AppColors.gold,
                    onRefresh: () async {
                      await _drawRepo.syncFromCdn();
                      await _loadData();
                    },
                    child: ListView(
                      padding: const EdgeInsets.all(16),
                      children: [
                        _buildFeaturedCard("Florida Noche", _flNight, "9:45 PM"),
                        _buildFeaturedCard("Florida Tarde", _flMidday, "1:30 PM"),
                        const SizedBox(height: 10),
                        const Text(
                          "Otras Loterías Oficiales (Georgia & New York)",
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textMuted,
                          ),
                        ),
                        const SizedBox(height: 10),
                        ..._otherDraws.map((d) => Container(
                              margin: const EdgeInsets.only(bottom: 8),
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                              decoration: BoxDecoration(
                                color: AppColors.card,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: AppColors.border, width: 1),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "${d.lottery.toUpperCase()} · ${d.period.toUpperCase()}",
                                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.text),
                                      ),
                                      Text("${d.drawDate} · ${d.drawTime ?? ''}", style: const TextStyle(fontSize: 10, color: AppColors.textMuted)),
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      BolaFijo(numero: d.fijo, size: 36),
                                      const SizedBox(width: 8),
                                      if (d.corrido1 != null) BolaCorrido(numero: d.corrido1!, size: 32),
                                      const SizedBox(width: 6),
                                      if (d.corrido2 != null) BolaCorrido(numero: d.corrido2!, size: 32),
                                    ],
                                  ),
                                ],
                              ),
                            )),
                      ],
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
