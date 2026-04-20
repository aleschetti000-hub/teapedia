import 'package:flutter/material.dart';
import '../models/tea.dart';
import '../theme/app_theme.dart';
import '../screens/tea_detail_screen.dart';

class TeaListCard extends StatelessWidget {
  final Tea tea;

  const TeaListCard({super.key, required this.tea});

  static _Colors _colorsFor(String categoryId) {
    switch (categoryId) {
      case 'te_verde':
        return _Colors(AppTheme.bgGreen, AppTheme.textGreen, AppTheme.teaGreen);
      case 'te_nero':
        return _Colors(AppTheme.bgBlack, AppTheme.textBlack, AppTheme.teaBlack);
      case 'oolong':
        return _Colors(AppTheme.bgOolong, AppTheme.textOolong, AppTheme.teaOolong);
      case 'tisana':
        return _Colors(AppTheme.bgHerbal, AppTheme.textHerbal, AppTheme.teaHerbal);
      default:
        return _Colors(const Color(0xFFF4F4F2), Colors.black87, Colors.black54);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = _colorsFor(tea.category);
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
                        fontSize: 15, fontWeight: FontWeight.w500),
                  ),
                  if (tea.originalName != null) ...[
                    const SizedBox(width: 6),
                    Text(
                      tea.originalName!,
                      style: const TextStyle(
                          fontSize: 13, color: Colors.black38),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 4),
              Text(
                '${tea.countryOfOrigin} · ${tea.region}',
                style: const TextStyle(fontSize: 12, color: Colors.black54),
              ),
              const SizedBox(height: 10),
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

class _Colors {
  final Color background;
  final Color text;
  final Color dot;
  const _Colors(this.background, this.text, this.dot);
}
