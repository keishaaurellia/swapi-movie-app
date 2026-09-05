import 'package:equatable/equatable.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:cinemax_app/bloc/export.dart';

part 'maps_event.dart';
part 'maps_state.dart';

class MapsBloc extends Bloc<MapsEvent, MapsState> {
  final CinemaProvider cinemaProvider;
  final MovieProvider movieProvider;

  MapsBloc({
    required this.cinemaProvider,
    required this.movieProvider,
  }) : super(MapsInitial()) {
    on<FetchCurrentLocation>((event, emit) async {
      final currentLoaded = state is MapsLoaded ? (state as MapsLoaded) : null;
      if (currentLoaded == null) {
        emit(MapsLoading());
      }

      try {
        LatLng userPos = currentLoaded?.position ?? const LatLng(-6.2250, 106.8800);
        bool hasPermission = currentLoaded?.hasLocationPermission ?? false;
        bool isServiceEnabled = currentLoaded?.isLocationServiceEnabled ?? false;

        try {
          isServiceEnabled = await Geolocator.isLocationServiceEnabled();
          LocationPermission permission = await Geolocator.checkPermission();

          if (permission == LocationPermission.denied) {
            permission = await Geolocator.requestPermission();
          }

          if (permission == LocationPermission.always ||
              permission == LocationPermission.whileInUse) {
            hasPermission = true;

            final lastPosition = await Geolocator.getLastKnownPosition();
            if (lastPosition != null) {
              userPos = LatLng(lastPosition.latitude, lastPosition.longitude);
            }

            if (isServiceEnabled) {
              try {
                final position = await Geolocator.getCurrentPosition(
                  desiredAccuracy: LocationAccuracy.medium,
                  timeLimit: const Duration(seconds: 3),
                );
                userPos = LatLng(position.latitude, position.longitude);
              } catch (_) {}
            }
          } else {
            hasPermission = false;
          }
        } catch (_) {}

        final rawCinemas = await cinemaProvider.getCinemas(userLocation: userPos);

        final List<Cinema> sortedCinemas = rawCinemas.map((c) {
          final distMeters = Geolocator.distanceBetween(
            userPos.latitude,
            userPos.longitude,
            c.latitude,
            c.longitude,
          );
          final distKm = double.parse((distMeters / 1000).toStringAsFixed(1));
          return c.copyWith(distanceKm: distKm);
        }).toList();

        sortedCinemas.sort((a, b) => (a.distanceKm ?? 0).compareTo(b.distanceKm ?? 0));

        final nearest = currentLoaded?.selectedCinema ?? sortedCinemas.first;
        final destination = LatLng(nearest.latitude, nearest.longitude);

        final d = nearest.distanceKm ?? 1.5;
        final m = (d / 25 * 60).round().clamp(3, 120);

        emit(MapsLoaded(
          position: userPos,
          cinemas: sortedCinemas,
          selectedCinema: nearest,
          routePoints: currentLoaded != null && currentLoaded.selectedCinema?.id == nearest.id
              ? currentLoaded.routePoints
              : [userPos, destination],
          distanceKm: d,
          durationMinutes: m,
          hasLocationPermission: hasPermission,
          isLocationServiceEnabled: isServiceEnabled,
        ));

        try {
          final routeInfo = await movieProvider.getRoute(userPos, destination);
          if (state is MapsLoaded) {
            final current = state as MapsLoaded;
            if (current.selectedCinema?.id == nearest.id) {
              emit(current.copyWith(
                routePoints: routeInfo.coordinates,
                distanceKm: routeInfo.distanceKm,
                durationMinutes: routeInfo.durationMinutes,
              ));
            }
          }
        } catch (_) {}
      } catch (e) {
        if (state is! MapsLoaded) {
          emit(MapsError(e.toString()));
        }
      }
    });

    on<SelectCinema>((event, emit) async {
      if (state is MapsLoaded) {
        final current = state as MapsLoaded;
        final destination =
            LatLng(event.cinema.latitude, event.cinema.longitude);

        eventBus.fire(CinemaSelectedEvent(event.cinema));

        final d = event.cinema.distanceKm ?? 3.0;
        final m = (d / 25 * 60).round().clamp(3, 120);

        emit(current.copyWith(
          selectedCinema: event.cinema,
          routePoints: [current.position, destination],
          distanceKm: d,
          durationMinutes: m,
        ));

        try {
          final routeInfo =
              await movieProvider.getRoute(current.position, destination);
          if (state is MapsLoaded &&
              (state as MapsLoaded).selectedCinema?.id == event.cinema.id) {
            emit((state as MapsLoaded).copyWith(
              routePoints: routeInfo.coordinates,
              distanceKm: routeInfo.distanceKm,
              durationMinutes: routeInfo.durationMinutes,
            ));
          }
        } catch (_) {}
      }
    });
  }
}
