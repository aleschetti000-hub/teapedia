import 'package:flutter/material.dart';
import '../models/tea.dart';
import '../models/tasting.dart';
import '../data/diary_repository.dart';
import '../theme/app_theme.dart';

class NewTastingSheet extends StatefulWidget {
  final Tea tea;
  const NewTastingSheet({super.key, required this.tea});

  @override
  State<NewTastingSheet> createState() => _NewTastingSheetState();
}

class _NewTastingSheetState extends State<NewTastingSheet> {
  int _rating = 0;
  final Set<String> _selectedAromas = {};
  final TextEditingController _notesController = TextEditingController();
  bool _saving = false;
  final DateTime _date = DateTime.now();

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  String _formatDate(DateTime dt) {
    const months = [
      'gennaio', 'febbraio', 'marzo', 'aprile', 'maggio', 'giugno',
      'luglio', 'agosto', 'settembre', 'ottobre', 'novembre', 'dicembre',
    ];
    final h = dt.hour.toString().padLeft(2, '0');
    final m = dt.minute.toString().padLeft(2, '0');
    return '${dt.day} ${months[dt.month - 1]} ${dt.year}, $h:$m';
  }

  Future<void> _save() async {
    if (_rating == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Seleziona almeno una stella')),
      );
      return;
    }

    setState(() => _saving = true);

    try {
      await DiaryRepository().addTasting(Tasting(
        teaId: widget.tea.id,
        date: _date,
        rating: _rating,
        aromas: _selectedAromas.toList(),
        notes: _notesController.text.trim().isEmpty
            ? null
            : _notesController.text.trim(),
      ));
      if (mounted) Navigator.pop(context, true);
    } catch (_) {
      if (mounted) {
        setState(() => _saving = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Errore nel salvataggio, riprova'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;
    final safeBottom = MediaQuery.paddingOf(context).bottom;
    final screenHeight = MediaQuery.sizeOf(context).height;

    return Padding(
      padding: EdgeInsets.only(bottom: bottomInset),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Handle iOS-style
          const SizedBox(height: 8),
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: const Color(0xFFE0E0E0),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Form scrollabile
          ConstrainedBox(
            constraints: BoxConstraints(maxHeight: screenHeight * 0.65),
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Nuova degustazione di ${widget.tea.name}',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _formatDate(_date),
                    style: const TextStyle(fontSize: 13, color: Colors.black45),
                  ),

                  const SizedBox(height: 24),
                  const _SectionLabel('VALUTAZIONE'),
                  const SizedBox(height: 10),
                  Row(
                    children: List.generate(5, (i) {
                      final filled = i < _rating;
                      return GestureDetector(
                        onTap: () => setState(() => _rating = i + 1),
                        child: Padding(
                          padding: const EdgeInsets.only(right: 4),
                          child: Icon(
                            filled
                                ? Icons.star_rounded
                                : Icons.star_outline_rounded,
                            color: filled
                                ? const Color(0xFFBA7517)
                                : Colors.black26,
                            size: 38,
                          ),
                        ),
                      );
                    }),
                  ),

                  const SizedBox(height: 24),
                  const _SectionLabel('AROMI PERCEPITI'),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: widget.tea.aromas.map((aroma) {
                      final selected = _selectedAromas.contains(aroma);
                      return GestureDetector(
                        onTap: () => setState(() {
                          if (selected) {
                            _selectedAromas.remove(aroma);
                          } else {
                            _selectedAromas.add(aroma);
                          }
                        }),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: selected
                                ? AppTheme.primaryGreen
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: selected
                                  ? AppTheme.primaryGreen
                                  : const Color(0xFFCCCCCC),
                            ),
                          ),
                          child: Text(
                            aroma,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color:
                                  selected ? Colors.white : Colors.black54,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),

                  const SizedBox(height: 24),
                  const _SectionLabel('NOTE'),
                  const SizedBox(height: 10),
                  TextField(
                    controller: _notesController,
                    minLines: 3,
                    maxLines: 6,
                    maxLength: 500,
                    decoration: InputDecoration(
                      hintText:
                          'Cosa hai pensato di questa degustazione?',
                      hintStyle: const TextStyle(
                          fontSize: 14, color: Colors.black38),
                      filled: true,
                      fillColor: const Color(0xFFF4F4F2),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.all(14),
                    ),
                  ),

                  const SizedBox(height: 4),
                ],
              ),
            ),
          ),

          // Pulsanti fissi in fondo
          Padding(
            padding:
                EdgeInsets.fromLTRB(20, 8, 20, 16 + safeBottom),
            child: Column(
              children: [
                SizedBox(
                  width: double.infinity,
                  child: TextButton(
                    onPressed:
                        _saving ? null : () => Navigator.pop(context),
                    child: const Text(
                      'Annulla',
                      style:
                          TextStyle(color: Colors.black54, fontSize: 15),
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: _saving ? null : _save,
                    style: FilledButton.styleFrom(
                      backgroundColor: AppTheme.primaryGreen,
                      foregroundColor: Colors.white,
                      padding:
                          const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: _saving
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Text('Salva',
                            style: TextStyle(fontSize: 16)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 10,
        fontWeight: FontWeight.w600,
        color: Colors.black45,
        letterSpacing: 0.8,
      ),
    );
  }
}
