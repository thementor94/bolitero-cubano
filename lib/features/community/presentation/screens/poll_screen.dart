import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/offline_banner.dart';

class PollScreen extends StatefulWidget {
  const PollScreen({super.key});

  @override
  State<PollScreen> createState() => _PollScreenState();
}

class _PollScreenState extends State<PollScreen> {
  String _pollId = "2026-11-10";
  String _question = "¿Cuál es tu número fijo para el sorteo de hoy?";
  int _totalVotes = 348;
  List<Map<String, dynamic>> _topPicks = [];
  String? _myVote;
  bool _hasVoted = false;
  bool _isLoading = true;

  final TextEditingController _voteInputController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadPoll();
  }

  @override
  void dispose() {
    _voteInputController.dispose();
    super.dispose();
  }

  Future<void> _loadPoll() async {
    final prefs = await SharedPreferences.getInstance();
    final savedVote = prefs.getString('poll_vote_$_pollId');

    // Cargar datos locales de respaldo
    _topPicks = [
      {"number": "15", "charada": "Perro", "votes": 82, "percentage": 23.5},
      {"number": "21", "charada": "Majá", "votes": 64, "percentage": 18.4},
      {"number": "04", "charada": "Gato", "votes": 49, "percentage": 14.1},
      {"number": "77", "charada": "Banderas", "votes": 38, "percentage": 10.9},
      {"number": "88", "charada": "Hojas", "votes": 31, "percentage": 8.9},
    ];

    // Intentar sincronizar desde CDN
    try {
      final resp = await http.get(Uri.parse(ApiConstants.pollCdnUrl)).timeout(const Duration(seconds: 4));
      if (resp.statusCode == 200) {
        final data = json.decode(utf8.decode(resp.bodyBytes)) as Map<String, dynamic>;
        _pollId = data['poll_id'] as String? ?? _pollId;
        _question = data['question'] as String? ?? _question;
        _totalVotes = (data['total_votes'] as num?)?.toInt() ?? _totalVotes;
        final rawPicks = (data['top_picks'] as List<dynamic>?) ?? [];
        if (rawPicks.isNotEmpty) {
          _topPicks = rawPicks.map((e) => Map<String, dynamic>.from(e as Map)).toList();
        }
      }
    } catch (_) {
      // Fallback transparente a datos cacheados
    }

    if (mounted) {
      setState(() {
        _myVote = savedVote;
        _hasVoted = savedVote != null;
        _isLoading = false;
      });
    }
  }

  Future<void> _submitVote(String number) async {
    final clean = number.trim().padLeft(2, '0');
    if (clean.length != 2) return;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('poll_vote_$_pollId', clean);

    setState(() {
      _myVote = clean;
      _hasVoted = true;
      _totalVotes++;

      // Actualizar conteo local
      bool found = false;
      for (final p in _topPicks) {
        if (p['number'] == clean) {
          p['votes'] = (p['votes'] as int) + 1;
          found = true;
          break;
        }
      }
      if (!found) {
        _topPicks.add({
          "number": clean,
          "charada": "Elegido",
          "votes": 1,
          "percentage": 1.0,
        });
      }

      // Recalcular porcentajes
      for (final p in _topPicks) {
        p['percentage'] = ((p['votes'] as int) / _totalVotes) * 100;
      }
      _topPicks.sort((a, b) => (b['votes'] as int).compareTo(a['votes'] as int));
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("¡Voto registrado para el #$clean!"),
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
        title: const Text("Encuesta del Día", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.gold)),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const OfflineBanner(),

            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Tarjeta Pregunta del Día
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppColors.card,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: AppColors.turquoise.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: const Text("ABIERTA · Cierra 9:30 PM", style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.turquoise)),
                            ),
                            Text("$_totalVotes votos", style: const TextStyle(fontSize: 12, color: AppColors.textMuted)),
                          ],
                        ),
                        const SizedBox(height: 14),
                        Text(
                          _question,
                          style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: AppColors.text),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),

                        if (_hasVoted) ...[
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                            decoration: BoxDecoration(
                              color: AppColors.gold.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: AppColors.gold),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.check_circle, color: AppColors.gold, size: 20),
                                const SizedBox(width: 8),
                                Text(
                                  "Tu voto de hoy: #$_myVote",
                                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.gold),
                                ),
                              ],
                            ),
                          ),
                        ] else ...[
                          Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  controller: _voteInputController,
                                  keyboardType: TextInputType.number,
                                  maxLength: 2,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(fontFamily: 'JetBrainsMono', fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.gold),
                                  decoration: InputDecoration(
                                    counterText: "",
                                    hintText: "00",
                                    hintStyle: const TextStyle(color: AppColors.textFaint),
                                    filled: true,
                                    fillColor: AppColors.cardElevated,
                                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.gold,
                                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                ),
                                onPressed: () {
                                  if (_voteInputController.text.isNotEmpty) {
                                    _submitVote(_voteInputController.text);
                                  }
                                },
                                child: const Text("Votar", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Distribución de Votos de la Comunidad
                  const Text("Termómetro de la Comunidad (Más Votados):", style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.text)),
                  const SizedBox(height: 12),

                  _isLoading
                      ? const Center(child: CircularProgressIndicator(color: AppColors.gold))
                      : ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: _topPicks.length,
                          itemBuilder: (context, idx) {
                            final pick = _topPicks[idx];
                            final numStr = pick['number'] as String;
                            final charada = pick['charada'] as String;
                            final votes = pick['votes'] as int;
                            final pct = (pick['percentage'] as num).toDouble();

                            return Container(
                              margin: const EdgeInsets.only(bottom: 10),
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: AppColors.card,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: numStr == _myVote ? AppColors.gold : AppColors.border),
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
                                            width: 36,
                                            height: 36,
                                            decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              color: numStr == _myVote ? AppColors.gold : AppColors.cardElevated,
                                              border: Border.all(color: AppColors.gold),
                                            ),
                                            alignment: Alignment.center,
                                            child: Text(
                                              numStr,
                                              style: TextStyle(
                                                fontFamily: 'JetBrainsMono',
                                                fontWeight: FontWeight.bold,
                                                color: numStr == _myVote ? Colors.black : AppColors.gold,
                                                fontSize: 15,
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 12),
                                          Text(charada, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.text)),
                                        ],
                                      ),
                                      Text(
                                        "${pct.toStringAsFixed(1)}% ($votes)",
                                        style: const TextStyle(fontFamily: 'JetBrainsMono', fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.textMuted),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(4),
                                    child: LinearProgressIndicator(
                                      value: pct / 100.0,
                                      backgroundColor: AppColors.cardElevated,
                                      color: numStr == _myVote ? AppColors.gold : AppColors.turquoise,
                                      minHeight: 6,
                                    ),
                                  ),
                                ],
                              ),
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
