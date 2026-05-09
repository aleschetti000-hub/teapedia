class TeaPersonal {
  final String teaId;
  final DateTime firstTastedAt;
  final DateTime lastTastedAt;
  final int tastingCount;
  final double averageRating;
  final bool isFavorite;

  TeaPersonal({
    required this.teaId,
    required this.firstTastedAt,
    required this.lastTastedAt,
    required this.tastingCount,
    required this.averageRating,
    required this.isFavorite,
  });

  factory TeaPersonal.fromMap(Map<String, dynamic> map) {
    return TeaPersonal(
      teaId: map['tea_id'] as String,
      firstTastedAt: DateTime.fromMillisecondsSinceEpoch(map['first_tasted_at'] as int),
      lastTastedAt: DateTime.fromMillisecondsSinceEpoch(map['last_tasted_at'] as int),
      tastingCount: map['tasting_count'] as int,
      averageRating: (map['average_rating'] as num).toDouble(),
      isFavorite: (map['is_favorite'] as int) == 1,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'tea_id': teaId,
      'first_tasted_at': firstTastedAt.millisecondsSinceEpoch,
      'last_tasted_at': lastTastedAt.millisecondsSinceEpoch,
      'tasting_count': tastingCount,
      'average_rating': averageRating,
      'is_favorite': isFavorite ? 1 : 0,
    };
  }
}
