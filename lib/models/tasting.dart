import 'dart:convert';

class Tasting {
  final int? id;
  final String teaId;
  final DateTime date;
  final int rating;
  final List<String> aromas;
  final String? notes;

  Tasting({
    this.id,
    required this.teaId,
    required this.date,
    required this.rating,
    required this.aromas,
    this.notes,
  });

  factory Tasting.fromMap(Map<String, dynamic> map) {
    return Tasting(
      id: map['id'] as int?,
      teaId: map['tea_id'] as String,
      date: DateTime.fromMillisecondsSinceEpoch(map['date'] as int),
      rating: map['rating'] as int,
      aromas: List<String>.from(jsonDecode(map['aromas'] as String)),
      notes: map['notes'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'tea_id': teaId,
      'date': date.millisecondsSinceEpoch,
      'rating': rating,
      'aromas': jsonEncode(aromas),
      'notes': notes,
    };
  }
}
