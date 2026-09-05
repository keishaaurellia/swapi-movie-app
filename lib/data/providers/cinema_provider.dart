import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import '../models/cinema.dart';

class CinemaProvider {
  Future<List<Cinema>> getCinemas({LatLng? userLocation}) async {
    await Future.delayed(const Duration(milliseconds: 50));

    List<Cinema> cinemas;

    final bool isNearJakarta = userLocation != null &&
        (Geolocator.distanceBetween(
                userLocation.latitude,
                userLocation.longitude,
                -6.2250,
                106.8800) <
            50000);

    if (userLocation != null && !isNearJakarta) {
      final double lat = userLocation.latitude;
      final double lng = userLocation.longitude;

      cinemas = [
        Cinema(
          id: 'cinema_01',
          name: 'Cinema XXI City Center',
          address: '3rd Floor Mall, 1 Central Protocol Ave.',
          latitude: lat + 0.010,
          longitude: lng + 0.008,
          phone: '(021) 500121',
          totalTheaters: 8,
        ),
        Cinema(
          id: 'cinema_02',
          name: 'Cinema XXI Plaza Mall',
          address: '4th Floor Plaza, 12 Youth Blvd.',
          latitude: lat - 0.012,
          longitude: lng + 0.011,
          phone: '(021) 500122',
          totalTheaters: 6,
        ),
        Cinema(
          id: 'cinema_03',
          name: 'Cinema XXI Grand Square',
          address: 'Level 2 Square Mall, 5 Civic Center Rd.',
          latitude: lat + 0.016,
          longitude: lng - 0.014,
          phone: '(021) 500123',
          totalTheaters: 7,
        ),
        Cinema(
          id: 'cinema_04',
          name: 'Cinema XXI Town Park',
          address: 'LG Level Park Mall, 88 Grand Ave.',
          latitude: lat - 0.018,
          longitude: lng - 0.015,
          phone: '(021) 500124',
          totalTheaters: 10,
        ),
        Cinema(
          id: 'cinema_05',
          name: 'Cinema XXI Metropolitan',
          address: 'Level 3 Metropolis Mall, 45 Metro Blvd.',
          latitude: lat + 0.024,
          longitude: lng + 0.019,
          phone: '(021) 500125',
          totalTheaters: 5,
        ),
        Cinema(
          id: 'cinema_06',
          name: 'Cinema XXI Grand Avenue',
          address: 'Level 2 Avenue Walk, 27 Heritage Way',
          latitude: lat - 0.022,
          longitude: lng + 0.018,
          phone: '(021) 500126',
          totalTheaters: 8,
        ),
        Cinema(
          id: 'cinema_07',
          name: 'Cinema XXI Prime Hills',
          address: 'Level 3 Hills Mall, 99 Boulevard St.',
          latitude: lat + 0.028,
          longitude: lng - 0.020,
          phone: '(021) 500127',
          totalTheaters: 6,
        ),
      ];
    } else {
      cinemas = const [
        Cinema(
          id: 'cinema_bassura',
          name: 'Bassura XXI (East Jakarta)',
          address: 'Level 2 Mall@Bassura, 1A Basuki Rahmat St., East Jakarta',
          latitude: -6.2238,
          longitude: 106.8732,
          phone: '(021) 22807221',
          totalTheaters: 6,
        ),
        Cinema(
          id: 'cinema_cipinang',
          name: 'Cipinang XXI (East Jakarta)',
          address: 'Level 3 Cipinang Indah Mall, 88 Kalimalang Rd., East Jakarta',
          latitude: -6.2415,
          longitude: 106.8920,
          phone: '(021) 29486221',
          totalTheaters: 5,
        ),
        Cinema(
          id: 'cinema_pgc',
          name: 'PGC XXI (East Jakarta)',
          address: 'Level 7 Cililitan Wholesale Center, 76 Sutoyo St., East Jakarta',
          latitude: -6.2625,
          longitude: 106.8660,
          phone: '(021) 80878221',
          totalTheaters: 6,
        ),
        Cinema(
          id: 'cinema_buaran',
          name: 'Buaran XXI (East Jakarta)',
          address: 'Level 3 Buaran Plaza, 1 Raden Inten II St., East Jakarta',
          latitude: -6.2241,
          longitude: 106.9188,
          phone: '(021) 86609221',
          totalTheaters: 5,
        ),
        Cinema(
          id: 'cinema_kokas',
          name: 'Kota Kasablanka XXI',
          address: 'Level 3 Kota Kasablanka Mall, 88 Casablanca Blvd., South Jakarta',
          latitude: -6.2240,
          longitude: 106.8431,
          phone: '(021) 29465221',
          totalTheaters: 9,
        ),
        Cinema(
          id: 'cinema_metropole',
          name: 'Metropole XXI',
          address: 'Metropole Building, 21 Pegangsaan Timur St., Central Jakarta',
          latitude: -6.1998,
          longitude: 106.8437,
          phone: '(021) 31925345',
          totalTheaters: 6,
        ),
        Cinema(
          id: 'cinema_gi',
          name: 'Grand Indonesia XXI',
          address: 'Level 8 Grand Indonesia Mall, 1 M.H. Thamrin St., Central Jakarta',
          latitude: -6.1953,
          longitude: 106.8208,
          phone: '(021) 23580021',
          totalTheaters: 10,
        ),
      ];
    }

    return cinemas;
  }
}
