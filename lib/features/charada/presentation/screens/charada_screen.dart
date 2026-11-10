import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/offline_banner.dart';
import '../../../../data/models/charada_model.dart';
import '../../../../data/repositories/charada_repository.dart';
import 'charada_detail_screen.dart';

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
  String _selectedCategory = 'Todos';

  final List<String> _categories = ['Todos', 'Clásica', 'Animales', 'Santería'];

  @override
  void initState() {
    super.initState();
    _loadEntries();
  }

  Future<void> _loadEntries() async {
    final list = await _charadaRepo.getAllEntries();
    if (mounted) {
      setState(() {
        _entries = list;
        _isLoading = false;
      });
    }
  }

  Future<void> _filter() async {
    final results = await _charadaRepo.search(
      _searchQuery,
      category: _selectedCategory == 'Todos' ? null : _selectedCategory,
    );
    if (mounted) {
      setState(() => _entries = results);
    }
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
            Text("Charada Cubana", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.gold)),
            Text("Diccionario místico del 1 al 100", style: TextStyle(fontSize: 11, color: AppColors.textMuted)),
          ],
        ),
      ),
      body: Column(
        children: [
          const OfflineBanner(),
          // Barra de búsqueda en tiempo real
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: TextField(
              onChanged: (val) {
                _searchQuery = val;
                _filter();
              },
              style: const TextStyle(color: AppColors.text),
              decoration: InputDecoration(
                hintText: "Buscar por número, animal, santo o sinónimo...",
                hintStyle: const TextStyle(color: AppColors.textFaint, fontSize: 13),
                prefixIcon: const Icon(Icons.search, color: AppColors.gold),
                filled: true,
                fillColor: AppColors.card,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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

          // Chips de categorías
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Row(
              children: _categories.map((cat) {
                final isSelected = _selectedCategory == cat;
                return Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: ChoiceChip(
                    label: Text(cat),
                    selected: isSelected,
                    onSelected: (selected) {
                      if (selected) {
                        setState(() => _selectedCategory = cat);
                        _filter();
                      }
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
          const SizedBox(height: 6),

          // Lista de Fichas
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator(color: AppColors.gold))
                : _entries.isEmpty
                    ? const Center(
                        child: Text("No se encontraron coincidencias en la Charada.", style: TextStyle(color: AppColors.textMuted)),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        itemCount: _entries.length,
                        itemBuilder: (context, index) {
                          final item = _entries[index];
                          final numStr = item.number.toString().padLeft(2, '0');
                          return Card(
                            color: AppColors.card,
                            margin: const EdgeInsets.only(bottom: 8),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                              side: const BorderSide(color: AppColors.border),
                            ),
                            child: InkWell(
                              borderRadius: BorderRadius.circular(12),
                              onTap: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(builder: (_) => CharadaDetailScreen(entry: item)),
                                );
                              },
                              child: Padding(
                                padding: const EdgeInsets.all(12.0),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 44,
                                      height: 44,
                                      decoration: BoxDecoration(
                                        color: AppColors.gold.withOpacity(0.15),
                                        shape: BoxShape.circle,
                                        border: Border.all(color: AppColors.gold, width: 1.5),
                                      ),
                                      alignment: Alignment.center,
                                      child: Text(
                                        numStr,
                                        style: const TextStyle(
                                          fontFamily: 'JetBrainsMono',
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: AppColors.gold,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 14),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              Text(
                                                item.primaryName,
                                                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.text),
                                              ),
                                              if (item.deity != null) ...[
                                                const SizedBox(width: 8),
                                                Text(
                                                  "· ${item.deity!.split('/').first.trim()}",
                                                  style: const TextStyle(fontSize: 11, color: AppColors.turquoise),
                                                  overflow: TextOverflow.ellipsis,
                                                ),
                                              ],
                                            ],
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            item.synonyms.take(4).join(', '),
                                            style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ],
                                      ),
                                    ),
                                    const Icon(Icons.chevron_right, color: AppColors.textFaint),
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
