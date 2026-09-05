import 'dart:math' as math;
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:latlong2/latlong.dart';
import '../models/movie.dart';
import '../models/people.dart';
import '../models/planets.dart';
import '../models/species.dart';
import '../models/starships.dart';
import '../models/vehicles.dart';
import '../config/map_config.dart';

List<Movie> _parseMovieList(List<dynamic> data) =>
    data.map((e) => Movie.fromJson(e as Map<String, dynamic>)).toList();

List<LatLng> _parseRouteCoordinates(List<dynamic> coords) =>
    coords
        .map((point) => LatLng(
              (point[1] as num).toDouble(),
              (point[0] as num).toDouble(),
            ))
        .toList();

class RouteInfo {
  final List<LatLng> coordinates;
  final double distanceKm;
  final int durationMinutes;

  const RouteInfo({
    required this.coordinates,
    required this.distanceKm,
    required this.durationMinutes,
  });
}

class MovieProvider {
  static final Map<String, dynamic> _entityCache = <String, dynamic>{};

  static int get cachedEntitiesCount => _entityCache.length;
  static void clearEntityCache() => _entityCache.clear();

  final dio = Dio(BaseOptions(
    baseUrl: 'https://swapi.dev/api',
    connectTimeout: const Duration(seconds: 15),
    receiveTimeout: const Duration(seconds: 15),
  ));

  Future<List<Movie>> getAllMovie() async {
    final response = await dio.get('/films');
    final List<dynamic> results = response.data['results'] as List<dynamic>;
    return compute(_parseMovieList, results);
  }

  Future<Movie> getMovieById(int id) async {
    final response = await dio.get('/films/$id');
    return Movie.fromJson(response.data as Map<String, dynamic>);
  }

  Future<List<People>> characters(List<String> urls) async {
    final results = await Future.wait(
      urls.map((url) async {
        if (_entityCache.containsKey(url) && _entityCache[url] is People) {
          return _entityCache[url] as People;
        }
        try {
          final response = await dio.get(url);
          if (response.data is Map<String, dynamic>) {
            final item = People.fromJson(response.data as Map<String, dynamic>);
            _entityCache[url] = item;
            return item;
          }
          return null;
        } catch (_) {
          return null;
        }
      }),
    );
    return results.whereType<People>().toList();
  }

  Future<List<Planets>> planets(List<String> urls) async {
    final results = await Future.wait(
      urls.map((url) async {
        if (_entityCache.containsKey(url) && _entityCache[url] is Planets) {
          return _entityCache[url] as Planets;
        }
        try {
          final response = await dio.get(url);
          if (response.data is Map<String, dynamic>) {
            final item = Planets.fromJson(response.data as Map<String, dynamic>);
            _entityCache[url] = item;
            return item;
          }
          return null;
        } catch (_) {
          return null;
        }
      }),
    );
    return results.whereType<Planets>().toList();
  }

  Future<List<Starships>> starships(List<String> urls) async {
    final results = await Future.wait(
      urls.map((url) async {
        if (_entityCache.containsKey(url) && _entityCache[url] is Starships) {
          return _entityCache[url] as Starships;
        }
        try {
          final response = await dio.get(url);
          if (response.data is Map<String, dynamic>) {
            final item =
                Starships.fromJson(response.data as Map<String, dynamic>);
            _entityCache[url] = item;
            return item;
          }
          return null;
        } catch (_) {
          return null;
        }
      }),
    );
    return results.whereType<Starships>().toList();
  }

  Future<List<Vehicles>> vehicles(List<String> urls) async {
    final results = await Future.wait(
      urls.map((url) async {
        if (_entityCache.containsKey(url) && _entityCache[url] is Vehicles) {
          return _entityCache[url] as Vehicles;
        }
        try {
          final response = await dio.get(url);
          if (response.data is Map<String, dynamic>) {
            final item =
                Vehicles.fromJson(response.data as Map<String, dynamic>);
            _entityCache[url] = item;
            return item;
          }
          return null;
        } catch (_) {
          return null;
        }
      }),
    );
    return results.whereType<Vehicles>().toList();
  }

  Future<List<Species>> species(List<String> urls) async {
    final results = await Future.wait(
      urls.map((url) async {
        if (_entityCache.containsKey(url) && _entityCache[url] is Species) {
          return _entityCache[url] as Species;
        }
        try {
          final response = await dio.get(url);
          if (response.data is Map<String, dynamic>) {
            final item =
                Species.fromJson(response.data as Map<String, dynamic>);
            _entityCache[url] = item;
            return item;
          }
          return null;
        } catch (_) {
          return null;
        }
      }),
    );
    return results.whereType<Species>().toList();
  }

  Future<RouteInfo> getRoute(LatLng origin, LatLng destination) async {
    const String token = MapConfig.mapboxAccessToken;
    if (token.isNotEmpty) {
      final String url =
          'https://api.mapbox.com/directions/v5/mapbox/driving/${origin.longitude},${origin.latitude};${destination.longitude},${destination.latitude}?geometries=geojson&access_token=$token';

      try {
        final response = await dio.get(url);
        final json = response.data;
        if (json['routes'] != null && (json['routes'] as List).isNotEmpty) {
          final primaryRoute = json['routes'][0];
          final routeCoords = primaryRoute['geometry']['coordinates'] as List;
          final double distanceMeters =
              (primaryRoute['distance'] as num).toDouble();
          final double durationSeconds =
              (primaryRoute['duration'] as num).toDouble();

          final coordinates =
              await compute(_parseRouteCoordinates, routeCoords);

          return RouteInfo(
            coordinates: coordinates,
            distanceKm: double.parse((distanceMeters / 1000).toStringAsFixed(1)),
            durationMinutes: (durationSeconds / 60).round(),
          );
        }
      } catch (_) {}
    }

    final double dist = _calculateDistance(origin, destination);
    final int minutes = (dist / 30 * 60).round().clamp(5, 300);
    return RouteInfo(
      coordinates: [origin, destination],
      distanceKm: double.parse(dist.toStringAsFixed(1)),
      durationMinutes: minutes,
    );
  }

  double _calculateDistance(LatLng p1, LatLng p2) {
    const double r = 6371.0;
    final double dLat = _deg2rad(p2.latitude - p1.latitude);
    final double dLon = _deg2rad(p2.longitude - p1.longitude);
    final double a = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(_deg2rad(p1.latitude)) *
            math.cos(_deg2rad(p2.latitude)) *
            math.sin(dLon / 2) *
            math.sin(dLon / 2);
    final double c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
    return r * c;
  }

  double _deg2rad(double deg) => deg * (math.pi / 180.0);
}
