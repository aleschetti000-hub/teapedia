import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/tea.dart';
import '../theme/app_theme.dart';
import 'new_tasting_sheet.dart';

class TeaDetailScreen extends StatelessWidget {
  final Tea tea;

  const TeaDetailScreen({super.key, required this.tea});

  static _CategoryStyle _styleFor(String categoryId) {
    switch (categoryId) {
      case 'te_verde':
        return _CategoryStyle(AppTheme.bgGreen, AppTheme.textGreen, AppTheme.teaGreen);
      case 'te_nero':
        return _CategoryStyle(AppTheme.bgBlack, AppTheme.textBlack, AppTheme.teaBlack);
      case 'oolong':
        return _CategoryStyle(AppTheme.bgOolong, AppTheme.textOolong, AppTheme.teaOolong);
      case 'tisana':
        return _CategoryStyle(AppTheme.bgHerbal, AppTheme.textHerbal, AppTheme.teaHerbal);
      default:
        return _CategoryStyle(const Color(0xFFF4F4F2), Colors.black87, Colors.black54);
    }
  }

  static String _categoryName(String categoryId) {
    switch (categoryId) {
      case 'te_verde': return 'Tè verde';
      case 'te_nero':  return 'Tè nero';
      case 'oolong':   return 'Oolong';
      case 'tisana':   return 'Tisana';
      default:         return categoryId;
    }
  }

  static String _caffeineLabel(String caffeine) {
    switch (caffeine) {
      case 'assente': return 'Assente';
      case 'bassa':   return 'Bassa';
      case 'media':   return 'Media';
      case 'alta':    return 'Alta';
      default:        return caffeine;
    }
  }

  @override
  Widget build(BuildContext context) {
    final style = _styleFor(tea.category);

    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle.light,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.favorite_border, color: Colors.white),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header immagine (280px, include area dietro AppBar)
          SizedBox(
            height: 280,
            child: Stack(
              fit: StackFit.expand,
              children: [
                Image.asset(
                  'assets/images/teas/${tea.id}.jpg',
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(color: style.background),
                ),
                const DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Colors.transparent, Color(0xA6000000)],
                      stops: [0.2, 1.0],
                    ),
                  ),
                ),
                Positioned(
                  bottom: 18,
                  left: 20,
                  right: 20,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        tea.name,
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                          shadows: [
                            Shadow(
                              offset: Offset(0, 1),
                              blurRadius: 2,
                              color: Color(0x66000000),
                            ),
                          ],
                        ),
                      ),
                      if (tea.originalName != null) ...[
                        const SizedBox(height: 3),
                        Text(
                          tea.originalName!,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.white.withValues(alpha: 0.9),
                            shadows: const [
                              Shadow(
                                offset: Offset(0, 1),
                                blurRadius: 2,
                                color: Color(0x66000000),
                              ),
                            ],
                          ),
                        ),
                      ],
                      const SizedBox(height: 4),
                      Text(
                        '${_categoryName(tea.category)} · ${tea.countryOfOrigin}',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.white.withValues(alpha: 0.85),
                          shadows: const [
                            Shadow(
                              offset: Offset(0, 1),
                              blurRadius: 2,
                              color: Color(0x66000000),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Contenuto scrollabile
          Expanded(
            child: SingleChildScrollView(
              physics: const ClampingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 24),

                  _SectionTitle('Scheda tecnica'),
                  const SizedBox(height: 10),
                  _TechCard(tea: tea, style: style),

                  const SizedBox(height: 24),

                  _SectionTitle('Aromi'),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: tea.aromas.map((aroma) {
                      return Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: style.background,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          aroma,
                          style: TextStyle(
                            fontSize: 13,
                            color: style.text,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      );
                    }).toList(),
                  ),

                  const SizedBox(height: 24),

                  _SectionTitle('Preparazione'),
                  const SizedBox(height: 8),
                  Text(
                    tea.preparation,
                    style: const TextStyle(
                        fontSize: 14, height: 1.6, color: Colors.black87),
                  ),

                  const SizedBox(height: 24),

                  _SectionTitle('Storia'),
                  const SizedBox(height: 8),
                  Text(
                    tea.history,
                    style: const TextStyle(
                        fontSize: 14, height: 1.6, color: Colors.black87),
                  ),

                  const SizedBox(height: 24),

                  _SectionTitle('Lo sapevi?'),
                  const SizedBox(height: 10),
                  ...tea.funFacts.map(
                      (fact) => _FunFactRow(fact: fact, dot: style.dot)),

                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton.icon(
                      onPressed: () async {
                        final saved = await showModalBottomSheet<bool>(
                          context: context,
                          isScrollControlled: true,
                          backgroundColor: Colors.white,
                          shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.vertical(
                                top: Radius.circular(16)),
                          ),
                          clipBehavior: Clip.antiAlias,
                          builder: (_) => NewTastingSheet(tea: tea),
                        );
                        if (saved == true && context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Degustazione aggiunta al diario'),
                              duration: Duration(seconds: 7),
                            ),
                          );
                        }
                      },
                      icon: const Icon(Icons.add),
                      label: const Text(
                        'Aggiungi al diario',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryGreen,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TechCard extends StatelessWidget {
  final Tea tea;
  final _CategoryStyle style;

  const _TechCard({required this.tea, required this.style});

  @override
  Widget build(BuildContext context) {
    final tempMin = tea.temperatureC[0];
    final tempMax = tea.temperatureC[1];
    final infMin = (tea.infusionSec[0] / 60).round();
    final infMax = (tea.infusionSec[1] / 60).round();

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF4F4F2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Row(
            children: [
              _TechItem(
                label: 'Origine',
                value: '${tea.countryOfOrigin}\n${tea.region}',
              ),
              const SizedBox(width: 12),
              _TechItem(
                label: 'Caffeina',
                value: TeaDetailScreen._caffeineLabel(tea.caffeine),
                dotColor: style.dot,
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _TechItem(
                label: 'Temperatura',
                value: '$tempMin–$tempMax°C',
              ),
              const SizedBox(width: 12),
              _TechItem(
                label: 'Infusione',
                value: infMin == infMax ? '$infMin min' : '$infMin–$infMax min',
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _TechItem extends StatelessWidget {
  final String label;
  final String value;
  final Color? dotColor;

  const _TechItem({required this.label, required this.value, this.dotColor});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label.toUpperCase(),
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: Colors.black45,
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              if (dotColor != null) ...[
                Container(
                  width: 7,
                  height: 7,
                  decoration: BoxDecoration(
                      color: dotColor, shape: BoxShape.circle),
                ),
                const SizedBox(width: 5),
              ],
              Flexible(
                child: Text(
                  value,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
                    height: 1.4,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _FunFactRow extends StatelessWidget {
  final String fact;
  final Color dot;

  const _FunFactRow({required this.fact, required this.dot});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(color: dot, shape: BoxShape.circle),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              fact,
              style: const TextStyle(
                  fontSize: 14, height: 1.5, color: Colors.black87),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String text;
  const _SectionTitle(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
    );
  }
}

class _CategoryStyle {
  final Color background;
  final Color text;
  final Color dot;
  const _CategoryStyle(this.background, this.text, this.dot);
}
