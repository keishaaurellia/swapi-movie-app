import 'package:shared_preferences/shared_preferences.dart';

class BookmarkProvider {
  static const String _favoritesKey = 'user_favorite_movies';
  static final Set<int> _cache = <int>{};
  static bool _initialized = false;

  Future<List<int>> getFavorites() async {
    if (!_initialized) {
      try {
        final prefs = await SharedPreferences.getInstance();
        final List<String> idStrings = prefs.getStringList(_favoritesKey) ?? [];
        for (final s in idStrings) {
          final id = int.tryParse(s);
          if (id != null) _cache.add(id);
        }
        _initialized = true;
      } catch (_) {
        _initialized = true;
      }
    }
    return _cache.toList();
  }

  Future<bool> toggleFavorite(int movieId) async {
    if (!_initialized) {
      await getFavorites();
    }

    final bool isFav;
    if (_cache.contains(movieId)) {
      _cache.remove(movieId);
      isFav = false;
    } else {
      _cache.add(movieId);
      isFav = true;
    }

    try {
      final prefs = await SharedPreferences.getInstance();
      final List<String> list = _cache.map((e) => e.toString()).toList();
      await prefs.setStringList(_favoritesKey, list);
    } catch (_) {}

    return isFav;
  }

  Future<bool> isFavorite(int movieId) async {
    if (!_initialized) {
      await getFavorites();
    }
    return _cache.contains(movieId);
  }
}
