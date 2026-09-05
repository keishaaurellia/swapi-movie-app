import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cinemax_app/bloc/all_movie/all_movie_bloc.dart';
import 'package:cinemax_app/bloc/maps/maps_bloc.dart';
import 'package:cinemax_app/bloc/export.dart';
import 'package:cinemax_app/screens/cinema_map_screen.dart';
import 'package:cinemax_app/screens/reminder_screen.dart';
import 'package:cinemax_app/widgets/export_widgets.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentTabIndex = 0;
  StreamSubscription? _eventSubscription;
  final TextEditingController _searchController = TextEditingController();
  String _selectedSort = 'Episode';
  String _selectedDirector = 'All';
  String _selectedDecade = 'All';
  bool _onlyFavorites = false;

  @override
  void initState() {
    super.initState();
    _eventSubscription = eventBus.on<ReminderCreatedEvent>().listen((event) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: AppColors.primaryYellow,
            content: Row(
              children: [
                const Icon(Icons.check_circle, color: AppColors.iconPrimary),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Reminder set: ${event.reminder.movieTitle} at ${event.reminder.cinemaName}',
                    style: const TextStyle(
                      color: Color(0xFF0F172A),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            duration: const Duration(seconds: 3),
          ),
        );
      }
    });
  }

  void _onSearchChanged(String val) {
    context.read<AllMovieBloc>().add(SearchMovie(val));
  }

  @override
  void dispose() {
    _searchController.dispose();
    _eventSubscription?.cancel();
    super.dispose();
  }

  List<Movie> _filterAndSortMovies(List<Movie> rawMovies,
      [Set<int>? favoriteIds, String searchQuery = '']) {
    List<Movie> list = List.from(rawMovies);

    if (_onlyFavorites && favoriteIds != null) {
      list = list.where((m) => favoriteIds.contains(m.swapiId)).toList();
    }

    if (searchQuery.trim().isNotEmpty) {
      final q = searchQuery.trim().toLowerCase();
      list = list.where((m) {
        final titleMatch = m.title?.toLowerCase().contains(q) ?? false;
        final directorMatch = m.director?.toLowerCase().contains(q) ?? false;
        return titleMatch || directorMatch;
      }).toList();
    }

    if (_selectedDirector != 'All' && _selectedDirector != 'Semua') {
      list = list.where((m) {
        return (m.director?.toLowerCase() ?? '')
            .contains(_selectedDirector.toLowerCase());
      }).toList();
    }

    if (_selectedDecade != 'All' && _selectedDecade != 'Semua') {
      list = list.where((m) {
        final year = m.releaseDate?.year;
        if (year == null) return false;
        if (_selectedDecade == '70s Era' || _selectedDecade == 'Era 70-an' || _selectedDecade == '70-an') {
          return year >= 1970 && year < 1980;
        } else if (_selectedDecade == '80s Era' || _selectedDecade == 'Era 80-an' || _selectedDecade == '80-an') {
          return year >= 1980 && year < 1990;
        } else if (_selectedDecade == '90s & 2000s Era' ||
            _selectedDecade == 'Era 90-an & 2000-an' ||
            _selectedDecade == '2000-an') {
          return year >= 1990 && year < 2010;
        }
        return true;
      }).toList();
    }

    if (_selectedSort == 'Episode' || _selectedSort == 'By Episode' || _selectedSort == 'Berdasarkan Episode') {
      list.sort((a, b) => (a.episodeId ?? 0).compareTo(b.episodeId ?? 0));
    } else if (_selectedSort == 'Release Year' || _selectedSort == 'Tahun Rilis') {
      list.sort((a, b) =>
          (a.releaseDate ?? DateTime(0)).compareTo(b.releaseDate ?? DateTime(0)));
    } else if (_selectedSort == 'Title A-Z' || _selectedSort == 'Judul A-Z' || _selectedSort == 'Abjad (A-Z)') {
      list.sort((a, b) => (a.title ?? '').compareTo(b.title ?? ''));
    }

    return list;
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: _currentTabIndex == 0,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          setState(() => _currentTabIndex = 0);
        }
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: _currentTabIndex == 0
            ? AppBar(
                backgroundColor: Colors.white,
                elevation: 0,
                surfaceTintColor: Colors.transparent,
                title: const Text(
                  'Star Wars Movies',
                  style: TextStyle(
                    color: AppColors.deepSlate,
                    fontWeight: FontWeight.bold,
                    fontSize: AppDimens.titleMain,
                  ),
                ),
                actions: [
                  Padding(
                    padding: const EdgeInsets.only(right: 12),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Semantics(
                          button: true,
                          label: 'Buka perbandingan film',
                          child: Tooltip(
                            message: 'Compare movies',
                            child: GestureDetector(
                              behavior: HitTestBehavior.opaque,
                              onTap: () {
                                Navigator.pushNamed(context, '/compare');
                              },
                              child: Container(
                                height: AppDimens.buttonHeight,
                                padding: const EdgeInsets.symmetric(horizontal: 14),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF0F172A),
                                  borderRadius:
                                      BorderRadius.circular(AppDimens.buttonHeight / 2),
                                  boxShadow: const [
                                    BoxShadow(
                                      color: Color(0x20000000),
                                      blurRadius: 4,
                                      offset: Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: const Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.compare_arrows,
                                        size: 18, color: Color(0xFFFFE81F)),
                                    SizedBox(width: 6),
                                    Text(
                                      'Compare',
                                      style: TextStyle(
                                        color: Color(0xFFFFE81F),
                                        fontSize: AppDimens.captionSmall,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: AppDimens.buttonSpacing),
                        BlocBuilder<BookmarkBloc, BookmarkState>(
                          buildWhen: (prev, curr) {
                            if (prev is BookmarkLoaded && curr is BookmarkLoaded) {
                              return prev.favoriteIds.length != curr.favoriteIds.length;
                            }
                            return prev.runtimeType != curr.runtimeType;
                          },
                          builder: (context, bState) {
                            final favCount = bState is BookmarkLoaded
                                ? bState.favoriteIds.length
                                : 0;
                            final isActive = _onlyFavorites && _currentTabIndex == 0;

                            return Semantics(
                              button: true,
                              selected: isActive,
                              label: isActive
                                  ? 'Filter film tersimpan aktif, $favCount film. Ketuk untuk tampilkan semua film'
                                  : 'Filter film tersimpan, $favCount film',
                              child: Tooltip(
                                message: isActive
                                    ? 'Show all movies'
                                    : 'Saved movies ($favCount)',
                                child: GestureDetector(
                                  behavior: HitTestBehavior.opaque,
                                  onTap: () {
                                    setState(() {
                                      if (_currentTabIndex != 0) {
                                        _currentTabIndex = 0;
                                        _onlyFavorites = true;
                                      } else {
                                        _onlyFavorites = !_onlyFavorites;
                                      }
                                    });
                                  },
                                  child: AnimatedContainer(
                                    duration: const Duration(milliseconds: 200),
                                    height: AppDimens.buttonHeight,
                                    padding:
                                        const EdgeInsets.symmetric(horizontal: 14),
                                    decoration: BoxDecoration(
                                      color: isActive
                                          ? AppColors.teal
                                          : const Color(0xFF0F172A),
                                      borderRadius: BorderRadius.circular(
                                          AppDimens.buttonHeight / 2),
                                      boxShadow: const [
                                        BoxShadow(
                                          color: Color(0x20000000),
                                          blurRadius: 4,
                                          offset: Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          isActive || favCount > 0
                                              ? Icons.bookmark
                                              : Icons.bookmark_border,
                                          size: 18,
                                          color: isActive
                                              ? Colors.white
                                              : AppColors.primaryYellow,
                                        ),
                                        const SizedBox(width: 6),
                                        Text(
                                          '$favCount',
                                          style: TextStyle(
                                            color: isActive
                                                ? Colors.white
                                                : AppColors.primaryYellow,
                                            fontSize: AppDimens.captionSmall,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ],
                bottom: PreferredSize(
                  preferredSize: const Size.fromHeight(1),
                  child: Container(color: AppColors.surface, height: 1),
                ),
              )
            : null,
        body: IndexedStack(
          index: _currentTabIndex,
          children: [
            _buildMoviesTab(),
            CinemaMapScreen(
              onBack: () => setState(() => _currentTabIndex = 0),
            ),
            ReminderScreen(
              onBack: () => setState(() => _currentTabIndex = 0),
            ),
          ],
        ),
        bottomNavigationBar: Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            border: Border(top: BorderSide(color: AppColors.surface, width: 1)),
          ),
          child: BottomNavigationBar(
            currentIndex: _currentTabIndex,
            onTap: (index) {
              setState(() => _currentTabIndex = index);
              if (index == 1) {
                final mapsB = context.read<MapsBloc>();
                if (mapsB.state is! MapsLoaded) {
                  mapsB.add(FetchCurrentLocation());
                }
              }
            },
            backgroundColor: Colors.white,
            selectedItemColor: AppColors.deepSlate,
            unselectedItemColor: AppColors.lightSlate,
            iconSize: AppDimens.iconSizeLarge,
            selectedFontSize: AppDimens.captionSmall,
            unselectedFontSize: AppDimens.captionSmall,
            selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold),
            unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500),
            elevation: 8,
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.movie_outlined),
                activeIcon: Icon(Icons.movie, color: AppColors.deepSlate),
                label: 'Movies',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.location_on_outlined),
                activeIcon: Icon(Icons.location_on, color: AppColors.deepSlate),
                label: 'Cinemas',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.alarm_outlined),
                activeIcon: Icon(Icons.alarm, color: AppColors.deepSlate),
                label: 'Reminders',
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMoviesTab() {
    AllMovieBloc allMovieBloc = context.read<AllMovieBloc>();

    return BlocBuilder<AllMovieBloc, AllMovieState>(
      bloc: allMovieBloc,
      buildWhen: (prev, curr) =>
          prev.runtimeType != curr.runtimeType ||
          (prev is AllMovieLoaded &&
              curr is AllMovieLoaded &&
              (prev.listMovie != curr.listMovie ||
                  prev.searchQuery != curr.searchQuery)),
      builder: (context, state) {
        if (state is AllMovieInitial || state is AllMovieLoading) {
          return const Center(
            child: CircularProgressIndicator(color: AppColors.primaryYellow),
          );
        } else if (state is AllMovieLoaded) {
          final rawMovies = state.listMovie;
          final searchQuery = state.searchQuery;

          return BlocBuilder<BookmarkBloc, BookmarkState>(
            buildWhen: (prev, curr) {
              if (prev is BookmarkLoaded && curr is BookmarkLoaded) {
                return prev.favoriteIds != curr.favoriteIds;
              }
              return prev.runtimeType != curr.runtimeType;
            },
            builder: (context, bookmarkState) {
              final favoriteIds = bookmarkState is BookmarkLoaded
                  ? bookmarkState.favoriteIds
                  : <int>{};
              final movies =
                  _filterAndSortMovies(rawMovies, favoriteIds, searchQuery);

              final bool hasActiveFilters = searchQuery.isNotEmpty ||
                  _selectedDirector != 'All' ||
                  _selectedDecade != 'All' ||
                  _selectedSort != 'Episode' ||
                  _onlyFavorites;

              return RefreshIndicator(
                color: AppColors.primaryYellow,
                backgroundColor: Colors.white,
                onRefresh: () async {
                  allMovieBloc.add(FetchAllMovie());
                },
                child: CustomScrollView(
                  slivers: [
                    const SliverToBoxAdapter(child: SizedBox(height: 16)),
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: AppSearchBar(
                          controller: _searchController,
                          onChanged: _onSearchChanged,
                          onClear: () {
                            context
                                .read<AllMovieBloc>()
                                .add(const SearchMovie(''));
                          },
                        ),
                      ),
                    ),
                    const SliverToBoxAdapter(child: SizedBox(height: 10)),
                    SliverToBoxAdapter(
                      child: SizedBox(
                        height: AppDimens.buttonHeight,
                        child: ListView(
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          children: [
                            Semantics(
                              button: true,
                              label: 'Urutkan film berdasarkan $_selectedSort',
                              child: PopupMenuButton<String>(
                                onSelected: (val) =>
                                    setState(() => _selectedSort = val),
                                itemBuilder: (context) => [
                                  const PopupMenuItem(
                                      value: 'Episode',
                                      child: Text('By Episode',
                                          style: TextStyle(
                                              fontSize:
                                                  AppDimens.captionSmall))),
                                  const PopupMenuItem(
                                      value: 'Release Year',
                                      child: Text('Release Year',
                                          style: TextStyle(
                                              fontSize:
                                                  AppDimens.captionSmall))),
                                  const PopupMenuItem(
                                      value: 'Title A-Z',
                                      child: Text('Title (A-Z)',
                                          style: TextStyle(
                                              fontSize:
                                                  AppDimens.captionSmall))),
                                ],
                                child: Container(
                                  height: AppDimens.buttonHeight,
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 14),
                                  decoration: BoxDecoration(
                                    color: _selectedSort != 'Episode'
                                        ? AppColors.primaryYellow.withAlpha(60)
                                        : AppColors.surface,
                                    borderRadius: BorderRadius.circular(
                                        AppDimens.buttonHeight / 2),
                                    border: Border.all(
                                      color: _selectedSort != 'Episode'
                                          ? AppColors.teal
                                          : AppColors.border,
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(Icons.swap_vert,
                                          size: 18, color: AppColors.teal),
                                      const SizedBox(width: 6),
                                      Text(
                                        _selectedSort == 'Episode'
                                            ? 'Sort By'
                                            : _selectedSort,
                                        style: TextStyle(
                                          fontSize: AppDimens.captionSmall,
                                          fontWeight: FontWeight.w600,
                                          color: _selectedSort != 'Episode'
                                              ? AppColors.teal
                                              : AppColors.deepSlate,
                                        ),
                                      ),
                                      const Icon(Icons.arrow_drop_down,
                                          size: 18, color: AppColors.slate),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: AppDimens.buttonSpacing),
                            Semantics(
                              button: true,
                              label: 'Filter sutradara: $_selectedDirector',
                              child: PopupMenuButton<String>(
                                onSelected: (val) =>
                                    setState(() => _selectedDirector = val),
                                itemBuilder: (context) => [
                                  const PopupMenuItem(
                                      value: 'All',
                                      child: Text('All Directors',
                                          style: TextStyle(
                                              fontSize:
                                                  AppDimens.captionSmall))),
                                  const PopupMenuItem(
                                      value: 'George Lucas',
                                      child: Text('George Lucas',
                                          style: TextStyle(
                                              fontSize:
                                                  AppDimens.captionSmall))),
                                  const PopupMenuItem(
                                      value: 'Irvin Kershner',
                                      child: Text('Irvin Kershner',
                                          style: TextStyle(
                                              fontSize:
                                                  AppDimens.captionSmall))),
                                  const PopupMenuItem(
                                      value: 'Richard Marquand',
                                      child: Text('Richard Marquand',
                                          style: TextStyle(
                                              fontSize:
                                                  AppDimens.captionSmall))),
                                ],
                                child: Container(
                                  height: AppDimens.buttonHeight,
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 14),
                                  decoration: BoxDecoration(
                                    color: _selectedDirector != 'All'
                                        ? AppColors.primaryYellow.withAlpha(60)
                                        : AppColors.surface,
                                    borderRadius: BorderRadius.circular(
                                        AppDimens.buttonHeight / 2),
                                    border: Border.all(
                                      color: _selectedDirector != 'All'
                                          ? AppColors.teal
                                          : AppColors.border,
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(Icons.person_outline,
                                          size: 18, color: AppColors.teal),
                                      const SizedBox(width: 6),
                                      Text(
                                        _selectedDirector == 'All'
                                            ? 'Director'
                                            : _selectedDirector,
                                        style: TextStyle(
                                          fontSize: AppDimens.captionSmall,
                                          fontWeight: FontWeight.w600,
                                          color: _selectedDirector != 'All'
                                              ? AppColors.teal
                                              : AppColors.deepSlate,
                                        ),
                                      ),
                                      const Icon(Icons.arrow_drop_down,
                                          size: 18, color: AppColors.slate),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: AppDimens.buttonSpacing),
                            Semantics(
                              button: true,
                              label: 'Filter era dekade: $_selectedDecade',
                              child: PopupMenuButton<String>(
                                onSelected: (val) =>
                                    setState(() => _selectedDecade = val),
                                itemBuilder: (context) => [
                                  const PopupMenuItem(
                                      value: 'All',
                                      child: Text('All Decades',
                                          style: TextStyle(
                                              fontSize:
                                                  AppDimens.captionSmall))),
                                  const PopupMenuItem(
                                      value: '70s Era',
                                      child: Text('70s Era',
                                          style: TextStyle(
                                              fontSize:
                                                  AppDimens.captionSmall))),
                                  const PopupMenuItem(
                                      value: '80s Era',
                                      child: Text('80s Era',
                                          style: TextStyle(
                                              fontSize:
                                                  AppDimens.captionSmall))),
                                  const PopupMenuItem(
                                      value: '90s & 2000s Era',
                                      child: Text('90s & 2000s Era',
                                          style: TextStyle(
                                              fontSize:
                                                  AppDimens.captionSmall))),
                                ],
                                child: Container(
                                  height: AppDimens.buttonHeight,
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 14),
                                  decoration: BoxDecoration(
                                    color: _selectedDecade != 'All'
                                        ? AppColors.primaryYellow.withAlpha(60)
                                        : AppColors.surface,
                                    borderRadius: BorderRadius.circular(
                                        AppDimens.buttonHeight / 2),
                                    border: Border.all(
                                      color: _selectedDecade != 'All'
                                          ? AppColors.teal
                                          : AppColors.border,
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(Icons.calendar_today_outlined,
                                          size: 16, color: AppColors.teal),
                                      const SizedBox(width: 6),
                                      Text(
                                        _selectedDecade == 'All'
                                            ? 'Decade'
                                            : _selectedDecade,
                                        style: TextStyle(
                                          fontSize: AppDimens.captionSmall,
                                          fontWeight: FontWeight.w600,
                                          color: _selectedDecade != 'All'
                                              ? AppColors.teal
                                              : AppColors.deepSlate,
                                        ),
                                      ),
                                      const Icon(Icons.arrow_drop_down,
                                          size: 18, color: AppColors.slate),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            if (hasActiveFilters) ...[
                              const SizedBox(width: AppDimens.buttonSpacing),
                              Semantics(
                                button: true,
                                label: 'Reset semua filter pencarian',
                                child: GestureDetector(
                                  behavior: HitTestBehavior.opaque,
                                  onTap: () {
                                    _searchController.clear();
                                    context
                                        .read<AllMovieBloc>()
                                        .add(const SearchMovie(''));
                                    setState(() {
                                      _selectedDirector = 'All';
                                      _selectedDecade = 'All';
                                      _selectedSort = 'Episode';
                                      _onlyFavorites = false;
                                    });
                                  },
                                  child: Container(
                                    height: AppDimens.buttonHeight,
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 14),
                                    decoration: BoxDecoration(
                                      color: AppColors.error.withAlpha(20),
                                      borderRadius: BorderRadius.circular(
                                          AppDimens.buttonHeight / 2),
                                      border: Border.all(
                                          color:
                                              AppColors.error.withAlpha(80)),
                                    ),
                                    child: const Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(Icons.refresh,
                                            size: 16, color: AppColors.error),
                                        SizedBox(width: 4),
                                        Text(
                                          'Reset',
                                          style: TextStyle(
                                            fontSize: AppDimens.captionSmall,
                                            fontWeight: FontWeight.bold,
                                            color: AppColors.error,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                    const SliverToBoxAdapter(child: SizedBox(height: 12)),
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 4),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  _onlyFavorites
                                      ? 'Saved Movies'
                                      : (searchQuery.isNotEmpty ||
                                              _selectedDirector != 'All' ||
                                              _selectedDecade != 'All'
                                          ? 'Search Results'
                                          : 'Movie Collection'),
                                  style: const TextStyle(
                                    color: AppColors.deepSlate,
                                    fontSize: AppDimens.titleMain,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: AppColors.surface,
                                    borderRadius: BorderRadius.circular(10),
                                    border:
                                        Border.all(color: AppColors.border),
                                  ),
                                  child: Text(
                                    '${movies.length} ${movies.length == 1 ? 'movie' : 'movies'}',
                                    style: const TextStyle(
                                      color: AppColors.slate,
                                      fontSize: AppDimens.captionSmall,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            if (_onlyFavorites)
                              GestureDetector(
                                onTap: () {
                                  setState(() {
                                    _onlyFavorites = false;
                                  });
                                },
                                child: const Text(
                                  'Show all',
                                  style: TextStyle(
                                    color: AppColors.teal,
                                    fontSize: AppDimens.captionSmall,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                    const SliverToBoxAdapter(child: SizedBox(height: 12)),
                    if (movies.isEmpty)
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              vertical: 40, horizontal: 24),
                          child: Column(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(16),
                                decoration: const BoxDecoration(
                                  color: AppColors.surface,
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  _onlyFavorites
                                      ? Icons.bookmark_border_rounded
                                      : Icons.search_off_rounded,
                                  size: 40,
                                  color: AppColors.lightSlate,
                                ),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                _onlyFavorites
                                    ? 'No saved movies yet'
                                    : 'No movies found',
                                style: const TextStyle(
                                  color: AppColors.deepSlate,
                                  fontWeight: FontWeight.bold,
                                  fontSize: AppDimens.titleMain,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                _onlyFavorites
                                    ? 'Bookmark movies you like to save them here for quick access.'
                                    : 'Try checking your search keyword or reset active filters.',
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  color: AppColors.slate,
                                  fontSize: AppDimens.textMain,
                                  height: 1.4,
                                ),
                              ),
                              const SizedBox(height: 16),
                              if (_onlyFavorites)
                                OutlinedButton.icon(
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: AppColors.teal,
                                    side: const BorderSide(
                                        color: AppColors.teal),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      _onlyFavorites = false;
                                    });
                                  },
                                  icon: const Icon(Icons.movie_outlined,
                                      size: 16),
                                  label: const Text(
                                    'Explore All Movies',
                                    style: TextStyle(
                                      fontSize: AppDimens.captionSmall,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                )
                              else if (hasActiveFilters)
                                OutlinedButton.icon(
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: AppColors.teal,
                                    side: const BorderSide(
                                        color: AppColors.teal),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                  ),
                                  onPressed: () {
                                    _searchController.clear();
                                    context
                                        .read<AllMovieBloc>()
                                        .add(const SearchMovie(''));
                                    setState(() {
                                      _selectedDirector = 'All';
                                      _selectedDecade = 'All';
                                      _selectedSort = 'Episode';
                                      _onlyFavorites = false;
                                    });
                                  },
                                  icon: const Icon(Icons.refresh, size: 16),
                                  label: const Text(
                                    'Reset Filters',
                                    style: TextStyle(
                                      fontSize: AppDimens.captionSmall,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      )
                    else
                      SliverPadding(
                        padding: const EdgeInsets.symmetric(horizontal: 14),
                        sliver: SliverGrid(
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            childAspectRatio: 0.49,
                            mainAxisSpacing: 20,
                            crossAxisSpacing: 14,
                          ),
                          delegate: SliverChildBuilderDelegate(
                            (context, index) {
                              final movie = movies[index];
                              return MovieCard(
                                movie: movie,
                                index: index,
                                onTap: () {
                                  Navigator.pushNamed(
                                    context,
                                    '/films/${movie.swapiId}',
                                  );
                                },
                              );
                            },
                            childCount: movies.length,
                          ),
                        ),
                      ),
                    const SliverToBoxAdapter(child: SizedBox(height: 32)),
                  ],
                ),
              );
        },
      );
    } else if (state is AllMovieError) {
      return AppErrorView(
        error: state.error,
        onRetry: () => allMovieBloc.add(FetchAllMovie()),
      );
    }
        return const SizedBox();
      },
    );
  }
}
