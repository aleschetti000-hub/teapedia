import 'package:flutter/material.dart';
import '../data/teas_repository.dart';
import '../models/tea.dart';
import '../theme/app_theme.dart';
import '../widgets/category_card.dart';
import '../widgets/tea_list_card.dart';
import 'category_list_screen.dart';
import 'tea_detail_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<Tea> _allTeas = [];
  String _query = '';

  // Tè del giorno: ruota in base al giorno dell'anno, non è casuale
  static Tea _teaOfTheDay(List<Tea> teas) {
    final dayOfYear = DateTime.now().difference(DateTime(DateTime.now().year)).inDays;
    return teas[dayOfYear % teas.length];
  }

  @override
  void initState() {
    super.initState();
    TeasRepository().loadTeas().then((teas) {
      if (mounted) setState(() => _allTeas = teas);
    });
    _searchController.addListener(() {
      setState(() => _query = _searchController.text);
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Tea> get _filteredTeas {
    if (_query.isEmpty) return [];
    final q = _query.toLowerCase();
    return _allTeas.where((tea) {
      return tea.name.toLowerCase().contains(q) ||
          (tea.originalName?.toLowerCase().contains(q) ?? false) ||
          tea.countryOfOrigin.toLowerCase().contains(q) ||
          tea.region.toLowerCase().contains(q) ||
          tea.category.toLowerCase().contains(q) ||
          tea.aromas.any((a) => a.toLowerCase().contains(q));
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final regions = <String>{};
    for (final tea in _allTeas) {
      regions.add(tea.region);
    }
    final countByCategory = <String, int>{};
    for (final tea in _allTeas) {
      countByCategory[tea.category] = (countByCategory[tea.category] ?? 0) + 1;
    }
    final todayTea = _allTeas.isNotEmpty ? _teaOfTheDay(_allTeas) : null;
    final isSearching = _query.isNotEmpty;
    final results = _filteredTeas;

    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header + barra di ricerca (fissi in cima)
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
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
                  Text(
                    '${_allTeas.length} varietà · ${regions.length} regioni del mondo',
                    style: const TextStyle(fontSize: 13, color: Colors.black54),
                  ),
                  const SizedBox(height: 20),

                  // Barra di ricerca reale
                  Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFFF4F4F2),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: TextField(
                      controller: _searchController,
                      style: const TextStyle(fontSize: 14),
                      decoration: InputDecoration(
                        hintText: 'Cerca tè, regione, aroma...',
                        hintStyle: const TextStyle(
                          fontSize: 14,
                          color: Colors.black45,
                        ),
                        prefixIcon: const Icon(
                          Icons.search,
                          size: 18,
                          color: Colors.black38,
                        ),
                        suffixIcon: isSearching
                            ? IconButton(
                                icon: const Icon(Icons.close,
                                    size: 18, color: Colors.black38),
                                onPressed: () => _searchController.clear(),
                              )
                            : null,
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),

            // Contenuto: home normale o risultati ricerca
            Expanded(
              child: isSearching
                  ? _buildSearchResults(results)
                  : _buildHomeContent(countByCategory, todayTea),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchResults(List<Tea> results) {
    if (results.isEmpty) {
      return const Center(
        child: Text(
          'Nessun tè trovato.\nProva con un altro termine.',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 14, color: Colors.black45, height: 1.6),
        ),
      );
    }

    return ListView.separated(
      physics: const ClampingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
      itemCount: results.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (context, index) => TeaListCard(tea: results[index]),
    );
  }

  Widget _buildHomeContent(Map<String, int> countByCategory, Tea? todayTea) {
    return SingleChildScrollView(
      physics: const ClampingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Esplora per categoria',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 12),

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
                count: countByCategory['te_verde'] ?? 0,
                backgroundColor: AppTheme.bgGreen,
                dotColor: AppTheme.teaGreen,
                textColor: AppTheme.textGreen,
                subtitleColor: const Color(0xFF3B6D11),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const CategoryListScreen(
                      categoryId: 'te_verde',
                      categoryName: 'Tè verde',
                    ),
                  ),
                ),
              ),
              CategoryCard(
                title: 'Tè nero',
                count: countByCategory['te_nero'] ?? 0,
                backgroundColor: AppTheme.bgBlack,
                dotColor: AppTheme.teaBlack,
                textColor: AppTheme.textBlack,
                subtitleColor: const Color(0xFF791F1F),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const CategoryListScreen(
                      categoryId: 'te_nero',
                      categoryName: 'Tè nero',
                    ),
                  ),
                ),
              ),
              CategoryCard(
                title: 'Oolong',
                count: countByCategory['oolong'] ?? 0,
                backgroundColor: AppTheme.bgOolong,
                dotColor: AppTheme.teaOolong,
                textColor: AppTheme.textOolong,
                subtitleColor: const Color(0xFF854F0B),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const CategoryListScreen(
                      categoryId: 'oolong',
                      categoryName: 'Oolong',
                    ),
                  ),
                ),
              ),
              CategoryCard(
                title: 'Tisane',
                count: countByCategory['tisana'] ?? 0,
                backgroundColor: AppTheme.bgHerbal,
                dotColor: AppTheme.teaHerbal,
                textColor: AppTheme.textHerbal,
                subtitleColor: const Color(0xFF3C3489),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const CategoryListScreen(
                      categoryId: 'tisana',
                      categoryName: 'Tisane',
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          const Text(
            'Scoperta del giorno',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 10),

          if (todayTea != null)
            _TodayTeaCard(tea: todayTea)
          else
            const SizedBox(
              height: 80,
              child: Center(child: CircularProgressIndicator()),
            ),

          const SizedBox(height: 32),
        ],
      ),
    );
  }
}

class _TodayTeaCard extends StatelessWidget {
  final Tea tea;
  const _TodayTeaCard({required this.tea});

  @override
  Widget build(BuildContext context) {
    // Usa il primo fun fact come anteprima
    final preview = tea.funFacts.isNotEmpty ? tea.funFacts.first : tea.history;

    return Material(
      color: const Color(0xFFF4F4F2),
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => TeaDetailScreen(tea: tea)),
        ),
        borderRadius: BorderRadius.circular(10),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                tea.name,
                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 2),
              Text(
                '${tea.countryOfOrigin} · ${tea.region}',
                style: const TextStyle(fontSize: 12, color: Colors.black54),
              ),
              const SizedBox(height: 10),
              Text(
                preview,
                style: const TextStyle(fontSize: 13, height: 1.5, color: Colors.black87),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
