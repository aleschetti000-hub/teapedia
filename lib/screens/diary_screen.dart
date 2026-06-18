import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import '../data/diary_repository.dart';
import '../data/teas_repository.dart';
import '../models/tea.dart';
import '../models/tea_personal.dart';
import '../theme/app_theme.dart';
import '../widgets/star_row.dart';
import 'tea_diary_detail_screen.dart';

// ── Opzioni di ordinamento ────────────────────────────────────────────────────

enum _SortOption { recent, starsDesc, tastingsDesc, alphabetical }

const _sortLabels = {
  _SortOption.recent: 'Più recenti',
  _SortOption.starsDesc: 'Stelle (alto-basso)',
  _SortOption.tastingsDesc: 'Numero degustazioni',
  _SortOption.alphabetical: 'Alfabetico',
};

// ── Chiavi dei filtri ─────────────────────────────────────────────────────────

const _kTutti = 'tutti';
const _kTeVerde = 'te_verde';
const _kTeNero = 'te_nero';
const _kOolong = 'oolong';
const _kTisane = 'tisana';
const _kStars4 = '4star';
const _kPreferiti = 'preferiti';

// ── Widget principale ─────────────────────────────────────────────────────────

class DiaryScreen extends StatefulWidget {
  final VoidCallback? onGoToExplore;

  const DiaryScreen({super.key, this.onGoToExplore});

  @override
  State<DiaryScreen> createState() => DiaryScreenState();
}

// Stato pubblico: MainShell può chiamare reload() tramite GlobalKey
class DiaryScreenState extends State<DiaryScreen> {
  _DiaryData? _data;
  final Set<String> _filters = {_kTutti};
  _SortOption _sort = _SortOption.recent;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final personals = await DiaryRepository().getAllTeaPersonal();
    final teas = await TeasRepository().loadTeas();
    if (mounted) {
      setState(() {
        _data = _DiaryData(
          personals,
          {for (final t in teas) t.id: t},
        );
      });
    }
  }

  void reload() => _loadData();

  // ── Filtraggio + ordinamento (solo in memoria) ────────────────────────────

  List<(TeaPersonal, Tea?)> get _filteredItems {
    final data = _data;
    if (data == null) return [];

    var items = data.personals.map((p) => (p, data.teaMap[p.teaId])).toList();

    if (!_filters.contains(_kTutti)) {
      final catFilters = _filters.intersection(
        {_kTeVerde, _kTeNero, _kOolong, _kTisane},
      );
      items = items.where((pair) {
        final (personal, tea) = pair;
        bool pass = true;

        // Filtri categoria (OR tra categorie selezionate)
        if (catFilters.isNotEmpty) {
          pass = tea != null && catFilters.contains(tea.category);
        }

        if (_filters.contains(_kStars4)) {
          pass = pass && personal.averageRating >= 4.0;
        }
        if (_filters.contains(_kPreferiti)) {
          pass = pass && personal.isFavorite;
        }
        return pass;
      }).toList();
    }

    items.sort((a, b) {
      final (pa, ta) = a;
      final (pb, tb) = b;
      return switch (_sort) {
        _SortOption.recent =>
          pb.lastTastedAt.compareTo(pa.lastTastedAt),
        _SortOption.starsDesc =>
          pb.averageRating.compareTo(pa.averageRating),
        _SortOption.tastingsDesc =>
          pb.tastingCount.compareTo(pa.tastingCount),
        _SortOption.alphabetical =>
          (ta?.name ?? pa.teaId).compareTo(tb?.name ?? pb.teaId),
      };
    });

    return items;
  }

  void _toggleFilter(String key) {
    setState(() {
      if (key == _kTutti) {
        _filters
          ..clear()
          ..add(_kTutti);
        return;
      }
      if (_filters.contains(key)) {
        _filters.remove(key);
        if (_filters.isEmpty) _filters.add(_kTutti);
      } else {
        _filters.remove(_kTutti);
        _filters.add(key);
      }
    });
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final data = _data;
    final totalTeas = data?.personals.length ?? 0;
    final totalTastings = data?.totalTastings ?? 0;

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 64,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Il mio diario'),
            Text(
              '$totalTeas tè provati · $totalTastings degustazioni totali',
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.normal,
                color: Colors.black45,
              ),
            ),
          ],
        ),
        actions: [
          PopupMenuButton<_SortOption>(
            icon: const Icon(Icons.sort),
            tooltip: 'Ordina',
            onSelected: (opt) => setState(() => _sort = opt),
            itemBuilder: (_) => _SortOption.values.map((opt) {
              return PopupMenuItem(
                value: opt,
                child: Row(
                  children: [
                    SizedBox(
                      width: 20,
                      child: _sort == opt
                          ? const Icon(
                              Icons.check,
                              size: 16,
                              color: AppTheme.primaryGreen,
                            )
                          : null,
                    ),
                    const SizedBox(width: 6),
                    Text(_sortLabels[opt]!),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
      body: data == null
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                _buildFilterRow(),
                Expanded(child: _buildBody(data)),
              ],
            ),
    );
  }

  // ── Riga filtri ───────────────────────────────────────────────────────────

  static const _chipDefs = [
    ('Tutti', _kTutti),
    ('Tè verde', _kTeVerde),
    ('Tè nero', _kTeNero),
    ('Oolong', _kOolong),
    ('Tisane', _kTisane),
    ('4★+', _kStars4),
    ('Preferiti', _kPreferiti),
  ];

  Widget _buildFilterRow() {
    // ScrollConfiguration con tutti i dragDevices garantisce lo scroll
    // su touch, mouse e trackpad macOS senza dipendere dal comportamento globale.
    return ScrollConfiguration(
      behavior: ScrollConfiguration.of(context).copyWith(
        dragDevices: PointerDeviceKind.values.toSet(),
        scrollbars: false,
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
        child: Row(
          children: [
            for (int i = 0; i < _chipDefs.length; i++) ...[
              if (i > 0) const SizedBox(width: 8),
              _chip(_chipDefs[i].$1, _chipDefs[i].$2),
            ],
          ],
        ),
      ),
    );
  }

  Widget _chip(String label, String key) {
    final selected = _filters.contains(key);
    return FilterChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) => _toggleFilter(key),
      showCheckmark: false,
      selectedColor: AppTheme.primaryGreen,
      backgroundColor: const Color(0xFFF0F0EE),
      side: BorderSide.none,
      shape: const StadiumBorder(),
      labelStyle: TextStyle(
        fontSize: 13,
        fontWeight: selected ? FontWeight.w500 : FontWeight.normal,
        color: selected ? Colors.white : Colors.black54,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 4),
    );
  }

  // ── Corpo lista ───────────────────────────────────────────────────────────

  Widget _buildBody(_DiaryData data) {
    if (data.personals.isEmpty) return _buildEmptyDiary();

    final items = _filteredItems;
    if (items.isEmpty) return _buildNoResults();

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 32),
      itemCount: items.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final (personal, tea) = items[index];
        return _DiaryTeaCard(
          personal: personal,
          tea: tea,
          onTap: () async {
            if (tea == null) return;
            await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => TeaDiaryDetailScreen(
                  tea: tea,
                  initialPersonal: personal,
                ),
              ),
            );
            reload();
          },
        );
      },
    );
  }

  Widget _buildEmptyDiary() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.emoji_food_beverage_outlined,
              size: 72,
              color: Colors.black12,
            ),
            const SizedBox(height: 20),
            const Text(
              'Il tuo diario è vuoto',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: Colors.black54,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Inizia esplorando i tè e aggiungendo le tue degustazioni',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.black38,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 28),
            FilledButton.icon(
              onPressed: widget.onGoToExplore,
              icon: const Icon(Icons.explore_outlined, size: 18),
              label: const Text('Esplora i tè'),
              style: FilledButton.styleFrom(
                backgroundColor: AppTheme.primaryGreen,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNoResults() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.filter_list_off, size: 48, color: Colors.black12),
          const SizedBox(height: 16),
          const Text(
            'Nessun tè corrisponde ai filtri',
            style: TextStyle(fontSize: 15, color: Colors.black45),
          ),
          const SizedBox(height: 16),
          TextButton(
            onPressed: () => setState(() {
              _filters
                ..clear()
                ..add(_kTutti);
            }),
            child: const Text('Rimuovi filtri'),
          ),
        ],
      ),
    );
  }
}

// ── Modello dati interno ──────────────────────────────────────────────────────

class _DiaryData {
  final List<TeaPersonal> personals;
  final Map<String, Tea> teaMap;

  _DiaryData(this.personals, this.teaMap);

  int get totalTastings =>
      personals.fold(0, (sum, p) => sum + p.tastingCount);
}

// ── Card del tè nel diario ───────────────────────────────────────────────────

class _DiaryTeaCard extends StatelessWidget {
  final TeaPersonal personal;
  final Tea? tea;
  final VoidCallback onTap;

  const _DiaryTeaCard({
    required this.personal,
    required this.tea,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final teaName = tea?.name ?? personal.teaId;
    final subtitle = tea != null
        ? '${_categoryLabel(tea!.category)} · ${tea!.countryOfOrigin}'
        : '';
    final count = personal.tastingCount;
    final countLabel = count == 1 ? 'degustazione' : 'degustazioni';

    return Material(
      color: const Color(0xFFF8F8F6),
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      teaName,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.black54,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        if (personal.isFavorite) ...[
                          const Icon(
                            Icons.favorite,
                            size: 13,
                            color: Color(0xFFA32D2D),
                          ),
                          const SizedBox(width: 5),
                        ],
                        Flexible(
                          child: Text(
                            '$count $countLabel · ultima il ${_shortDate(personal.lastTastedAt)}',
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.black45,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              StarRow(rating: personal.averageRating),
            ],
          ),
        ),
      ),
    );
  }

  static String _categoryLabel(String cat) => switch (cat) {
        'te_verde' => 'Tè verde',
        'te_nero' => 'Tè nero',
        'oolong' => 'Oolong',
        'tisana' => 'Tisana',
        _ => cat,
      };

  static String _shortDate(DateTime date) {
    const months = [
      'gen', 'feb', 'mar', 'apr', 'mag', 'giu',
      'lug', 'ago', 'set', 'ott', 'nov', 'dic',
    ];
    final now = DateTime.now();
    if (date.year == now.year) {
      return '${date.day} ${months[date.month - 1]}';
    }
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }
}

