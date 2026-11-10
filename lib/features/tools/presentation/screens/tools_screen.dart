import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/bolita_calculator.dart';
import '../../../../core/widgets/offline_banner.dart';

class ToolsScreen extends StatefulWidget {
  const ToolsScreen({super.key});

  @override
  State<ToolsScreen> createState() => _ToolsScreenState();
}

class _ToolsScreenState extends State<ToolsScreen> {
  int _selectedTab = 0; // 0: Pirámide, 1: Cruz de la Suerte, 2: Equivalencias

  // Estado Pirámide
  String _pyramidSeed = "415";
  List<List<int>> _pyramidLevels = [];
  List<String> _pyramidSuggestions = [];

  // Estado Cruz
  DateTime _crossDate = DateTime.now();
  Map<String, int> _crossMatrix = {};
  List<String> _crossPairs = [];

  // Estado Equivalencias
  int _equivNumber = 15;
  Map<String, String> _equivalencies = {};

  @override
  void initState() {
    super.initState();
    _recalculateAll();
  }

  void _recalculateAll() {
    _pyramidLevels = BolitaCalculator.calculatePyramid(_pyramidSeed);
    _pyramidSuggestions = BolitaCalculator.extractPyramidSuggestions(_pyramidLevels);
    _crossMatrix = BolitaCalculator.calculateLuckCross(_crossDate);
    _crossPairs = BolitaCalculator.calculateCrossPairs(_crossMatrix);
    _equivalencies = BolitaCalculator.calculateEquivalencies(_equivNumber);
  }

  Widget _buildPyramidTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            children: [
              const Text("Pirámide Pascal Modulo 10", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.text)),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("Dígitos base: ", style: TextStyle(color: AppColors.textMuted)),
                  SizedBox(
                    width: 100,
                    child: TextField(
                      style: const TextStyle(fontFamily: 'JetBrainsMono', fontSize: 16, color: AppColors.gold, fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                      controller: TextEditingController(text: _pyramidSeed),
                      onChanged: (v) {
                        setState(() {
                          _pyramidSeed = v;
                          _recalculateAll();
                        });
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              // Renderizado visual de pirámide
              ..._pyramidLevels.reversed.map((row) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: row.map((digit) {
                      final isTop = row.length == 1;
                      return Container(
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        width: isTop ? 44 : 36,
                        height: isTop ? 44 : 36,
                        decoration: BoxDecoration(
                          color: isTop ? AppColors.gold : AppColors.sheet,
                          shape: BoxShape.circle,
                          border: Border.all(color: isTop ? AppColors.gold : AppColors.border),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          "$digit",
                          style: TextStyle(
                            fontFamily: 'JetBrainsMono',
                            fontSize: isTop ? 18 : 14,
                            fontWeight: FontWeight.bold,
                            color: isTop ? AppColors.canvas : AppColors.text,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                );
              }),
              const SizedBox(height: 20),
              const Text("Números Sugeridos de la Pirámide:", style: TextStyle(fontSize: 12, color: AppColors.turquoise, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: _pyramidSuggestions
                    .map((n) => Chip(
                          backgroundColor: AppColors.sheet,
                          label: Text(n, style: const TextStyle(fontFamily: 'JetBrainsMono', fontWeight: FontWeight.bold, color: AppColors.gold)),
                        ))
                    .toList(),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCrossTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            children: [
              const Text("Cruz de la Suerte Numerológica", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.text)),
              const SizedBox(height: 16),
              // Cruz 3x3
              Column(
                children: [
                  // Fila Norte
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(color: AppColors.sheet, borderRadius: BorderRadius.circular(8), border: Border.all(color: AppColors.turquoise)),
                    alignment: Alignment.center,
                    child: Text("${_crossMatrix['north']}", style: const TextStyle(fontFamily: 'JetBrainsMono', fontSize: 20, color: AppColors.text, fontWeight: FontWeight.bold)),
                  ),
                  const SizedBox(height: 6),
                  // Fila Centro
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(color: AppColors.sheet, borderRadius: BorderRadius.circular(8), border: Border.all(color: AppColors.turquoise)),
                        alignment: Alignment.center,
                        child: Text("${_crossMatrix['west']}", style: const TextStyle(fontFamily: 'JetBrainsMono', fontSize: 20, color: AppColors.text, fontWeight: FontWeight.bold)),
                      ),
                      const SizedBox(width: 6),
                      Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(color: AppColors.gold, borderRadius: BorderRadius.circular(10)),
                        alignment: Alignment.center,
                        child: Text("${_crossMatrix['center']}", style: const TextStyle(fontFamily: 'JetBrainsMono', fontSize: 24, color: AppColors.canvas, fontWeight: FontWeight.bold)),
                      ),
                      const SizedBox(width: 6),
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(color: AppColors.sheet, borderRadius: BorderRadius.circular(8), border: Border.all(color: AppColors.turquoise)),
                        alignment: Alignment.center,
                        child: Text("${_crossMatrix['east']}", style: const TextStyle(fontFamily: 'JetBrainsMono', fontSize: 20, color: AppColors.text, fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  // Fila Sur
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(color: AppColors.sheet, borderRadius: BorderRadius.circular(8), border: Border.all(color: AppColors.turquoise)),
                    alignment: Alignment.center,
                    child: Text("${_crossMatrix['south']}", style: const TextStyle(fontFamily: 'JetBrainsMono', fontSize: 20, color: AppColors.text, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              const Text("Parejas Cruzadas del Día:", style: TextStyle(fontSize: 12, color: AppColors.turquoise, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: _crossPairs
                    .map((p) => Chip(
                          backgroundColor: AppColors.sheet,
                          label: Text(p, style: const TextStyle(fontFamily: 'JetBrainsMono', fontWeight: FontWeight.bold, color: AppColors.gold)),
                        ))
                    .toList(),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildEquivTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            children: [
              const Text("Tabla de Equivalencias y Espejos", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.text)),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("Número: ", style: TextStyle(color: AppColors.textMuted)),
                  SizedBox(
                    width: 80,
                    child: TextField(
                      style: const TextStyle(fontFamily: 'JetBrainsMono', fontSize: 20, color: AppColors.gold, fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                      controller: TextEditingController(text: _equivNumber.toString().padLeft(2, '0')),
                      onChanged: (v) {
                        final val = int.tryParse(v);
                        if (val != null) {
                          setState(() {
                            _equivNumber = val;
                            _recalculateAll();
                          });
                        }
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(color: AppColors.sheet, borderRadius: BorderRadius.circular(12)),
                      child: Column(
                        children: [
                          const Text("+25", style: TextStyle(fontSize: 11, color: AppColors.textMuted)),
                          const SizedBox(height: 4),
                          Text(_equivalencies['plus25'] ?? '', style: const TextStyle(fontFamily: 'JetBrainsMono', fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.gold)),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(color: AppColors.sheet, borderRadius: BorderRadius.circular(12)),
                      child: Column(
                        children: [
                          const Text("-25", style: TextStyle(fontSize: 11, color: AppColors.textMuted)),
                          const SizedBox(height: 4),
                          Text(_equivalencies['minus25'] ?? '', style: const TextStyle(fontFamily: 'JetBrainsMono', fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.gold)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(color: AppColors.sheet, borderRadius: BorderRadius.circular(12)),
                      child: Column(
                        children: [
                          const Text("Espejo (+5)", style: TextStyle(fontSize: 11, color: AppColors.textMuted)),
                          const SizedBox(height: 4),
                          Text(_equivalencies['espejo'] ?? '', style: const TextStyle(fontFamily: 'JetBrainsMono', fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.turquoise)),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(color: AppColors.sheet, borderRadius: BorderRadius.circular(12)),
                      child: Column(
                        children: [
                          const Text("Inverso (Virado)", style: TextStyle(fontSize: 11, color: AppColors.textMuted)),
                          const SizedBox(height: 4),
                          Text(_equivalencies['inverso'] ?? '', style: const TextStyle(fontFamily: 'JetBrainsMono', fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.text)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.canvas,
      appBar: AppBar(
        backgroundColor: AppColors.canvas,
        elevation: 0,
        title: const Text("Herramientas y Cálculos", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.gold)),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ChoiceChip(
                label: const Text("Pirámide"),
                selected: _selectedTab == 0,
                onSelected: (_) => setState(() => _selectedTab = 0),
                selectedColor: AppColors.gold.withOpacity(0.2),
                labelStyle: TextStyle(color: _selectedTab == 0 ? AppColors.gold : AppColors.textMuted),
              ),
              ChoiceChip(
                label: const Text("Cruz"),
                selected: _selectedTab == 1,
                onSelected: (_) => setState(() => _selectedTab = 1),
                selectedColor: AppColors.gold.withOpacity(0.2),
                labelStyle: TextStyle(color: _selectedTab == 1 ? AppColors.gold : AppColors.textMuted),
              ),
              ChoiceChip(
                label: const Text("Equivalencias"),
                selected: _selectedTab == 2,
                onSelected: (_) => setState(() => _selectedTab = 2),
                selectedColor: AppColors.gold.withOpacity(0.2),
                labelStyle: TextStyle(color: _selectedTab == 2 ? AppColors.gold : AppColors.textMuted),
              ),
            ],
          ),
        ),
      ),
      body: Column(
        children: [
          const OfflineBanner(),
          Expanded(
            child: _selectedTab == 0
                ? _buildPyramidTab()
                : _selectedTab == 1
                    ? _buildCrossTab()
                    : _buildEquivTab(),
          ),
        ],
      ),
    );
  }
}
