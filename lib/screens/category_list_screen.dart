import 'package:flutter/material.dart';
import '../data/teas_repository.dart';
import '../models/tea.dart';
import '../theme/app_theme.dart';
import 'tea_detail_screen.dart';

class CategoryListScreen extends StatelessWidget {
  final String categoryId;
  final String categoryName;

  const CategoryListScreen({
    super.key,
    required this.categoryId,
    required this.categoryName,
  });

  // Restituisce i colori della categoria (sfondo chip, testo, dot)
  static _CategoryColors _colorsFor(String categoryId) {
    switch (categoryId) {
      case 'te_verde':
        return _CategoryColors(AppTheme.bgGreen, AppTheme.textGreen, AppTheme.teaGreen);
      case 'te_nero':
        return _CategoryColors(AppTheme.bgBlack, AppTheme.textBlack, AppTheme.teaBlack);
      case 'oolong':
        return _CategoryColors(AppTheme.bgOolong, AppTheme.textOolong, AppTheme.teaOolong);
      case 'tisana':
        return _CategoryColors(AppTheme.bgHerbal, AppTheme.textHerbal, AppTheme.teaHerbal);
      default:
        return _CategoryColors(const Color(0xFFF4F4F2), Colors.black87, Colors.black54);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = _colorsFor(categoryId);

    return Scaffold(
      appBar: AppBar(
        title: Text(categoryName),
        backgroundColor: colors.background,
        foregroundColor: colors.text,
        surfaceTintColor: Colors.transparent,
      ),
      body: FutureBuilder<List<Tea>>(
        future: TeasRepository().loadTeasByCategory(categoryId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return const Center(child: Text('Errore nel caricamento.'));
          }

          final teas = snapshot.data ?? [];

          if (teas.isEmpty) {
            return Center(
              child: Text(
                'Nessun tè in questa categoria.',
                style: TextStyle(color: Colors.black45, fontSize: 14),
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            itemCount: teas.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (context, index) {
              return _TeaCard(tea: teas[index], colors: colors);
            },
          );
        },
      ),
    );
  }
}

class _TeaCard extends StatelessWidget {
  final Tea tea;
  final _CategoryColors colors;

  const _TeaCard({required this.tea, required this.colors});

  @override
  Widget build(BuildContext context) {
    // Mostra al massimo 3 aromi
    final aromas = tea.aromas.take(3).toList();

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => TeaDetailScreen(tea: tea)),
        ),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFEEEEEE)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Nome e nome originale
              Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: colors.dot,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    tea.name,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  if (tea.originalName != null) ...[
                    const SizedBox(width: 6),
                    Text(
                      tea.originalName!,
                      style: const TextStyle(
                        fontSize: 13,
                        color: Colors.black38,
                      ),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 4),
              // Origine
              Text(
                '${tea.countryOfOrigin} · ${tea.region}',
                style: const TextStyle(fontSize: 12, color: Colors.black54),
              ),
              const SizedBox(height: 10),
              // Aromi come chip
              Wrap(
                spacing: 6,
                children: aromas.map((aroma) {
                  return Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: colors.background,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      aroma,
                      style: TextStyle(
                        fontSize: 11,
                        color: colors.text,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Struttura di supporto per raggruppare i 3 colori della categoria
class _CategoryColors {
  final Color background;
  final Color text;
  final Color dot;

  const _CategoryColors(this.background, this.text, this.dot);
}
