import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/bolita_calculator.dart';
import '../../../../core/utils/mystic_engine.dart';
import '../../../../core/utils/reduction_engine.dart';
import '../../../../core/widgets/offline_banner.dart';
import '../../../../data/repositories/draw_repository.dart';

class ToolsScreen extends StatefulWidget {
  final String? initialPyramidSeed;

  const ToolsScreen({super.key, this.initialPyramidSeed});

  @override
  State<ToolsScreen> createState() => _ToolsScreenState();
}

class _ToolsScreenState extends State<ToolsScreen> {
  int _selectedTool = 0; // 0: Pirámide, 1: Cruz 3x3, 2: Equivalencias, 3: Candados, 4: Reducciones, 5: Dioses, 6: Horóscopo
  final _drawRepo = DrawRepository();

  // 1. Estado Pirámide
  late TextEditingController _pyramidController;
  List<List<int>> _pyramidLevels = [];
  List<String> _pyramidSuggestions = [];

  // 2. Estado Cruz 3x3
  DateTime _crossDate = DateTime(2026, 11, 10);
  List<List<int>> _crossMatrix = [];
  List<String> _crossPairs = [];

  // 3. Estado Equivalencias
  int _equivNumber = 15;
  Map<String, String> _equivalencies = {};

  // 4. Estado Candados y Parlés
  final List<String> _parleSelected = ['15', '21', '46'];

  // 5. Estado Reducciones
  final Set<int> _redTens = {1, 2, 4};
  final Set<int> _redTerminals = {5, 6};
  ParityFilter _redParity = ParityFilter.all;
  Set<String> _reducedNumbers = {};

  // 6. Estado Dioses
  String _selectedOrisha = 'Eleguá';

  // 7. Estado Horóscopo
  String _selectedSign = 'Aries';
  Map<String, dynamic> _horoscopeData = {};

  final List<String> _toolLabels = [
    'Pirámide',
    'Cruz 3x3',
    'Equivalencias',
    'Parlés/Candados',
    'Reducciones',
    'Orishas',
    'Horóscopo',
  ];

  @override
  void initState() {
    super.initState();
    _pyramidController = TextEditingController(text: widget.initialPyramidSeed ?? "415");
    _recalculateAll();
  }

  @override
  void dispose() {
    _pyramidController.dispose();
    super.dispose();
  }

  void _recalculateAll() {
    // Pirámide
    _pyramidLevels = BolitaCalculator.calculatePyramid(_pyramidController.text);
    _pyramidSuggestions = BolitaCalculator.extractPyramidSuggestions(_pyramidLevels);

    // Cruz 3x3
    _crossMatrix = BolitaCalculator.calculateLuckCross3x3(_crossDate);
    _crossPairs = BolitaCalculator.extractCrossPairs3x3(_crossMatrix);

    // Equivalencias
    _equivalencies = BolitaCalculator.calculateEquivalencies(_equivNumber);

    // Reducciones
    _reducedNumbers = ReductionEngine.generate(
      tens: _redTens,
      terminals: _redTerminals,
      parity: _redParity,
    );

    // Horóscopo
    _horoscopeData = MysticEngine.generateDailyHoroscope(
      sign: _selectedSign,
      date: DateTime.now(),
    );
  }

  Future<void> _importLatestDraw() async {
    final latest = await _drawRepo.getLatestDraw(lottery: 'florida');
    if (latest != null && mounted) {
      setState(() {
        _pyramidController.text = latest.centena;
        _recalculateAll();
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Tiro importado: ${latest.centena} (Fijo: ${latest.fijo})"),
          backgroundColor: AppColors.cardElevated,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  // Pestaña Pirámide
  Widget _buildPyramidTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _pyramidController,
                  keyboardType: TextInputType.number,
                  maxLength: 7,
                  style: const TextStyle(fontFamily: 'JetBrainsMono', fontSize: 18, color: AppColors.gold, fontWeight: FontWeight.bold),
                  decoration: InputDecoration(
                    counterText: "",
                    labelText: "Semilla de Entrada",
                    labelStyle: const TextStyle(color: AppColors.textMuted),
                    filled: true,
                    fillColor: AppColors.card,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.border)),
                    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.border)),
                    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.gold)),
                  ),
                  onChanged: (val) => setState(() => _recalculateAll()),
                ),
              ),
              const SizedBox(width: 8),
              IconButton.filled(
                icon: const Icon(Icons.download, color: Colors.black),
                style: IconButton.styleFrom(backgroundColor: AppColors.gold),
                tooltip: "Importar último tiro",
                onPressed: _importLatestDraw,
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Renderizado Pirámide Pascal Modulo 10
          Container(
            padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
            decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              children: _pyramidLevels.reversed.map((row) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: row.map((d) {
                      return Container(
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: row.length == 1 ? AppColors.gold : AppColors.cardElevated,
                          border: Border.all(color: row.length == 1 ? AppColors.gold : AppColors.border),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          d.toString(),
                          style: TextStyle(
                            fontFamily: 'JetBrainsMono',
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: row.length == 1 ? Colors.black : AppColors.text,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 16),

          // Sugerencias
          const Text("Combinaciones Sugeridas:", style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.turquoise)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _pyramidSuggestions.map((s) => Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.turquoise.withOpacity(0.15),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.turquoise),
              ),
              child: Text(
                s,
                style: const TextStyle(fontFamily: 'JetBrainsMono', fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.turquoise),
              ),
            )).toList(),
          ),
        ],
      ),
    );
  }

  // Pestaña Cruz 3x3
  Widget _buildCrossTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Fecha: ${_crossDate.day.toString().padLeft(2, '0')}/${_crossDate.month.toString().padLeft(2, '0')}/${_crossDate.year}",
                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.gold),
              ),
              OutlinedButton.icon(
                icon: const Icon(Icons.calendar_today, size: 14, color: AppColors.gold),
                label: const Text("Hoy", style: TextStyle(color: AppColors.gold)),
                onPressed: () {
                  setState(() {
                    _crossDate = DateTime.now();
                    _recalculateAll();
                  });
                },
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Matriz 3x3 estilizada
          Center(
            child: Container(
              width: 220,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.card,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                children: _crossMatrix.asMap().entries.map((rEntry) {
                  final r = rEntry.key;
                  final row = rEntry.value;
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: row.asMap().entries.map((cEntry) {
                      final c = cEntry.key;
                      final val = cEntry.value;
                      final isCenter = (r == 1 && c == 1);
                      return Container(
                        margin: const EdgeInsets.all(4),
                        width: 52,
                        height: 52,
                        decoration: BoxDecoration(
                          color: isCenter ? AppColors.gold.withOpacity(0.25) : AppColors.cardElevated,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: isCenter ? AppColors.gold : AppColors.border, width: isCenter ? 2 : 1),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          val.toString(),
                          style: TextStyle(
                            fontFamily: 'JetBrainsMono',
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: isCenter ? AppColors.gold : AppColors.text,
                          ),
                        ),
                      );
                    }).toList(),
                  );
                }).toList(),
              ),
            ),
          ),
          const SizedBox(height: 20),

          const Text("Parejas Cruzadas Resultantes:", style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.gold)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _crossPairs.map((p) => Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.card,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.border),
              ),
              child: Text(p, style: const TextStyle(fontFamily: 'JetBrainsMono', fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.text)),
            )).toList(),
          ),
        ],
      ),
    );
  }

  // Pestaña Equivalencias
  Widget _buildEquivTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("Selecciona Número Base (00–99):", style: TextStyle(fontSize: 13, color: AppColors.textMuted)),
              DropdownButton<int>(
                value: _equivNumber,
                dropdownColor: AppColors.card,
                style: const TextStyle(fontFamily: 'JetBrainsMono', fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.gold),
                items: List.generate(100, (i) => DropdownMenuItem(value: i, child: Text(i.toString().padLeft(2, '0')))),
                onChanged: (val) {
                  if (val != null) {
                    setState(() {
                      _equivNumber = val;
                      _recalculateAll();
                    });
                  }
                },
              ),
            ],
          ),
          const SizedBox(height: 16),

          // 4 tarjetas de transformación
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.4,
            children: [
              _buildEquivCard("+25 Tradicional", _equivalencies['plus25'] ?? '', "Avance de cuarto"),
              _buildEquivCard("-25 Tradicional", _equivalencies['minus25'] ?? '', "Retroceso de cuarto"),
              _buildEquivCard("Espejo Canónico", _equivalencies['espejo'] ?? '', "Suma 5 a cada dígito"),
              _buildEquivCard("Inverso (Virado)", _equivalencies['inverso'] ?? '', "Dígitos invertidos"),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEquivCard(String title, String value, String desc) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.textMuted)),
          Text(value, style: const TextStyle(fontFamily: 'JetBrainsMono', fontSize: 26, fontWeight: FontWeight.bold, color: AppColors.gold)),
          Text(desc, style: const TextStyle(fontSize: 10, color: AppColors.textFaint)),
        ],
      ),
    );
  }

  // Pestaña Parlés y Candados
  Widget _buildParlesTab() {
    final parles = BolitaCalculator.generateParles(_parleSelected);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text("Tus Números Seleccionados:", style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.textMuted)),
          const SizedBox(height: 8),
          Row(
            children: _parleSelected.map((num) => Container(
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.gold.withOpacity(0.15),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.gold),
              ),
              child: Text(num, style: const TextStyle(fontFamily: 'JetBrainsMono', fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.gold)),
            )).toList(),
          ),
          const SizedBox(height: 20),
          Text("Parlés y Candados Generados (${parles.length}):", style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.turquoise)),
          const SizedBox(height: 10),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: parles.length,
            itemBuilder: (context, idx) {
              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: AppColors.card,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.border),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(parles[idx], style: const TextStyle(fontFamily: 'JetBrainsMono', fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.text)),
                    const Text("Parlé / Candado cerrado", style: TextStyle(fontSize: 11, color: AppColors.textMuted)),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  // Pestaña Reducciones
  Widget _buildReductionsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Decenas Activas (0 al 9):", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textMuted)),
          const SizedBox(height: 6),
          Wrap(
            spacing: 6,
            children: List.generate(10, (d) {
              final active = _redTens.contains(d);
              return FilterChip(
                label: Text("$d"),
                selected: active,
                onSelected: (val) {
                  setState(() {
                    if (val) {
                      _redTens.add(d);
                    } else {
                      _redTens.remove(d);
                    }
                    _recalculateAll();
                  });
                },
                selectedColor: AppColors.gold.withOpacity(0.2),
                labelStyle: TextStyle(color: active ? AppColors.gold : AppColors.textMuted, fontSize: 11),
              );
            }),
          ),
          const SizedBox(height: 12),

          const Text("Terminales Activos (0 al 9):", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textMuted)),
          const SizedBox(height: 6),
          Wrap(
            spacing: 6,
            children: List.generate(10, (u) {
              final active = _redTerminals.contains(u);
              return FilterChip(
                label: Text("$u"),
                selected: active,
                onSelected: (val) {
                  setState(() {
                    if (val) {
                      _redTerminals.add(u);
                    } else {
                      _redTerminals.remove(u);
                    }
                    _recalculateAll();
                  });
                },
                selectedColor: AppColors.turquoise.withOpacity(0.2),
                labelStyle: TextStyle(color: active ? AppColors.turquoise : AppColors.textMuted, fontSize: 11),
              );
            }),
          ),
          const SizedBox(height: 12),

          // Filtro de Paridad
          Row(
            children: [
              const Text("Paridad: ", style: TextStyle(fontSize: 12, color: AppColors.textMuted)),
              ChoiceChip(
                label: const Text("Todos"),
                selected: _redParity == ParityFilter.all,
                onSelected: (_) => setState(() {
                  _redParity = ParityFilter.all;
                  _recalculateAll();
                }),
              ),
              const SizedBox(width: 6),
              ChoiceChip(
                label: const Text("Solo Pares"),
                selected: _redParity == ParityFilter.pairsOnly,
                onSelected: (_) => setState(() {
                  _redParity = ParityFilter.pairsOnly;
                  _recalculateAll();
                }),
              ),
              const SizedBox(width: 6),
              ChoiceChip(
                label: const Text("Solo Impares"),
                selected: _redParity == ParityFilter.oddsOnly,
                onSelected: (_) => setState(() {
                  _redParity = ParityFilter.oddsOnly;
                  _recalculateAll();
                }),
              ),
            ],
          ),
          const SizedBox(height: 16),

          Text("Números Reducidos (${_reducedNumbers.length}):", style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.gold)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: _reducedNumbers.map((n) => Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.card,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: AppColors.border),
              ),
              child: Text(n, style: const TextStyle(fontFamily: 'JetBrainsMono', fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.text)),
            )).toList(),
          ),
        ],
      ),
    );
  }

  // Pestaña Orishas (Tabla de los Dioses)
  Widget _buildOrishasTab() {
    final orisha = MysticEngine.orishas[_selectedOrisha]!;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Selector de Orisha
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.border),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _selectedOrisha,
                dropdownColor: AppColors.card,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.gold),
                items: MysticEngine.orishas.keys.map((k) => DropdownMenuItem(value: k, child: Text(k))).toList(),
                onChanged: (val) {
                  if (val != null) setState(() => _selectedOrisha = val);
                },
              ),
            ),
          ),
          const SizedBox(height: 16),

          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(orisha.domain, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.text)),
                const SizedBox(height: 4),
                Text(orisha.syncretism, style: const TextStyle(fontSize: 12, color: AppColors.turquoise)),
                const SizedBox(height: 10),
                Text(orisha.description, style: const TextStyle(fontSize: 12, color: AppColors.textMuted)),
                const SizedBox(height: 16),
                const Text("Números Sagrados:", style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.gold)),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: orisha.sacredNumbers.map((num) => Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.gold.withOpacity(0.15),
                      border: Border.all(color: AppColors.gold),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      num.toString().padLeft(2, '0'),
                      style: const TextStyle(fontFamily: 'JetBrainsMono', fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.gold),
                    ),
                  )).toList(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Pestaña Horóscopo
  Widget _buildHoroscopeTab() {
    final luckyNumbers = (_horoscopeData['luckyNumbers'] as List<dynamic>?) ?? [];
    final advice = _horoscopeData['advice'] as String? ?? '';

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Selector de Signo
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.border),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _selectedSign,
                dropdownColor: AppColors.card,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.gold),
                items: MysticEngine.zodiacSigns.map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
                onChanged: (val) {
                  if (val != null) {
                    setState(() {
                      _selectedSign = val;
                      _recalculateAll();
                    });
                  }
                },
              ),
            ),
          ),
          const SizedBox(height: 20),

          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              children: [
                const Text("Terna de la Suerte de Hoy:", style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.textMuted)),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: luckyNumbers.map((n) => Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: const RadialGradient(colors: [Color(0xFFFFD56B), AppColors.gold, Color(0xFFB57C1E)]),
                      boxShadow: [BoxShadow(color: AppColors.gold.withOpacity(0.3), blurRadius: 10)],
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      n.toString(),
                      style: const TextStyle(fontFamily: 'JetBrainsMono', fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black),
                    ),
                  )).toList(),
                ),
                const SizedBox(height: 20),
                Text(
                  "“$advice”",
                  style: const TextStyle(fontSize: 13, color: AppColors.turquoise, fontStyle: FontStyle.italic),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
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
        title: const Text("Suite de Cálculo", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.gold)),
      ),
      body: Column(
        children: [
          const OfflineBanner(),
          // Barra de Chips de Herramientas
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            child: Row(
              children: _toolLabels.asMap().entries.map((entry) {
                final idx = entry.key;
                final label = entry.value;
                final isSelected = _selectedTool == idx;
                return Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: ChoiceChip(
                    label: Text(label),
                    selected: isSelected,
                    onSelected: (val) {
                      if (val) setState(() => _selectedTool = idx);
                    },
                    selectedColor: AppColors.gold.withOpacity(0.2),
                    backgroundColor: AppColors.card,
                    labelStyle: TextStyle(
                      color: isSelected ? AppColors.gold : AppColors.textMuted,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      fontSize: 12,
                    ),
                    side: BorderSide(color: isSelected ? AppColors.gold : AppColors.border),
                  ),
                );
              }).toList(),
            ),
          ),
          const Divider(color: AppColors.border, height: 1),

          Expanded(
            child: [
              _buildPyramidTab(),
              _buildCrossTab(),
              _buildEquivTab(),
              _buildParlesTab(),
              _buildReductionsTab(),
              _buildOrishasTab(),
              _buildHoroscopeTab(),
            ][_selectedTool],
          ),
        ],
      ),
    );
  }
}
