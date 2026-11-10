import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/offline_banner.dart';
import '../../../../data/models/charada_model.dart';
import '../../../../data/repositories/charada_repository.dart';

class CharadaScreen extends StatefulWidget {
  const CharadaScreen({super.key});

  @override
  State<CharadaScreen> createState() => _CharadaScreenState();
}

class _CharadaScreenState extends State<CharadaScreen> {
  final _charadaRepo = CharadaRepository();
  List<CharadaModel> _entries = [];
  bool _isLoading = true;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadEntries();
  }

  Future<void> _loadEntries() async {
    final list = await _charadaRepo.getAllEntries();
    setState(() {
      _entries = list;
      _isLoading = false;
    });
  }

  Future<void> _onSearch(String q) async {
    setState(() => _searchQuery = q);
    final results = await _charadaRepo.search(q);
    setState(() => _entries = results);
  }

  void _showDetailSheet(CharadaModel item) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.sheet,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    decoration: const BoxDecoration(
                      color: AppColors.gold,
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      item.number.toString().padLeft(2, '0'),
                      style: const TextStyle(
                        fontFamily: 'JetBrainsMono',
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: AppColors.canvas,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(item.primaryName, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.text)),
                      const Text("Charada Tradicional Cubana", style: TextStyle(fontSize: 12, color: AppColors.textMuted)),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 20),
              const Text("Significados populares y sueños:", style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.turquoise)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: item.synonyms
                    .map((s) => Chip(
                          backgroundColor: AppColors.card,
                          side: const BorderSide(color: AppColors.border),
                          label: Text(s, style: const TextStyle(fontSize: 12, color: AppColors.text)),
                        ))
                    .toList(),
              ),
              const SizedBox(height: 20),
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
        title: const Text("Charada Cubana", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.gold)),
      ),
      body: Column(
        children: [
          const OfflineBanner(),
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: TextField(
              style: const TextStyle(color: AppColors.text),
              onChanged: _onSearch,
              decoration: InputDecoration(
                filled: true,
                fillColor: AppColors.card,
                hintText: "Busca un sueño o número...",
                hintStyle: const TextStyle(color: AppColors.textMuted, fontSize: 13),
                prefixIcon: const Icon(Icons.search, color: AppColors.gold),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.border),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.border),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.gold),
                ),
              ),
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator(color: AppColors.gold))
                : _entries.isEmpty
                    ? const Center(child: Text("Sin coincidencias en la charada", style: TextStyle(color: AppColors.textMuted)))
                    : GridView.builder(
                        padding: const EdgeInsets.all(12),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 4,
                          crossAxisSpacing: 8,
                          mainAxisSpacing: 8,
                          childAspectRatio: 0.85,
                        ),
                        itemCount: _entries.length,
                        itemBuilder: (context, index) {
                          final item = _entries[index];
                          return Material(
                            color: AppColors.card,
                            borderRadius: BorderRadius.circular(12),
                            child: InkWell(
                              borderRadius: BorderRadius.circular(12),
                              onTap: () => _showDetailSheet(item),
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: AppColors.border, width: 1),
                                ),
                                padding: const EdgeInsets.all(6),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      item.number.toString().padLeft(2, '0'),
                                      style: const TextStyle(
                                        fontFamily: 'JetBrainsMono',
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.gold,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      item.primaryName,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(
                                        fontSize: 11,
                                        color: AppColors.text,
                                      ),
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
    );
  }
}
