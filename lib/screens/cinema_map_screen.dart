import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:cinemax_app/bloc/export.dart';
import 'package:cinemax_app/bloc/maps/maps_bloc.dart';
import 'package:cinemax_app/data/config/map_config.dart';
import 'package:cinemax_app/widgets/export_widgets.dart';

class CinemaMapScreen extends StatefulWidget {
  final VoidCallback? onBack;

  const CinemaMapScreen({super.key, this.onBack});

  @override
  State<CinemaMapScreen> createState() => _CinemaMapScreenState();
}

class _CinemaMapScreenState extends State<CinemaMapScreen> {
  final MapController _mapController = MapController();
  late final PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(viewportFraction: 0.9);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (context.read<MapsBloc>().state is! MapsLoaded) {
        context.read<MapsBloc>().add(FetchCurrentLocation());
      }
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    _mapController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final mapsB = context.read<MapsBloc>();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: Semantics(
          button: true,
          label: 'Kembali ke halaman sebelumnya',
          child: Container(
            width: AppDimens.buttonSize,
            height: AppDimens.buttonSize,
            alignment: Alignment.center,
            child: IconButton(
              icon: const Icon(
                Icons.arrow_back,
                size: AppDimens.iconSize,
                color: AppColors.deepSlate,
              ),
              onPressed: () {
                if (widget.onBack != null) {
                  widget.onBack!();
                } else if (Navigator.canPop(context)) {
                  Navigator.pop(context);
                }
              },
            ),
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        title: const Text(
          'Cinemas & Navigation',
          style: TextStyle(
            color: AppColors.deepSlate,
            fontSize: AppDimens.titleMain,
            fontWeight: FontWeight.w900,
            letterSpacing: 1.1,
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: AppColors.surface, height: 1),
        ),
      ),
      body: BlocConsumer<MapsBloc, MapsState>(
        listener: (context, state) {
          if (state is MapsLoaded) {
            final selectedCinema = state.selectedCinema;
            if (selectedCinema != null) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                _mapController.move(
                  LatLng(
                    selectedCinema.latitude,
                    selectedCinema.longitude,
                  ),
                  14,
                );
                final idx = state.cinemas.indexWhere(
                  (c) => c.id == selectedCinema.id,
                );
              if (idx != -1 &&
                  _pageController.hasClients &&
                  _pageController.page?.round() != idx) {
                _pageController.animateToPage(
                  idx,
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                );
              }
            });
          }
        }
      },
      builder: (context, state) {
          if (state is MapsLoading) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(color: AppColors.primaryYellow),
                  SizedBox(height: 12),
                  Text(
                    'Finding nearest cinemas...',
                    style: TextStyle(color: Color(0xFF64748B)),
                  ),
                ],
              ),
            );
          } else if (state is MapsLoaded) {
            final List<Marker> markers = [];

            markers.add(
              Marker(
                point: state.position,
                width: 48,
                height: 48,
                child: Semantics(
                  label: 'Lokasi Anda saat ini',
                  child: Center(
                    child: Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: const Color(0xFF0284C7),
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 3),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x33000000),
                            blurRadius: 6,
                            offset: Offset(0, 2),
                          )
                        ],
                      ),
                      child: const Icon(
                        Icons.my_location,
                        color: Colors.white,
                        size: 22,
                      ),
                    ),
                  ),
                ),
              ),
            );

            for (final cinema in state.cinemas) {
              final isSelected = state.selectedCinema?.id == cinema.id;
              markers.add(
                Marker(
                  point: LatLng(cinema.latitude, cinema.longitude),
                  width: isSelected ? 54 : AppDimens.minTouchTarget,
                  height: isSelected ? 54 : AppDimens.minTouchTarget,
                  child: Semantics(
                    button: true,
                    label: 'Bioskop ${cinema.name}',
                    selected: isSelected,
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () {
                        mapsB.add(SelectCinema(cinema));
                        final idx =
                            state.cinemas.indexWhere((c) => c.id == cinema.id);
                        if (idx != -1 && _pageController.hasClients) {
                          _pageController.animateToPage(
                            idx,
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                          );
                        }
                      },
                      child: Center(
                        child: Container(
                          width: isSelected ? 54 : AppDimens.buttonSize,
                          height: isSelected ? 54 : AppDimens.buttonSize,
                          decoration: BoxDecoration(
                            color: isSelected
                                ? AppColors.primaryYellow
                                : Colors.white,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: isSelected
                                  ? AppColors.deepSlate
                                  : AppColors.slate,
                              width: 2.5,
                            ),
                            boxShadow: const [
                              BoxShadow(
                                color: Color(0x26000000),
                                blurRadius: 6,
                                offset: Offset(0, 2),
                              )
                            ],
                          ),
                          child: Center(
                            child: Text(
                              'XXI',
                              style: TextStyle(
                                color: isSelected
                                    ? const Color(0xFF0F172A)
                                    : AppColors.deepSlate,
                                fontWeight: FontWeight.w900,
                                fontSize: isSelected ? 12 : 10,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }

            return Stack(
              children: [
                FlutterMap(
                  mapController: _mapController,
                  options: MapOptions(
                    initialCenter: state.position,
                    initialZoom: 13,
                  ),
                  children: [
                    TileLayer(
                      urlTemplate: MapConfig.tileUrl,
                      userAgentPackageName: 'com.cinemax.app',
                      maxZoom: 19,
                      panBuffer: 1,
                      keepBuffer: 3,
                    ),
                    if (state.routePoints.isNotEmpty)
                      PolylineLayer(
                        polylines: [
                          Polyline(
                            points: state.routePoints,
                            strokeWidth: 5.0,
                            color: AppColors.blue,
                          ),
                        ],
                      ),
                    MarkerLayer(markers: markers),
                  ],
                ),

                Positioned(
                  right: 12,
                  top: 16,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Semantics(
                        button: true,
                        label: 'Perbesar peta',
                        child: Container(
                          width: AppDimens.buttonSize,
                          height: AppDimens.buttonSize,
                          decoration: BoxDecoration(
                            color: Colors.white.withAlpha(240),
                            shape: BoxShape.circle,
                            boxShadow: const [
                              BoxShadow(
                                color: Color(0x28000000),
                                blurRadius: 6,
                                offset: Offset(0, 2),
                              ),
                            ],
                          ),
                          child: IconButton(
                            padding: EdgeInsets.zero,
                            icon: const Icon(
                              Icons.add,
                              color: AppColors.deepSlate,
                              size: AppDimens.iconSize,
                            ),
                            tooltip: 'Zoom In',
                            onPressed: () {
                              final zoom = _mapController.camera.zoom;
                              _mapController.move(
                                  _mapController.camera.center, zoom + 1);
                            },
                          ),
                        ),
                      ),
                      const SizedBox(height: AppDimens.buttonSpacing),
                      Semantics(
                        button: true,
                        label: 'Perkecil peta',
                        child: Container(
                          width: AppDimens.buttonSize,
                          height: AppDimens.buttonSize,
                          decoration: BoxDecoration(
                            color: Colors.white.withAlpha(240),
                            shape: BoxShape.circle,
                            boxShadow: const [
                              BoxShadow(
                                color: Color(0x28000000),
                                blurRadius: 6,
                                offset: Offset(0, 2),
                              ),
                            ],
                          ),
                          child: IconButton(
                            padding: EdgeInsets.zero,
                            icon: const Icon(
                              Icons.remove,
                              color: AppColors.deepSlate,
                              size: AppDimens.iconSize,
                            ),
                            tooltip: 'Zoom Out',
                            onPressed: () {
                              final zoom = _mapController.camera.zoom;
                              _mapController.move(
                                  _mapController.camera.center, zoom - 1);
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                if (!state.locationPermissionGranted || !state.locationServiceActive)
                  Positioned(
                    top: 16,
                    left: 12,
                    right: 68,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                            color: const Color(0xFFF59E0B), width: 1.5),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x1F000000),
                            blurRadius: 10,
                            offset: Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.location_off_outlined,
                              color: Color(0xFFD97706), size: 24),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  !state.locationPermissionGranted
                                      ? 'Location Permission Required'
                                      : 'Device GPS is Turned Off',
                                  style: const TextStyle(
                                    fontSize: AppDimens.textMain,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF0F172A),
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  !state.locationPermissionGranted
                                      ? 'Enable location permission to detect your current position and find nearby cinemas.'
                                      : 'Turn on device GPS to calculate route and ETA to nearby cinemas.',
                                  style: const TextStyle(
                                    fontSize: AppDimens.captionSmall,
                                    color: Color(0xFF475569),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: AppDimens.buttonSpacing),
                          Semantics(
                            button: true,
                            label: !state.locationPermissionGranted
                                ? 'Izinkan akses lokasi'
                                : 'Aktifkan GPS perangkat',
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primaryYellow,
                                foregroundColor: const Color(0xFF0F172A),
                                minimumSize: const Size(
                                    AppDimens.minTouchTarget,
                                    AppDimens.buttonHeightLarge),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 12),
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              onPressed: () async {
                                if (!state.locationPermissionGranted) {
                                  final perm = await Geolocator.requestPermission();
                                  if (perm == LocationPermission.deniedForever) {
                                    await Geolocator.openAppSettings();
                                  } else {
                                    mapsB.add(FetchCurrentLocation());
                                  }
                                } else {
                                  await Geolocator.openLocationSettings();
                                }
                              },
                              child: Text(
                                !state.locationPermissionGranted ? 'Allow' : 'Turn On',
                                style: const TextStyle(
                                  fontSize: AppDimens.captionSmall,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 16,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (state.cinemas.isNotEmpty)
                        SizedBox(
                          height: 200,
                          child: PageView.builder(
                            controller: _pageController,
                            itemCount: state.cinemas.length,
                            onPageChanged: (index) {
                              final cinema = state.cinemas[index];
                              if (state.selectedCinema?.id != cinema.id) {
                                mapsB.add(SelectCinema(cinema));
                              }
                            },
                            itemBuilder: (context, index) {
                              final cinema = state.cinemas[index];
                              final isSelected =
                                  state.selectedCinema?.id == cinema.id;
                              final reminderState =
                                  context.watch<ReminderBloc>().state;
                              final hasReminder = reminderState is ReminderLoaded &&
                                  reminderState.reminders.any(
                                    (r) =>
                                        r.cinemaName.toLowerCase() ==
                                        cinema.name.toLowerCase(),
                                  );
                              final distKm = isSelected
                                  ? (state.distanceKm ?? cinema.distanceKm)
                                  : cinema.distanceKm;
                              final cinemaDistance = cinema.distanceKm;
                              final durMin = isSelected
                                  ? (state.durationMinutes ??
                                      (distKm != null
                                          ? (distKm / 25 * 60).round().clamp(3, 120)
                                          : null))
                                  : (cinemaDistance != null
                                      ? (cinemaDistance / 25 * 60).round().clamp(3, 120)
                                      : null);

                              return Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 6, vertical: 4),
                                child: Align(
                                  alignment: Alignment.topCenter,
                                  child: CinemaCard(
                                    cinema: cinema,
                                    isSelected: isSelected,
                                    hasActiveReminder: hasReminder,
                                    distanceKm: distKm,
                                    durationMinutes: durMin,
                                    showReminderButton: true,
                                    onTap: () {
                                      if (!isSelected) {
                                        mapsB.add(SelectCinema(cinema));
                                      }
                                      if (_pageController.hasClients &&
                                          _pageController.page?.round() != index) {
                                        _pageController.animateToPage(
                                          index,
                                          duration: const Duration(milliseconds: 300),
                                          curve: Curves.easeInOut,
                                        );
                                      }
                                    },
                                  ),
                                ),
                              );
                            },
                          ),
                        )
                      else
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: AppColors.primaryYellow,
                                width: 1.5,
                              ),
                              boxShadow: const [
                                BoxShadow(
                                  color: Color(0x1F000000),
                                  blurRadius: 16,
                                  offset: Offset(0, 4),
                                )
                              ],
                            ),
                            child: const Row(
                              children: [
                                Icon(Icons.info_outline,
                                    color: AppColors.iconDarkAccent, size: 20),
                                SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    'No cinemas found nearby.',
                                    style: TextStyle(
                                      fontSize: AppDimens.captionSmall,
                                      color: Color(0xFF334155),
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      const SizedBox(height: AppDimens.buttonSpacing),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: SizedBox(
                          width: double.infinity,
                          height: AppDimens.buttonHeightLarge,
                          child: Semantics(
                            button: true,
                            label: 'Pusatkan peta ke lokasi saya',
                            child: OutlinedButton.icon(
                              style: OutlinedButton.styleFrom(
                                backgroundColor: Colors.white,
                                side: const BorderSide(
                                    color: Color(0xFFCBD5E1), width: 1.2),
                                foregroundColor: const Color(0xFF0F172A),
                                minimumSize: const Size.fromHeight(
                                    AppDimens.buttonHeightLarge),
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              onPressed: () async {
                                if (!state.locationPermissionGranted) {
                                  final perm = await Geolocator.requestPermission();
                                  if (perm == LocationPermission.deniedForever) {
                                    await Geolocator.openAppSettings();
                                    return;
                                  }
                                }
                                if (!state.locationServiceActive) {
                                  await Geolocator.openLocationSettings();
                                  return;
                                }
                                mapsB.add(FetchCurrentLocation());
                                _mapController.move(state.position, 14);
                              },
                              icon: const Icon(Icons.my_location,
                                  size: AppDimens.iconSize,
                                  color: AppColors.deepSlate),
                              label: const Text(
                                'Center to My Location',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: AppDimens.textMain),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          } else if (state is MapsError) {
            return Center(
              child: Text(
                state.message,
                style: const TextStyle(
                  color: Color(0xFFEF4444),
                  fontSize: AppDimens.textMain,
                ),
              ),
            );
          }
          return const SizedBox();
        },
      ),
    );
  }
}
