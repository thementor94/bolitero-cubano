import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../data/models/lab_play_model.dart';

class TicketDetailScreen extends StatelessWidget {
  final LabPlayModel play;

  const TicketDetailScreen({super.key, required this.play});

  String _formatReceipt() {
    final statusText = play.status == 'won'
        ? '¡GANADA! (Pago: +${play.totalPayout.toStringAsFixed(1)} pts)'
        : play.status == 'lost'
            ? 'NO PREMIADA'
            : 'PENDIENTE DE SORTEO';

    return '''
================================
      BOLITERO LIBRE LAB
    Comprobante de Simulación
================================
Ticket: ${play.id}
Fecha Sorteo: ${play.drawDate}
Lotería: ${play.lottery.toUpperCase()} (${play.period.toUpperCase()})
Modalidad: ${play.playType.toUpperCase()}
Números: ${play.numbers}
Puntos Jugados: ${play.virtualPoints.toStringAsFixed(1)} pts
Multiplicador: ${play.payoutMultiplier}x
Estado: $statusText
--------------------------------
Total Retorno: ${play.totalPayout.toStringAsFixed(1)} pts
================================
100% Libre y Sin Apuestas Reales
''';
  }

  @override
  Widget build(BuildContext context) {
    final isWon = play.status == 'won';
    final isLost = play.status == 'lost';

    return Scaffold(
      backgroundColor: AppColors.canvas,
      appBar: AppBar(
        backgroundColor: AppColors.canvas,
        elevation: 0,
        title: const Text("Comprobante Digital", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.gold)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.text),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Tarjeta Estilo Ticket / Comprobante
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.card,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isWon ? AppColors.gold : isLost ? AppColors.border : AppColors.turquoise,
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: isWon ? AppColors.gold.withOpacity(0.15) : Colors.black26,
                    blurRadius: 16,
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Text("BOLITERO LIBRE", style: TextStyle(fontFamily: 'JetBrainsMono', fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.gold)),
                  const Text("Comprobante de Jugada Virtual", style: TextStyle(fontSize: 11, color: AppColors.textMuted)),
                  const SizedBox(height: 12),
                  const Divider(color: AppColors.border),
                  const SizedBox(height: 12),

                  // Estado badge
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                    decoration: BoxDecoration(
                      color: isWon
                          ? AppColors.gold.withOpacity(0.2)
                          : isLost
                              ? Colors.red.withOpacity(0.15)
                              : AppColors.turquoise.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      isWon ? "PREMIADA" : isLost ? "NO PREMIADA" : "PENDIENTE",
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: isWon ? AppColors.gold : isLost ? Colors.redAccent : AppColors.turquoise,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  _buildRow("Ticket ID", play.id.substring(0, 8)),
                  _buildRow("Lotería", "${play.lottery.toUpperCase()} (${play.period})"),
                  _buildRow("Fecha del Sorteo", play.drawDate),
                  _buildRow("Modalidad", play.playType.toUpperCase()),
                  _buildRow("Números", play.numbers, isHighlight: true),
                  _buildRow("Puntos Apostados", "${play.virtualPoints.toStringAsFixed(1)} pts"),
                  _buildRow("Multiplicador", "${play.payoutMultiplier}x"),
                  const Divider(color: AppColors.border),
                  _buildRow(
                    "Retorno Total",
                    "${play.totalPayout.toStringAsFixed(1)} pts",
                    isHighlight: true,
                    highlightColor: isWon ? AppColors.gold : AppColors.textMuted,
                  ),
                  const SizedBox(height: 20),

                  // Código de barras decorativo
                  Container(
                    height: 36,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: AppColors.cardElevated,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      "||||| | |||| ||| || ||||| | |||||",
                      style: TextStyle(fontFamily: 'JetBrainsMono', fontSize: 14, letterSpacing: 4, color: AppColors.textMuted),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Botón Compartir
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.share, color: Colors.black),
                label: const Text("Copiar y Compartir Comprobante", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.gold,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: _formatReceipt()));
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Comprobante copiado al portapapeles para compartir en WhatsApp o Telegram."),
                      backgroundColor: AppColors.cardElevated,
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRow(String label, String value, {bool isHighlight = false, Color? highlightColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 12, color: AppColors.textMuted)),
          Text(
            value,
            style: TextStyle(
              fontFamily: isHighlight ? 'JetBrainsMono' : null,
              fontSize: isHighlight ? 16 : 13,
              fontWeight: isHighlight ? FontWeight.bold : FontWeight.w500,
              color: highlightColor ?? (isHighlight ? AppColors.gold : AppColors.text),
            ),
          ),
        ],
      ),
    );
  }
}
