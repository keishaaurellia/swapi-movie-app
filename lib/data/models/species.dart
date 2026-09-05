class Species {
  Species({
    required this.name,
    required this.classification,
    required this.designation,
    required this.averageHeight,
    required this.skinColors,
    required this.hairColors,
    required this.eyeColors,
    required this.averageLifespan,
    required this.homeworld,
    required this.language,
    required this.people,
    required this.films,
    required this.created,
    required this.edited,
    required this.url,
  });

  final String? name;
  final String? classification;
  final String? designation;
  final String? averageHeight;
  final String? skinColors;
  final String? hairColors;
  final String? eyeColors;
  final String? averageLifespan;
  final String? homeworld;
  final String? language;
  final List<String> people;
  final List<String> films;
  final DateTime? created;
  final DateTime? edited;
  final String? url;

  factory Species.fromJson(Map<String, dynamic> json) {
    return Species(
      name: json["name"],
      classification: json["classification"],
      designation: json["designation"],
      averageHeight: json["average_height"],
      skinColors: json["skin_colors"],
      hairColors: json["hair_colors"],
      eyeColors: json["eye_colors"],
      averageLifespan: json["average_lifespan"],
      homeworld: json["homeworld"],
      language: json["language"],
      people: (json["people"] as List?)?.map((x) => x.toString()).toList() ??
          const [],
      films: (json["films"] as List?)?.map((x) => x.toString()).toList() ??
          const [],
      created: DateTime.tryParse(json["created"] ?? ""),
      edited: DateTime.tryParse(json["edited"] ?? ""),
      url: json["url"],
    );
  }
}
