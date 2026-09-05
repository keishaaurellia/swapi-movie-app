class MapConfig {
  static const String mapboxAccessToken = String.fromEnvironment(
    'MAPBOX_ACCESS_TOKEN',
  );

  static const String mapboxStyleId = String.fromEnvironment(
    'MAPBOX_STYLE_ID',
    defaultValue: 'outdoors-v12',
  );

  static String get tileUrl {
    if (mapboxAccessToken.isNotEmpty) {
      return 'https://api.mapbox.com/styles/v1/mapbox/$mapboxStyleId/tiles/256/{z}/{x}/{y}?access_token=$mapboxAccessToken';
    }
    return 'https://tile.openstreetmap.org/{z}/{x}/{y}.png';
  }

  static bool get isUsingMapbox => mapboxAccessToken.isNotEmpty;
}

