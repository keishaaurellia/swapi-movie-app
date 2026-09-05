import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cinemax_app/bloc/export.dart';
import 'package:cinemax_app/bloc/maps/maps_bloc.dart';
import 'package:cinemax_app/widgets/export_widgets.dart';
import 'package:cinemax_app/screens/cinema_map_screen.dart';
import 'package:cinemax_app/data/config/network_error_helper.dart';
import 'package:cinemax_app/data/config/map_config.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('CinemaProvider returns at least 7 mock cinemas', () async {
    final provider = CinemaProvider();
    final cinemas = await provider.getCinemas();
    expect(cinemas.length, greaterThanOrEqualTo(7));
    expect(cinemas.first.name, isNotEmpty);
    expect(cinemas.first.latitude, isNotNull);
    expect(cinemas.first.longitude, isNotNull);
  });

  test('Reminder model serialization and notificationTime calculation', () {
    final showtime = DateTime(2026, 9, 5, 20, 0);
    final reminder = Reminder(
      id: 'test_1',
      movieId: '1',
      movieTitle: 'A New Hope',
      cinemaName: 'Grand Indonesia XXI',
      scheduledTime: showtime,
      leadTimeMinutes: 30,
    );

    expect(reminder.notificationTime, DateTime(2026, 9, 5, 19, 30));

    final json = reminder.toJson();
    expect(json['leadTimeMinutes'], 30);

    final fromJson = Reminder.fromJson(json);
    expect(fromJson.id, 'test_1');
    expect(fromJson.movieTitle, 'A New Hope');
    expect(fromJson.cinemaName, 'Grand Indonesia XXI');
    expect(fromJson.leadTimeMinutes, 30);
    expect(fromJson.notificationTime, DateTime(2026, 9, 5, 19, 30));
  });

  test('ReminderProvider persists reminders to SharedPreferences and allows cancellation', () async {
    SharedPreferences.setMockInitialValues({});
    final provider = ReminderProvider();

    final showtime = DateTime.now().add(const Duration(hours: 2));
    final reminder = Reminder(
      id: 'rem_101',
      movieId: 'sw_1',
      movieTitle: 'The Empire Strikes Back',
      cinemaName: 'Plaza Senayan XXI',
      scheduledTime: showtime,
      leadTimeMinutes: 15,
    );

    await provider.addReminder(reminder);

    final reminders = await provider.getReminders();
    expect(reminders.length, 1);
    expect(reminders.first.id, 'rem_101');
    expect(reminders.first.movieTitle, 'The Empire Strikes Back');
    expect(reminders.first.leadTimeMinutes, 15);

    await provider.deleteReminder('rem_101');
    final afterCancel = await provider.getReminders();
    expect(afterCancel.isEmpty, isTrue);
  });

  test('BookmarkProvider persists and toggles favorites', () async {
    SharedPreferences.setMockInitialValues({'user_favorite_movies': <String>['1']});
    final provider = BookmarkProvider();
    expect(await provider.isFavorite(1), isTrue);
    expect(await provider.isFavorite(2), isFalse);

    final added = await provider.toggleFavorite(2);
    expect(added, isTrue);
    expect(await provider.isFavorite(2), isTrue);

    final removed = await provider.toggleFavorite(1);
    expect(removed, isFalse);
    expect(await provider.isFavorite(1), isFalse);
  });

  test('MovieProvider cache management works correctly', () {
    MovieProvider.clearEntityCache();
    expect(MovieProvider.cachedEntitiesCount, 0);
  });

  test('Reminder real-time trigger time validation logic', () {
    final now = DateTime.now();

    final targetTimeFuture = now.add(const Duration(minutes: 15));
    final triggerTimePast = targetTimeFuture.subtract(const Duration(minutes: 30));
    expect(targetTimeFuture.isAfter(now), isTrue);
    expect(triggerTimePast.isAfter(now), isFalse);

    final targetTimeValid = now.add(const Duration(hours: 3));
    final triggerTimeValid = targetTimeValid.subtract(const Duration(minutes: 60));
    expect(targetTimeValid.isAfter(now), isTrue);
    expect(triggerTimeValid.isAfter(now), isTrue);

    final testMode5Sec = now.add(const Duration(seconds: 5));
    final testTrigger5Sec = testMode5Sec.subtract(Duration.zero);
    expect(testTrigger5Sec.isAfter(now), isTrue);
  });

  test('Movie cleanedOpeningCrawl removes single \\r\\n and formats paragraphs cleanly', () {
    const rawCrawl = 'It is a period of civil war.\r\nRebel spaceships, striking\r\nfrom a hidden base.\r\n\r\nDuring the battle, Rebel\r\nspies managed to steal secret plans.';
    final movie = Movie(
      title: 'A New Hope',
      episodeId: 4,
      openingCrawl: rawCrawl,
      director: 'George Lucas',
      producer: 'Gary Kurtz',
      releaseDate: DateTime(1977, 5, 25),
      characters: [],
      planets: [],
      starships: [],
      vehicles: [],
      species: [],
      created: null,
      edited: null,
      url: 'https://swapi.dev/api/films/1/',
    );

    const expected = 'It is a period of civil war. Rebel spaceships, striking from a hidden base.\n\nDuring the battle, Rebel spies managed to steal secret plans.';
    expect(movie.cleanedOpeningCrawl, expected);
  });

  testWidgets('ScheduleDialog shows real-time clock when opened', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) {
              return ElevatedButton(
                onPressed: () => ScheduleDialog.show(context),
                child: const Text('Open Reminder'),
              );
            },
          ),
        ),
      ),
    );

    await tester.tap(find.text('Open Reminder'));
    await tester.pumpAndSettle();

    expect(find.text('Set Movie Reminder'), findsOneWidget);
    expect(find.text('On time'), findsOneWidget);
  });

  testWidgets('TicketCard shows Completed badge when reminder time is past', (tester) async {
    final pastReminder = Reminder(
      id: 'past_1',
      movieId: '1',
      movieTitle: 'A New Hope',
      cinemaName: 'Grand Indonesia XXI',
      scheduledTime: DateTime.now().subtract(const Duration(hours: 1)),
      leadTimeMinutes: 0,
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: TicketCard(
            reminder: pastReminder,
            onDelete: () {},
          ),
        ),
      ),
    );

    expect(find.text('Completed'), findsOneWidget);
    expect(find.byIcon(Icons.check_circle), findsWidgets);
  });

  test('Global text sizes standard (teksUtama 16dp, judulUtama 20dp, keteranganKecil 12dp)', () {
    expect(AppDimens.judulUtama, 20.0);
    expect(AppDimens.titleMain, 20.0);
    expect(AppDimens.fontTitleMain, 20.0);

    expect(AppDimens.teksUtama, 16.0);
    expect(AppDimens.textMain, 16.0);
    expect(AppDimens.fontTextMain, 16.0);

    expect(AppDimens.keteranganKecil, 12.0);
    expect(AppDimens.captionSmall, 12.0);
    expect(AppDimens.fontCaptionSmall, 12.0);

    expect(AppTypography.judulUtama.fontSize, 20.0);
    expect(AppTypography.titleMain.fontSize, 20.0);

    expect(AppTypography.teksUtama.fontSize, 16.0);
    expect(AppTypography.textMain.fontSize, 16.0);

    expect(AppTypography.keteranganKecil.fontSize, 12.0);
    expect(AppTypography.captionSmall.fontSize, 12.0);
  });

  testWidgets('CinemaCard displays cinema details, distance, ETA, and reminder button', (tester) async {
    const cinema = Cinema(
      id: 'cinema_01',
      name: 'Cinema XXI City Center',
      address: '3rd Floor Mall, 1 Central Protocol Ave.',
      latitude: -6.2250,
      longitude: 106.8800,
      phone: '(021) 500121',
      totalTheaters: 8,
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: CinemaCard(
            cinema: cinema,
            distanceKm: 1.9,
            durationMinutes: 6,
            isSelected: true,
            onTap: () {},
          ),
        ),
      ),
    );

    expect(find.text('CINEMA XXI'), findsOneWidget);
    expect(find.text('Cinema XXI City Center'), findsOneWidget);
    expect(find.text('3rd Floor Mall, 1 Central Protocol Ave.'), findsOneWidget);
    expect(find.text('1.9 km'), findsOneWidget);
    expect(find.text('6 mins drive'), findsOneWidget);
    expect(find.text('Set Reminder at this Cinema'), findsOneWidget);
  });

  testWidgets('Horizontal PageView of CinemaCards allows horizontal scrolling', (tester) async {
    final cinemas = [
      const Cinema(
        id: 'c1',
        name: 'Cinema XXI City Center',
        address: 'Mall 1',
        latitude: -6.2,
        longitude: 106.8,
        phone: '(021) 500121',
        totalTheaters: 8,
      ),
      const Cinema(
        id: 'c2',
        name: 'Cinema XXI Plaza Mall',
        address: 'Mall 2',
        latitude: -6.3,
        longitude: 106.9,
        phone: '(021) 500122',
        totalTheaters: 6,
      ),
    ];

    final controller = PageController();

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SizedBox(
            height: 200,
            child: PageView.builder(
              controller: controller,
              itemCount: cinemas.length,
              itemBuilder: (context, index) {
                return CinemaCard(
                  cinema: cinemas[index],
                  isSelected: index == 0,
                  onTap: () {},
                );
              },
            ),
          ),
        ),
      ),
    );

    expect(find.text('Cinema XXI City Center'), findsOneWidget);
    await tester.fling(find.byType(PageView), const Offset(-600, 0), 1000);
    await tester.pumpAndSettle();
    expect(find.text('Cinema XXI Plaza Mall'), findsOneWidget);
  });

  test('NetworkErrorHelper maps network and socket errors accurately', () {
    final infoSocket = NetworkErrorHelper.parse('SocketException: Failed host lookup');
    expect(infoSocket.kind, NetworkErrorKind.noInternet);
    expect(infoSocket.title, 'Koneksi Terputus');
    expect(infoSocket.icon, Icons.wifi_off_rounded);

    final infoGeneric = NetworkErrorHelper.parse('Some random exception');
    expect(infoGeneric.kind, NetworkErrorKind.unknown);
    expect(infoGeneric.title, 'Terjadi Kendala');
  });

  testWidgets('AppErrorView renders properly and triggers retry callback', (tester) async {
    bool retried = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: AppErrorView(
            error: 'SocketException: Network unreachable',
            onRetry: () {
              retried = true;
            },
          ),
        ),
      ),
    );

    expect(find.text('Koneksi Terputus'), findsOneWidget);
    expect(find.text('Coba Lagi'), findsOneWidget);
    expect(find.byIcon(Icons.wifi_off_rounded), findsOneWidget);

    await tester.tap(find.text('Coba Lagi'));
    await tester.pump();
    expect(retried, isTrue);
  });

  test('MapConfig tileUrl falls back to OpenStreetMap when token is empty or formats Mapbox correctly', () {
    expect(MapConfig.mapboxStyleId, isNotEmpty);
    if (MapConfig.mapboxAccessToken.isEmpty) {
      expect(MapConfig.isUsingMapbox, isFalse);
      expect(MapConfig.tileUrl, 'https://tile.openstreetmap.org/{z}/{x}/{y}.png');
    } else {
      expect(MapConfig.isUsingMapbox, isTrue);
      expect(MapConfig.tileUrl, contains('mapbox.com'));
      expect(MapConfig.tileUrl, contains(MapConfig.mapboxAccessToken));
    }
  });

  testWidgets('AppSearchBar molecule displays search icon, reveals clear button on typing, and clears input', (tester) async {
    String changedQuery = '';
    bool cleared = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: AppSearchBar(
            hintText: 'Search title...',
            onChanged: (val) => changedQuery = val,
            onClear: () => cleared = true,
          ),
        ),
      ),
    );

    expect(find.byIcon(Icons.search), findsOneWidget);
    expect(find.text('Search title...'), findsOneWidget);
    expect(find.byIcon(Icons.clear), findsNothing);

    await tester.enterText(find.byType(TextField), 'Empire');
    await tester.pump();

    expect(find.byIcon(Icons.clear), findsOneWidget);
    expect(changedQuery, 'Empire');

    await tester.tap(find.byIcon(Icons.clear));
    await tester.pump();

    expect(find.text('Empire'), findsNothing);
    expect(find.byIcon(Icons.clear), findsNothing);
    expect(cleared, isTrue);
    expect(changedQuery, '');
  });

  testWidgets('CinemaMapScreen renders back button and styled Cinemas & Navigation title', (tester) async {
    final cinemaProvider = CinemaProvider();
    final movieProvider = MovieProvider();
    final mapsBloc = MapsBloc(
      cinemaProvider: cinemaProvider,
      movieProvider: movieProvider,
    );

    bool backPressed = false;
    await tester.pumpWidget(
      BlocProvider<MapsBloc>.value(
        value: mapsBloc,
        child: MaterialApp(
          home: CinemaMapScreen(
            onBack: () => backPressed = true,
          ),
        ),
      ),
    );

    expect(find.text('Cinemas & Navigation'), findsOneWidget);
    expect(find.byIcon(Icons.arrow_back), findsOneWidget);
    expect(
      find.descendant(
        of: find.byType(AppBar),
        matching: find.byIcon(Icons.refresh),
      ),
      findsNothing,
    );

    await tester.tap(find.byIcon(Icons.arrow_back));
    await tester.pump();

    expect(backPressed, isTrue);
  });
}




