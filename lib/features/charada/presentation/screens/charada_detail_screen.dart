import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../data/models/charada_model.dart';
import '../../../../data/repositories/draw_repository.dart';

class CharadaDetailScreen extends StatefulWidget {
  final CharadaModel entry;

  const CharadaDetailScreen({super.key, required this.entry});

  @override
  State<CharadaDetailScreen> createState() => _CharadaDetailScreenState();
}

class _CharadaDetailScreenState extends State<CharadaDetailScreen> {
  final _drawRepo = DrawRepository();
  List<Map<String, dynamic>> _historyHits = [];
  bool _isLoadingHistory = true;

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    final numStr = widget.entry.number.toString().padLeft(2, '0');
    final hits = await _drawRepo.getNumberHistory(numStr, limit: 15);
    if (mounted) {
      setState(() {
        _historyHits = hits;
        _isLoadingHistory = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final entry = widget.entry;
    final numStr = entry.number.toString().padLeft(2, '0');

    return Scaffold(
      backgroundColor: AppColors.canvas,
      appBar: AppBar(
        backgroundColor: AppColors.canvas,
        elevation: 0,
        title: Text("Ficha #${entry.number}", style: const TextStyle(color: AppColors.gold, fontWeight: FontWeight.bold)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.text),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Esfera Principal Dorada
            Center(
              child: Container(
                width: 90,
                height: 90,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const RadialGradient(
                    colors: [Color(0xFFFFD56B), AppColors.gold, Color(0xFFB57C1E)],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.gold.withOpacity(0.4),
                      blurRadius: 16,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    numStr,
                    style: const TextStyle(
                      fontFamily: 'JetBrainsMono',
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              entry.primaryName,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.text),
            ),
            if (entry.deity != null) ...[
              const SizedBox(height: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.turquoise.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.turquoise, width: 1),
                ),
                child: Text(
                  entry.deity!,
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.turquoise),
                ),
              ),
            ],
            const SizedBox(height: 20),

            // Tarjeta de Sinónimos Tradicionales
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.card,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Significados Populares y Sinónimos", style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.textMuted)),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: entry.synonyms.map((s) => Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: AppColors.cardElevated,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Text(s, style: const TextStyle(fontSize: 12, color: AppColors.text)),
                    )).toList(),
                  ),
                  if (entry.description != null) ...[
                    const SizedBox(height: 12),
                    Text(entry.description!, style: const TextStyle(fontSize: 12, color: AppColors.textMuted, fontStyle: FontStyle.italic)),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Números Acompañantes (Jaladeras)
            if (entry.accompanying != null) ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.card,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.border),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Números Acompañantes (Jalan)", style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.gold)),
                    const SizedBox(height: 6),
                    const Text("Según la tradición cubana, cuando sale este número suelen salir pronto:", style: TextStyle(fontSize: 11, color: AppColors.textMuted)),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: entry.accompanying!.split(',').map((ac) => Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: AppColors.gold.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.gold),
                        ),
                        child: Text(
                          ac.trim(),
                          style: const TextStyle(fontFamily: 'JetBrainsMono', fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.gold),
                        ),
                      )).toList(),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],

            // Historial de Salidas en los últimos 180 días
            Container(
              width: double.infinity,
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
                      const Text("Apariciones Recientes", style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.text)),
                      Text(
                        _isLoadingHistory ? "Cargando..." : "${_historyHits.length} apariciones",
                        style: const TextStyle(fontSize: 11, color: AppColors.turquoise),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  if (_isLoadingHistory)
                    const Center(child: Padding(padding: EdgeInsets.all(16), child: CircularProgressIndicator(color: AppColors.gold)))
                  else if (_historyHits.isEmpty)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 12),
                      child: Text("No ha salido en los sorteos recientes registrados.", style: TextStyle(fontSize: 12, color: AppColors.textMuted)),
                    )
                  else
                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _historyHits.length,
                      separatorBuilder: (_, __) => const Divider(color: AppColors.border, height: 12),
                      itemBuilder: (context, idx) {
                        final hit = _historyHits[idx];
                        final isFijo = hit['fijo'] == numStr;
                        return Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "${hit['draw_date']}  ·  ${hit['lottery'].toString().toUpperCase()} (${hit['period']})",
                              style: const TextStyle(fontSize: 12, color: AppColors.text),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: isFijo ? AppColors.gold.withOpacity(0.2) : AppColors.turquoise.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                isFijo ? "FIJO" : "CORRIDO",
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: isFijo ? AppColors.gold : AppColors.turquoise,
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
