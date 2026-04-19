class Tea {
  final String id;
  final String name;
  final String? originalName;
  final String category; // te_verde, te_nero, oolong, tisana
  final String countryOfOrigin;
  final String region;
  final String caffeine; // assente, bassa, media, alta
  final List<int> temperatureC; // [min, max]
  final List<int> infusionSec; // [min, max]
  final List<String> aromas;
  final String history;
  final String preparation;
  final List<String> funFacts;

  Tea({
    required this.id,
    required this.name,
    this.originalName,
    required this.category,
    required this.countryOfOrigin,
    required this.region,
    required this.caffeine,
    required this.temperatureC,
    required this.infusionSec,
    required this.aromas,
    required this.history,
    required this.preparation,
    required this.funFacts,
  });

  factory Tea.fromJson(Map<String, dynamic> json) {
    return Tea(
      id: json['id'],
      name: json['name'],
      originalName: json['originalName'],
      category: json['category'],
      countryOfOrigin: json['countryOfOrigin'],
      region: json['region'],
      caffeine: json['caffeine'],
      temperatureC: List<int>.from(json['temperatureC']),
      infusionSec: List<int>.from(json['infusionSec']),
      aromas: List<String>.from(json['aromas']),
      history: json['history'],
      preparation: json['preparation'],
      funFacts: List<String>.from(json['funFacts']),
    );
  }
}
