part of 'maps_bloc.dart';

abstract class MapsState extends Equatable {
  const MapsState();

  @override
  List<Object?> get props => [];
}

class MapsInitial extends MapsState {}

class MapsLoading extends MapsState {}

class MapsLoaded extends MapsState {
  final LatLng position;
  final List<Cinema> cinemas;
  final Cinema? selectedCinema;
  final List<LatLng> routePoints;
  final double? distanceKm;
  final int? durationMinutes;
  final bool? hasLocationPermission;
  final bool? isLocationServiceEnabled;

  const MapsLoaded({
    required this.position,
    required this.cinemas,
    this.selectedCinema,
    this.routePoints = const [],
    this.distanceKm,
    this.durationMinutes,
    this.hasLocationPermission = true,
    this.isLocationServiceEnabled = true,
  });

  bool get locationPermissionGranted => hasLocationPermission ?? true;
  bool get locationServiceActive => isLocationServiceEnabled ?? true;

  MapsLoaded copyWith({
    LatLng? position,
    List<Cinema>? cinemas,
    Cinema? selectedCinema,
    List<LatLng>? routePoints,
    double? distanceKm,
    int? durationMinutes,
    bool? hasLocationPermission,
    bool? isLocationServiceEnabled,
  }) {
    return MapsLoaded(
      position: position ?? this.position,
      cinemas: cinemas ?? this.cinemas,
      selectedCinema: selectedCinema ?? this.selectedCinema,
      routePoints: routePoints ?? this.routePoints,
      distanceKm: distanceKm ?? this.distanceKm,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      hasLocationPermission:
          hasLocationPermission ?? this.hasLocationPermission,
      isLocationServiceEnabled:
          isLocationServiceEnabled ?? this.isLocationServiceEnabled,
    );
  }

  @override
  List<Object?> get props => [
        position,
        cinemas,
        selectedCinema,
        routePoints,
        distanceKm,
        durationMinutes,
        hasLocationPermission ?? true,
        isLocationServiceEnabled ?? true,
      ];
}

class MapsError extends MapsState {
  final String message;
  const MapsError(this.message);

  @override
  List<Object?> get props => [message];
}
