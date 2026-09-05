class People {
  People({
    required this.name,
    required this.height,
    required this.mass,
    required this.hairColor,
    required this.skinColor,
    required this.eyeColor,
    required this.birthYear,
    required this.gender,
    required this.homeworld,
    required this.films,
    required this.species,
    required this.vehicles,
    required this.starships,
    required this.created,
    required this.edited,
    required this.url,
  });

  final String? name;
  final String? height;
  final String? mass;
  final String? hairColor;
  final String? skinColor;
  final String? eyeColor;
  final String? birthYear;
  final String? gender;
  final String? homeworld;
  final List<String> films;
  final List<String> species;
  final List<String> vehicles;
  final List<String> starships;
  final DateTime? created;
  final DateTime? edited;
  final String? url;

  factory People.fromJson(Map<String, dynamic> json) {
    return People(
      name: json["name"],
      height: json["height"],
      mass: json["mass"],
      hairColor: json["hair_color"],
      skinColor: json["skin_color"],
      eyeColor: json["eye_color"],
      birthYear: json["birth_year"],
      gender: json["gender"],
      homeworld: json["homeworld"],
      films: (json["films"] as List?)?.map((x) => x.toString()).toList() ??
          const [],
      species: (json["species"] as List?)
              ?.map((x) => x.toString())
              .toList() ??
          const [],
      vehicles: (json["vehicles"] as List?)
              ?.map((x) => x.toString())
              .toList() ??
          const [],
      starships: (json["starships"] as List?)
              ?.map((x) => x.toString())
              .toList() ??
          const [],
      created: DateTime.tryParse(json["created"] ?? ""),
      edited: DateTime.tryParse(json["edited"] ?? ""),
      url: json["url"],
    );
  }
}
