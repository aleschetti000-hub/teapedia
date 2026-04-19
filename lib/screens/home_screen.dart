import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/category_card.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),

              // Header
              Row(
                children: [
                  Container(
                    width: 28,
                    height: 28,
                    decoration: const BoxDecoration(
                      color: AppTheme.primaryGreen,
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: const Text(
                      'T',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  const Text(
                    'Teapedia',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              const Text(
                '5 varietà · 5 regioni del mondo',
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.black54,
                ),
              ),
              const SizedBox(height: 20),

              // Barra di ricerca
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 14, vertical: 12),
                decoration: BoxDecoration(
                  color: const Color(0xFFF4F4F2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: const [
                    Icon(Icons.search,
                        size: 18, color: Colors.black38),
                    SizedBox(width: 10),
                    Text(
                      'Cerca tè, regione, aroma...',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.black45,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Titolo sezione
              const Text(
                'Esplora per categoria',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 12),

              // Griglia categorie
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                childAspectRatio: 1.5,
                children: [
                  CategoryCard(
                    title: 'Tè verde',
                    count: 1,
                    backgroundColor: AppTheme.bgGreen,
                    dotColor: AppTheme.teaGreen,
                    textColor: AppTheme.textGreen,
                    subtitleColor: const Color(0xFF3B6D11),
                    onTap: () {},
                  ),
                  CategoryCard(
                    title: 'Tè nero',
                    count: 2,
                    backgroundColor: AppTheme.bgBlack,
                    dotColor: AppTheme.teaBlack,
                    textColor: AppTheme.textBlack,
                    subtitleColor: const Color(0xFF791F1F),
                    onTap: () {},
                  ),
                  CategoryCard(
                    title: 'Oolong',
                    count: 0,
                    backgroundColor: AppTheme.bgOolong,
                    dotColor: AppTheme.teaOolong,
                    textColor: AppTheme.textOolong,
                    subtitleColor: const Color(0xFF854F0B),
                    onTap: () {},
                  ),
                  CategoryCard(
                    title: 'Tisane',
                    count: 2,
                    backgroundColor: AppTheme.bgHerbal,
                    dotColor: AppTheme.teaHerbal,
                    textColor: AppTheme.textHerbal,
                    subtitleColor: const Color(0xFF3C3489),
                    onTap: () {},
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Scoperta del giorno
              const Text(
                'Scoperta del giorno',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFFF4F4F2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      'Matcha',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'Giappone · Uji, Kyoto',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.black54,
                      ),
                    ),
                    SizedBox(height: 10),
                    Text(
                      'Il "tè della rugiada di giada" cresce all\'ombra per 3 settimane prima della raccolta.',
                      style: TextStyle(
                        fontSize: 13,
                        height: 1.5,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}
