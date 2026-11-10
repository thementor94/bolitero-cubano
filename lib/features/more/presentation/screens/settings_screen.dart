import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';
import '../../../../core/database/database_helper.dart';
import '../../../../core/theme/app_colors.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  String _parleRule = 'tradicional'; // 'tradicional' (900x/100x) o 'oriental' (1000x/200x)
  bool _dataSaver = true;
  bool _showFlorida = true;
  bool _showGeorgia = true;
  bool _showNewYork = true;

  int _totalDraws = 0;
  int _totalCharada = 0;
  bool _isLoadingDb = true;

  @override
  void initState() {
    super.initState();
    _loadPreferences();
    _loadDbStats();
  }

  Future<void> _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _parleRule = prefs.getString('setting_parle_rule') ?? 'tradicional';
      _dataSaver = prefs.getBool('setting_data_saver') ?? true;
      _showFlorida = prefs.getBool('setting_lottery_fl') ?? true;
      _showGeorgia = prefs.getBool('setting_lottery_ga') ?? true;
      _showNewYork = prefs.getBool('setting_lottery_ny') ?? true;
    });
  }

  Future<void> _loadDbStats() async {
    final db = await DatabaseHelper.database;
    final drawsCount = Sqflite.firstIntValue(await db.rawQuery('SELECT COUNT(*) FROM local_draws')) ?? 0;
    final charadaCount = Sqflite.firstIntValue(await db.rawQuery('SELECT COUNT(*) FROM charada_entries')) ?? 0;

    if (mounted) {
      setState(() {
        _totalDraws = drawsCount;
        _totalCharada = charadaCount;
        _isLoadingDb = false;
      });
    }
  }

  Future<void> _saveParleRule(String rule) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('setting_parle_rule', rule);
    setState(() => _parleRule = rule);
  }

  Future<void> _exportHistory() async {
    final db = await DatabaseHelper.database;
    final draws = await db.query('local_draws', orderBy: 'draw_date DESC, draw_time DESC', limit: 20);

    final buffer = StringBuffer();
    buffer.writeln("=== BOLITERO LIBRE · ÚLTIMOS TIROS ===");
    for (final d in draws) {
      buffer.writeln("${d['draw_date']} ${d['lottery']} (${d['period']}): Fijo: ${d['fijo']}, Centena: ${d['centena']}, Corridos: ${d['corrido1']}, ${d['corrido2']}");
    }
    buffer.writeln("=== 100% LIBRE Y SIN PUBLICIDAD ===");

    await Clipboard.setData(ClipboardData(text: buffer.toString()));
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Últimos 20 sorteos copiados al portapapeles."),
          backgroundColor: AppColors.cardElevated,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.canvas,
      appBar: AppBar(
        backgroundColor: AppColors.canvas,
        elevation: 0,
        title: const Text("Configuración & Sistema", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.gold)),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Sección Reglas de Pago
          _buildSectionHeader("Reglas de Pago de Parlé"),
          Container(
            decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              children: [
                RadioListTile<String>(
                  title: const Text("Tradicional (Habana / Occidente)", style: TextStyle(fontSize: 14, color: AppColors.text, fontWeight: FontWeight.bold)),
                  subtitle: const Text("Fijo+Corrido paga 900x  ·  Corrido+Corrido paga 100x", style: TextStyle(fontSize: 11, color: AppColors.textMuted)),
                  activeColor: AppColors.gold,
                  value: 'tradicional',
                  groupValue: _parleRule,
                  onChanged: (val) => _saveParleRule(val!),
                ),
                const Divider(color: AppColors.border, height: 1),
                RadioListTile<String>(
                  title: const Text("Oriental (Oriente / Camagüey)", style: TextStyle(fontSize: 14, color: AppColors.text, fontWeight: FontWeight.bold)),
                  subtitle: const Text("Fijo+Corrido paga 1000x · Corrido+Corrido paga 200x", style: TextStyle(fontSize: 11, color: AppColors.textMuted)),
                  activeColor: AppColors.gold,
                  value: 'oriental',
                  groupValue: _parleRule,
                  onChanged: (val) => _saveParleRule(val!),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Sección Ahorro de Datos
          _buildSectionHeader("Conectividad y Red ETECSA"),
          Container(
            decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.border),
            ),
            child: SwitchListTile(
              title: const Text("Modo Ahorro de Datos", style: TextStyle(fontSize: 14, color: AppColors.text, fontWeight: FontWeight.bold)),
              subtitle: const Text("Descarga deltas mínimos < 1 KB por tirada y timeouts extendidos", style: TextStyle(fontSize: 11, color: AppColors.textMuted)),
              activeColor: AppColors.turquoise,
              value: _dataSaver,
              onChanged: (val) async {
                final prefs = await SharedPreferences.getInstance();
                await prefs.setBool('setting_data_saver', val);
                setState(() => _dataSaver = val);
              },
            ),
          ),
          const SizedBox(height: 20),

          // Estado Base de Datos
          _buildSectionHeader("Estado de la Memoria Local (SQLite)"),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              children: [
                _buildInfoRow("Sorteos Históricos Guardados", _isLoadingDb ? "..." : "$_totalDraws tiros (180 días)"),
                const Divider(color: AppColors.border, height: 16),
                _buildInfoRow("Entradas de la Charada", _isLoadingDb ? "..." : "$_totalCharada términos (1 al 100)"),
                const Divider(color: AppColors.border, height: 16),
                _buildInfoRow("Modo de Operación", "100% Offline-First (Sin Nube Obligatoria)"),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Botón Exportar
          SizedBox(
            height: 48,
            child: OutlinedButton.icon(
              icon: const Icon(Icons.copy, color: AppColors.gold),
              label: const Text("Exportar Historial Reciente a Texto", style: TextStyle(color: AppColors.gold, fontWeight: FontWeight.bold)),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: AppColors.gold),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: _exportHistory,
            ),
          ),
          const SizedBox(height: 24),

          // Manifiesto de Software Libre
          Center(
            child: Column(
              children: [
                Text("Bolitero Libre v1.1.0", style: TextStyle(fontFamily: 'JetBrainsMono', fontSize: 13, color: AppColors.gold, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                const Text("Código Abierto · Sin Publicidad · Sin Rastreos", style: TextStyle(fontSize: 11, color: AppColors.textMuted)),
                const SizedBox(height: 2),
                const Text("Hecho con orgullo para la comunidad cubana", style: TextStyle(fontSize: 10, color: AppColors.textFaint)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, left: 4),
      child: Text(title, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.gold)),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontSize: 12, color: AppColors.textMuted)),
        Text(value, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.text)),
      ],
    );
  }
}
