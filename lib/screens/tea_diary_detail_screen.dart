import 'package:flutter/material.dart';
import '../data/diary_repository.dart';
import '../models/tea.dart';
import '../models/tea_personal.dart';
import '../models/tasting.dart';
import '../theme/app_theme.dart';
import '../widgets/star_row.dart';
import 'new_tasting_sheet.dart';
import 'tea_detail_screen.dart';

class TeaDiaryDetailScreen extends StatefulWidget {
  final Tea tea;
  final TeaPersonal initialPersonal;

  const TeaDiaryDetailScreen({
    super.key,
    required this.tea,
    required this.initialPersonal,
  });

  @override
  State<TeaDiaryDetailScreen> createState() => _TeaDiaryDetailScreenState();
}

class _TeaDiaryDetailScreenState extends State<TeaDiaryDetailScreen> {
  late TeaPersonal _personal;
  List<Tasting>? _tastings;

  @override
  void initState() {
    super.initState();
    _personal = widget.initialPersonal;
    _loadTastings();
  }

  Future<void> _loadTastings() async {
    final tastings =
        await DiaryRepository().getTastingsForTea(widget.tea.id);
    if (mounted) setState(() => _tastings = tastings);
  }

  Future<void> _reloadAll() async {
    final tastings =
        await DiaryRepository().getTastingsForTea(widget.tea.id);
    final personal =
        await DiaryRepository().getTeaPersonal(widget.tea.id);
    if (!mounted) return;
    if (personal == null) {
      // ultima degustazione eliminata → torna al diario
      Navigator.pop(context);
      return;
    }
    setState(() {
      _tastings = tastings;
      _personal = personal;
    });
  }

  Future<void> _openAddTasting() async {
    final saved = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      clipBehavior: Clip.antiAlias,
      builder: (_) => NewTastingSheet(tea: widget.tea),
    );
    if (saved == true) await _reloadAll();
  }

  Future<void> _openEditTasting(Tasting tasting) async {
    final saved = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      clipBehavior: Clip.antiAlias,
      builder: (_) => NewTastingSheet(tea: widget.tea, tasting: tasting),
    );
    if (saved == true) await _reloadAll();
  }

  Future<void> _confirmDelete(Tasting tasting) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Elimina degustazione'),
        content: const Text(
            'Vuoi eliminare questa degustazione? L\'azione non è reversibile.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Annulla'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text(
              'Elimina',
              style: TextStyle(color: Color(0xFFA32D2D)),
            ),
          ),
        ],
      ),
    );
    if (confirmed == true && mounted) {
      await DiaryRepository().deleteTasting(tasting.id!);
      await _reloadAll();
    }
  }

  // ── Stile colore per categoria ────────────────────────────────────────────

  static _HeaderStyle _styleFor(String cat) {
    return switch (cat) {
      'te_verde' =>
        _HeaderStyle(AppTheme.bgGreen, AppTheme.textGreen, AppTheme.teaGreen),
      'te_nero' =>
        _HeaderStyle(AppTheme.bgBlack, AppTheme.textBlack, AppTheme.teaBlack),
      'oolong' => _HeaderStyle(
          AppTheme.bgOolong, AppTheme.textOolong, AppTheme.teaOolong),
      'tisana' => _HeaderStyle(
          AppTheme.bgHerbal, AppTheme.textHerbal, AppTheme.teaHerbal),
      _ => _HeaderStyle(const Color(0xFFF4F4F2), Colors.black87, Colors.black54),
    };
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final style = _styleFor(widget.tea.category);

    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(style),
          Expanded(child: _buildBody(style)),
        ],
      ),
    );
  }

  // ── Header colorato compatto ──────────────────────────────────────────────

  Widget _buildHeader(_HeaderStyle style) {
    final p = _personal;
    final tea = widget.tea;
    final topPad = MediaQuery.of(context).padding.top;

    return Container(
      width: double.infinity,
      color: style.background,
      padding: EdgeInsets.fromLTRB(4, topPad + 4, 20, 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Riga back + nome
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              IconButton(
                icon: Icon(Icons.arrow_back, color: style.text),
                onPressed: () => Navigator.pop(context),
              ),
              const SizedBox(width: 2),
              Expanded(
                child: Text(
                  tea.name,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: style.text,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),

          // Riga statistiche
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 6, 16, 0),
            child: Row(
              children: [
                _statItem('Media', '${p.averageRating.toStringAsFixed(1)}★',
                    style.text),
                _statItem(
                    'Degustazioni', '${p.tastingCount}', style.text),
                _statItem('Prima volta',
                    _shortDate(p.firstTastedAt), style.text),
                _statItem(
                    'Ultima', _shortDate(p.lastTastedAt), style.text),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _statItem(String label, String value, Color textColor) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label.toUpperCase(),
            style: TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.w600,
              color: textColor.withValues(alpha: 0.55),
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }

  // ── Corpo: timeline degustazioni ──────────────────────────────────────────

  Widget _buildBody(_HeaderStyle style) {
    final tastings = _tastings;
    if (tastings == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
      children: [
        // Bottone aggiungi
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            icon: const Icon(Icons.add, size: 18),
            label: const Text('Aggiungi nuova degustazione'),
            onPressed: _openAddTasting,
            style: OutlinedButton.styleFrom(
              foregroundColor: AppTheme.primaryGreen,
              side: const BorderSide(color: AppTheme.primaryGreen),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
        ),

        const SizedBox(height: 20),

        // Timeline degustazioni
        if (tastings.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 24),
            child: Center(
              child: Text(
                'Nessuna degustazione registrata',
                style: TextStyle(fontSize: 14, color: Colors.black38),
              ),
            ),
          )
        else
          ...tastings.map(
            (t) => _TastingCard(
              tasting: t,
              style: style,
              onTap: () => _openEditTasting(t),
              onLongPress: () => _confirmDelete(t),
            ),
          ),

        const SizedBox(height: 8),

        // Link alla scheda catalogo
        Center(
          child: TextButton.icon(
            icon: const Icon(Icons.menu_book_outlined, size: 16),
            label: const Text('Vedi scheda del tè'),
            style: TextButton.styleFrom(foregroundColor: Colors.black54),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (_) => TeaDetailScreen(tea: widget.tea)),
            ),
          ),
        ),
      ],
    );
  }

  // ── Utility date ──────────────────────────────────────────────────────────

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

// ── Stile header ──────────────────────────────────────────────────────────────

class _HeaderStyle {
  final Color background;
  final Color text;
  final Color dot;
  const _HeaderStyle(this.background, this.text, this.dot);
}

// ── Card singola degustazione ─────────────────────────────────────────────────

class _TastingCard extends StatelessWidget {
  final Tasting tasting;
  final _HeaderStyle style;
  final VoidCallback onTap;
  final VoidCallback onLongPress;

  const _TastingCard({
    required this.tasting,
    required this.style,
    required this.onTap,
    required this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: const Color(0xFFF8F8F6),
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: onTap,
          onLongPress: onLongPress,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Data + stelle
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _formatDate(tasting.date),
                      style: const TextStyle(
                          fontSize: 12, color: Colors.black45),
                    ),
                    StarRow(rating: tasting.rating, iconSize: 16),
                  ],
                ),

                // Aromi
                if (tasting.aromas.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 6,
                    runSpacing: 4,
                    children: tasting.aromas
                        .map(
                          (a) => Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: style.background,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              a,
                              style: TextStyle(
                                fontSize: 11,
                                color: style.text,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        )
                        .toList(),
                  ),
                ],

                // Note (troncate a 2 righe)
                if (tasting.notes != null && tasting.notes!.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(
                    tasting.notes!,
                    style: const TextStyle(
                        fontSize: 13, color: Colors.black54, height: 1.4),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],

                // Hint se la card è vuota
                if (tasting.aromas.isEmpty &&
                    (tasting.notes == null || tasting.notes!.isEmpty)) ...[
                  const SizedBox(height: 4),
                  const Text(
                    'Tieni premuto per eliminare · Tocca per modificare',
                    style: TextStyle(
                        fontSize: 11,
                        color: Colors.black26,
                        fontStyle: FontStyle.italic),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  static String _formatDate(DateTime dt) {
    const months = [
      'gennaio', 'febbraio', 'marzo', 'aprile', 'maggio', 'giugno',
      'luglio', 'agosto', 'settembre', 'ottobre', 'novembre', 'dicembre',
    ];
    final h = dt.hour.toString().padLeft(2, '0');
    final m = dt.minute.toString().padLeft(2, '0');
    return '${dt.day} ${months[dt.month - 1]} ${dt.year}, $h:$m';
  }
}
