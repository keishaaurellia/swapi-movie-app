class Movie {
  Movie({
    required this.title,
    required this.episodeId,
    required this.openingCrawl,
    required this.director,
    required this.producer,
    required this.releaseDate,
    required this.characters,
    required this.planets,
    required this.starships,
    required this.vehicles,
    required this.species,
    required this.created,
    required this.edited,
    required this.url,
  });

  final String? title;
  final int? episodeId;
  final String? openingCrawl;
  final String? director;
  final String? producer;
  final DateTime? releaseDate;
  final List<String> characters;
  final List<String> planets;
  final List<String> starships;
  final List<String> vehicles;
  final List<String> species;
  final DateTime? created;
  final DateTime? edited;
  final String? url;

  factory Movie.fromJson(Map<String, dynamic> json) {
    return Movie(
      title: json["title"],
      episodeId: json["episode_id"],
      openingCrawl: json["opening_crawl"],
      director: json["director"],
      producer: json["producer"],
      releaseDate: DateTime.tryParse(json["release_date"] ?? ""),
      characters: (json["characters"] as List?)
              ?.map((x) => x.toString())
              .toList() ??
          const [],
      planets: (json["planets"] as List?)
              ?.map((x) => x.toString())
              .toList() ??
          const [],
      starships: (json["starships"] as List?)
              ?.map((x) => x.toString())
              .toList() ??
          const [],
      vehicles: (json["vehicles"] as List?)
              ?.map((x) => x.toString())
              .toList() ??
          const [],
      species: (json["species"] as List?)
              ?.map((x) => x.toString())
              .toList() ??
          const [],
      created: DateTime.tryParse(json["created"] ?? ""),
      edited: DateTime.tryParse(json["edited"] ?? ""),
      url: json["url"],
    );
  }

  int get swapiId {
    final movieUrl = url;
    if (movieUrl != null) {
      final segments =
          Uri.tryParse(movieUrl)?.pathSegments.where((s) => s.isNotEmpty).toList();
      if (segments != null && segments.isNotEmpty) {
        final parsed = int.tryParse(segments.last);
        if (parsed != null) return parsed;
      }
    }
    if (episodeId != null) {
      switch (episodeId) {
        case 4:
          return 1;
        case 5:
          return 2;
        case 6:
          return 3;
        case 1:
          return 4;
        case 2:
          return 5;
        case 3:
          return 6;
      }
    }
    return 1;
  }

  String get formattedReleaseDate {
    final date = releaseDate;
    if (date == null) return '';
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December'
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  String get duration {
    switch (episodeId) {
      case 1:
        return '2h 16m';
      case 2:
        return '2h 22m';
      case 3:
        return '2h 20m';
      case 4:
        return '2h 1m';
      case 5:
        return '2h 4m';
      case 6:
        return '2h 11m';
      default:
        return '2h 15m';
    }
  }

  String get cleanedOpeningCrawl {
    final rawCrawl = openingCrawl;
    if (rawCrawl == null || rawCrawl.isEmpty) return '';
    final normalized = rawCrawl
        .replaceAll('\\r\\n', '\n')
        .replaceAll('\\r', '\n')
        .replaceAll('\\n', '\n')
        .replaceAll('\r\n', '\n')
        .replaceAll('\r', '\n');

    final paragraphs = normalized
        .split(RegExp(r'\n{2,}'))
        .map((p) => p.replaceAll('\n', ' ').replaceAll(RegExp(r'\s+'), ' ').trim())
        .where((p) => p.isNotEmpty);

    return paragraphs.join('\n\n');
  }

  String get posterAsset {
    return Movie.getPosterAsset(
      episodeId: episodeId,
      title: title,
      url: url,
    );
  }

  static String getPosterAsset({
    int? episodeId,
    String? title,
    String? url,
    int? swapiId,
  }) {
    if (episodeId != null) {
      switch (episodeId) {
        case 1:
          return 'assets/images/movies/the phantom menace (1999).webp';
        case 2:
          return 'assets/images/movies/attack of the clones 2002.webp';
        case 3:
          return 'assets/images/movies/Revenge Of The Sith 2005.webp';
        case 4:
          return 'assets/images/movies/A New Hope.webp';
        case 5:
          return 'assets/images/movies/The Empire Strikes Back 1980.webp';
        case 6:
          return 'assets/images/movies/Return Of The Jedi 1983.webp';
      }
    }

    if (title != null) {
      final t = title.toLowerCase();
      if (t.contains('phantom')) return 'assets/images/movies/the phantom menace (1999).webp';
      if (t.contains('clones')) return 'assets/images/movies/attack of the clones 2002.webp';
      if (t.contains('sith')) return 'assets/images/movies/Revenge Of The Sith 2005.webp';
      if (t.contains('hope')) return 'assets/images/movies/A New Hope.webp';
      if (t.contains('empire')) return 'assets/images/movies/The Empire Strikes Back 1980.webp';
      if (t.contains('jedi')) return 'assets/images/movies/Return Of The Jedi 1983.webp';
    }

    int? resolvedId = swapiId;
    if (resolvedId == null && url != null) {
      final segments =
          Uri.tryParse(url)?.pathSegments.where((s) => s.isNotEmpty).toList();
      if (segments != null && segments.isNotEmpty) {
        resolvedId = int.tryParse(segments.last);
      }
    }

    if (resolvedId != null) {
      switch (resolvedId) {
        case 1:
          return 'assets/images/movies/A New Hope.webp';
        case 2:
          return 'assets/images/movies/The Empire Strikes Back 1980.webp';
        case 3:
          return 'assets/images/movies/Return Of The Jedi 1983.webp';
        case 4:
          return 'assets/images/movies/the phantom menace (1999).webp';
        case 5:
          return 'assets/images/movies/attack of the clones 2002.webp';
        case 6:
          return 'assets/images/movies/Revenge Of The Sith 2005.webp';
      }
    }

    return 'assets/images/movies/A New Hope.webp';
  }
}
