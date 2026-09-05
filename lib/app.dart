import 'package:flutter/material.dart';
import 'package:cinemax_app/bloc/all_movie/all_movie_bloc.dart';
import 'package:cinemax_app/bloc/maps/maps_bloc.dart';
import 'package:cinemax_app/bloc/movie/movie_bloc.dart';
import 'package:cinemax_app/screens/home_screen.dart';
import 'package:cinemax_app/screens/movie_screen.dart';
import 'package:cinemax_app/screens/movie_compare_screen.dart';
import 'package:cinemax_app/screens/cinema_map_screen.dart';
import 'package:cinemax_app/widgets/export_widgets.dart';
import './bloc/export.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    final movieProvider = MovieProvider();
    final cinemaProvider = CinemaProvider();
    final reminderProvider = ReminderProvider()..initNotification();
    final bookmarkProvider = BookmarkProvider();

    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) =>
              AllMovieBloc(movieProvider)..add(FetchAllMovie()),
        ),
        BlocProvider(
          create: (context) => MovieBloc(movieProvider),
        ),
        BlocProvider(
          create: (context) => MapsBloc(
            cinemaProvider: cinemaProvider,
            movieProvider: movieProvider,
          ),
        ),
        BlocProvider(
          create: (context) =>
              ReminderBloc(reminderProvider)..add(LoadReminders()),
        ),
        BlocProvider(
          create: (context) =>
              BookmarkBloc(bookmarkProvider)..add(const LoadBookmarks()),
        ),
      ],
      child: const AppView(),
    );
  }
}

class AppView extends StatelessWidget {
  const AppView({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Star Wars Movies',
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        scaffoldBackgroundColor: Colors.white,
        colorScheme: const ColorScheme.light(
          primary: AppColors.primaryYellow,
          onPrimary: AppColors.deepSlate,
          secondary: AppColors.teal,
          surface: Colors.white,
          onSurface: AppColors.deepSlate,
        ),
        iconTheme: const IconThemeData(color: AppColors.iconPrimary),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          elevation: 0,
          scrolledUnderElevation: 0,
          iconTheme: IconThemeData(color: AppColors.deepSlate),
          titleTextStyle: TextStyle(
            color: AppColors.deepSlate,
            fontSize: AppDimens.titleMain,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.0,
          ),
        ),
        textTheme: const TextTheme(
          titleLarge: TextStyle(
            fontSize: AppDimens.titleMain,
            fontWeight: FontWeight.bold,
            color: AppColors.deepSlate,
          ),
          bodyLarge: TextStyle(
            fontSize: AppDimens.textMain,
            color: AppColors.deepSlate,
          ),
          bodyMedium: TextStyle(
            fontSize: AppDimens.textMain,
            color: AppColors.deepSlate,
          ),
          bodySmall: TextStyle(
            fontSize: AppDimens.captionSmall,
            color: AppColors.slate,
          ),
          labelSmall: TextStyle(
            fontSize: AppDimens.captionSmall,
            color: AppColors.slate,
          ),
        ),
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: Colors.white,
          selectedItemColor: AppColors.deepSlate,
          unselectedItemColor: AppColors.lightSlate,
          type: BottomNavigationBarType.fixed,
          elevation: 8,
        ),
      ),
      debugShowCheckedModeBanner: false,
      builder: (context, child) => OfflineBanner(
        child: child ?? const SizedBox(),
      ),
      initialRoute: '/',
      onGenerateRoute: (settings) {
        if (settings.name == '/') {
          return MaterialPageRoute(
            builder: (_) => const HomeScreen(),
            settings: settings,
          );
        }
        if (settings.name == '/compare') {
          final initialId = settings.arguments as int?;
          return MaterialPageRoute(
            builder: (_) => MovieCompareScreen(initialMovieId: initialId),
            settings: settings,
          );
        }
        if (settings.name == '/cinemas' || settings.name == '/maps') {
          return MaterialPageRoute(
            builder: (_) => const CinemaMapScreen(),
            settings: settings,
          );
        }
        final uri = Uri.tryParse(settings.name ?? '');
        if (uri != null &&
            uri.pathSegments.length == 2 &&
            uri.pathSegments[0] == 'films') {
          final id = int.tryParse(uri.pathSegments[1]) ?? 1;
          return MaterialPageRoute(
            builder: (_) => MovieScreen(id: id),
            settings: settings,
          );
        }
        return MaterialPageRoute(
          builder: (_) => const HomeScreen(),
          settings: settings,
        );
      },
    );
  }
}
