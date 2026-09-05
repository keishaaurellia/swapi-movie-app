import 'package:flutter/material.dart';
import 'package:cinemax_app/bloc/export.dart';
import 'package:cinemax_app/bloc/all_movie/all_movie_bloc.dart';
import 'package:cinemax_app/screens/movie_screen.dart';
import 'package:cinemax_app/widgets/export_widgets.dart';

class MovieCompareScreen extends StatefulWidget {
  final int? initialMovieId;

  const MovieCompareScreen({super.key, this.initialMovieId});

  @override
  State<MovieCompareScreen> createState() => _MovieCompareScreenState();
}

class _MovieCompareScreenState extends State<MovieCompareScreen> {
  Movie? _movieA;
  Movie? _movieB;
  bool _initialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      final allMovieState = context.read<AllMovieBloc>().state;
      if (allMovieState is AllMovieLoaded &&
          allMovieState.listMovie.isNotEmpty) {
        final movies = allMovieState.listMovie;
        final initialId = widget.initialMovieId;
        if (initialId != null) {
          final matchedMovie = movies.firstWhere(
            (m) => m.swapiId == initialId,
            orElse: () => movies[0],
          );
          _movieA = matchedMovie;
          _movieB = movies.firstWhere(
            (m) => m.swapiId != matchedMovie.swapiId,
            orElse: () => movies.length > 1 ? movies[1] : movies[0],
          );
        } else {
          _movieA = movies[0];
          _movieB = movies.length > 1 ? movies[1] : movies[0];
        }
      }
      _initialized = true;
    }
  }

  void _showMoviePicker(bool forMovieA, List<Movie> movies) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        forMovieA ? 'SELECT FIRST MOVIE' : 'SELECT SECOND MOVIE',
                        style: const TextStyle(
                          fontSize: AppDimens.titleMain,
                          fontWeight: FontWeight.w900,
                          color: AppColors.teal,
                          letterSpacing: 1.2,
                        ),
                      ),
                      Semantics(
                        button: true,
                        label: 'Tutup pemilih film',
                        child: Container(
                          width: AppDimens.buttonSize,
                          height: AppDimens.buttonSize,
                          alignment: Alignment.center,
                          child: IconButton(
                            padding: EdgeInsets.zero,
                            icon: const Icon(Icons.close,
                                size: AppDimens.iconSize,
                                color: AppColors.lightSlate),
                            onPressed: () => Navigator.pop(context),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const Divider(
                  height: 1,
                  thickness: 0.5,
                  color: AppColors.border,
                ),
                Flexible(
                  child: ListView.separated(
                    shrinkWrap: true,
                    itemCount: movies.length,
                    separatorBuilder: (_, __) => const Divider(
                      height: 1,
                      thickness: 0.5,
                      color: AppColors.border,
                    ),
                    itemBuilder: (context, index) {
                      final m = movies[index];
                      final isCurrentSelected = forMovieA
                          ? m.swapiId == _movieA?.swapiId
                          : m.swapiId == _movieB?.swapiId;
                      final isOtherSelected = forMovieA
                          ? m.swapiId == _movieB?.swapiId
                          : m.swapiId == _movieA?.swapiId;

                      return Semantics(
                        button: !isOtherSelected,
                        selected: isCurrentSelected,
                        enabled: !isOtherSelected,
                        label: isOtherSelected
                            ? '${m.title} sedang aktif di ${forMovieA ? "Movie B" : "Movie A"}'
                            : 'Pilih film ${m.title}, Episode ${m.episodeId}',
                        child: Opacity(
                          opacity: isOtherSelected ? 0.45 : 1.0,
                          child: ListTile(
                            enabled: !isOtherSelected,
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 20, vertical: 4),
                            leading: ClipRRect(
                              borderRadius: BorderRadius.circular(6),
                              child: Image.asset(
                                m.posterAsset,
                                width: 36,
                                height: 52,
                                fit: BoxFit.cover,
                                cacheWidth: 72,
                                cacheHeight: 104,
                                errorBuilder: (_, __, ___) => Container(
                                  width: 36,
                                  height: 52,
                                  color: AppColors.surface,
                                  child: const Icon(Icons.movie, size: 20),
                                ),
                              ),
                            ),
                            title: Text(
                              m.title ?? 'Movie',
                              style: TextStyle(
                                fontSize: AppDimens.textMain,
                                fontWeight: isCurrentSelected
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                                color: isOtherSelected
                                    ? AppColors.lightSlate
                                    : AppColors.deepSlate,
                              ),
                            ),
                            subtitle: Text(
                              isOtherSelected
                                  ? 'Sedang aktif di ${forMovieA ? "Movie B" : "Movie A"}'
                                  : 'Episode ${m.episodeId} • ${m.releaseDate?.year ?? ''}',
                              style: TextStyle(
                                fontSize: AppDimens.captionSmall,
                                color: isOtherSelected
                                    ? AppColors.slate
                                    : AppColors.slate,
                                fontWeight: isOtherSelected
                                    ? FontWeight.w600
                                    : FontWeight.normal,
                              ),
                            ),
                            trailing: isCurrentSelected
                                ? const Icon(Icons.check_circle,
                                    color: AppColors.deepSlate)
                                : (isOtherSelected
                                    ? Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 8, vertical: 3),
                                        decoration: BoxDecoration(
                                          color: AppColors.surface,
                                          borderRadius:
                                              BorderRadius.circular(6),
                                        ),
                                        child: Text(
                                          forMovieA ? 'Aktif di B' : 'Aktif di A',
                                          style: const TextStyle(
                                            fontSize: AppDimens.captionSmall,
                                            color: AppColors.slate,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      )
                                    : null),
                            onTap: isOtherSelected
                                ? null
                                : () {
                                    setState(() {
                                      if (forMovieA) {
                                        _movieA = m;
                                      } else {
                                        _movieB = m;
                                      }
                                    });
                                    Navigator.pop(context);
                                  },
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        leading: Semantics(
          button: true,
          label: 'Kembali ke halaman sebelumnya',
          child: Container(
            width: AppDimens.buttonSize,
            height: AppDimens.buttonSize,
            alignment: Alignment.center,
            child: IconButton(
              icon: const Icon(Icons.arrow_back,
                  size: AppDimens.iconSize, color: AppColors.deepSlate),
              onPressed: () => Navigator.pop(context),
            ),
          ),
        ),
        title: const Text(
          'Fleet & Lore Comparison',
          style: TextStyle(
            fontSize: AppDimens.titleMain,
            fontWeight: FontWeight.w900,
            letterSpacing: 1.1,
          ),
        ),
        actions: [
          Semantics(
            button: true,
            label: 'Tukar posisi film A dan film B',
            child: Container(
              width: AppDimens.buttonSize,
              height: AppDimens.buttonSize,
              margin: const EdgeInsets.only(right: AppDimens.buttonSpacing),
              alignment: Alignment.center,
              child: IconButton(
                icon: const Icon(Icons.swap_horiz,
                    size: AppDimens.iconSizeLarge, color: AppColors.deepSlate),
                onPressed: () {
                  setState(() {
                    final temp = _movieA;
                    _movieA = _movieB;
                    _movieB = temp;
                  });
                },
              ),
            ),
          ),
        ],
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: AppColors.surface, height: 1),
        ),
      ),
      body: BlocBuilder<AllMovieBloc, AllMovieState>(
        builder: (context, state) {
          if (state is AllMovieLoading) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.teal),
            );
          }
          if (state is AllMovieError) {
            return AppErrorView(
              error: state.error,
              onRetry: () => context.read<AllMovieBloc>().add(FetchAllMovie()),
            );
          }
          if (state is! AllMovieLoaded || state.listMovie.isEmpty) {
            return const Center(
              child: Text(
                'Movie data unavailable',
                style: TextStyle(fontSize: AppDimens.textMain),
              ),
            );
          }

          final movies = state.listMovie;
          final currentA = _movieA;
          final currentB = _movieB;
          if (movies.length > 1 &&
              currentA != null &&
              currentB != null &&
              currentA.swapiId == currentB.swapiId) {
            _movieB = movies.firstWhere(
              (m) => m.swapiId != currentA.swapiId,
              orElse: () => movies[1],
            );
          }
          final a = _movieA ?? movies[0];
          final b = _movieB ?? (movies.length > 1 ? movies[1] : movies[0]);

          final int aStarships = a.starships.length;
          final int bStarships = b.starships.length;
          final int aVehicles = a.vehicles.length;
          final int bVehicles = b.vehicles.length;
          final int aTotalFleet = aStarships + aVehicles;
          final int bTotalFleet = bStarships + bVehicles;
          final int aPlanets = a.planets.length;
          final int bPlanets = b.planets.length;
          final int aCharacters = a.characters.length;
          final int bCharacters = b.characters.length;
          final int aSpecies = a.species.length;
          final int bSpecies = b.species.length;

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF0F172A), Color(0xFF1E293B)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.shield_outlined,
                            size: 16, color: Color(0xFFFFE81F)),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'STAR WARS FLEET & WORLD-BUILDING',
                            style: TextStyle(
                              color: Color(0xFFFFE81F),
                              fontSize: AppDimens.captionSmall,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 1.2,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: _buildMovieCardSelector(
                            movie: a,
                            label: 'MOVIE A',
                            tagColor: AppColors.teal,
                            onTap: () => _showMoviePicker(true, movies),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: AppDimens.buttonSpacing,
                              vertical: 40),
                          child: Semantics(
                            button: true,
                            label: 'Tukar posisi film A dan film B',
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                onTap: () {
                                  setState(() {
                                    final temp = _movieA;
                                    _movieA = _movieB;
                                    _movieB = temp;
                                  });
                                },
                                borderRadius: BorderRadius.circular(
                                    AppDimens.buttonSizeLarge / 2),
                                child: Container(
                                  width: AppDimens.buttonSizeLarge,
                                  height: AppDimens.buttonSizeLarge,
                                  alignment: Alignment.center,
                                  decoration: const BoxDecoration(
                                    color: Color(0xFFFFE81F),
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black26,
                                        blurRadius: 4,
                                        offset: Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: const Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        'VS',
                                        style: TextStyle(
                                          color: Color(0xFF0F172A),
                                          fontWeight: FontWeight.w900,
                                          fontSize: AppDimens.captionSmall,
                                        ),
                                      ),
                                      Icon(
                                        Icons.swap_horiz,
                                        size: 11,
                                        color: Color(0xFF0F172A),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: _buildMovieCardSelector(
                            movie: b,
                            label: 'MOVIE B',
                            tagColor: const Color(0xFF3B82F6),
                            onTap: () => _showMoviePicker(false, movies),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              _buildSectionTitle('MILITARY & FLEET SUPREMACY'),
              const SizedBox(height: 8),
              _buildComparisonMetricCard(
                title: 'Space Fleet (Starships)',
                icon: Icons.rocket_launch,
                valueA: aStarships,
                valueB: bStarships,
                subtitle: 'Interstellar combat craft & flagships',
              ),
              const SizedBox(height: 10),
              _buildComparisonMetricCard(
                title: 'Surface Fleet (Vehicles)',
                icon: Icons.directions_car,
                valueA: aVehicles,
                valueB: bVehicles,
                subtitle: 'Speeders, walkers & planetary craft',
              ),
              const SizedBox(height: 10),
              _buildComparisonMetricCard(
                title: 'Total Combat Fleet',
                icon: Icons.military_tech,
                valueA: aTotalFleet,
                valueB: bTotalFleet,
                subtitle: 'Combined starships and combat vehicles',
                highlight: true,
              ),
              const SizedBox(height: 20),
              _buildSectionTitle('WORLD-BUILDING & GALACTIC REACH'),
              const SizedBox(height: 8),
              _buildComparisonMetricCard(
                title: 'Planetary Reach (Planets)',
                icon: Icons.public,
                valueA: aPlanets,
                valueB: bPlanets,
                subtitle: 'Diversity of locations & star systems',
                highlight: true,
              ),
              const SizedBox(height: 10),
              _buildComparisonMetricCard(
                title: 'Characters Featured',
                icon: Icons.people,
                valueA: aCharacters,
                valueB: bCharacters,
                subtitle: 'Key figures & characters appearing',
              ),
              const SizedBox(height: 10),
              _buildComparisonMetricCard(
                title: 'Species Diversity',
                icon: Icons.pets,
                valueA: aSpecies,
                valueB: bSpecies,
                subtitle: 'Alien races & galactic sentient species',
              ),
              const SizedBox(height: 20),
              _buildSectionTitle('STAR WARS LORE VERDICT'),
              const SizedBox(height: 8),
              _buildLoreVerdictCard(
                movieA: a,
                movieB: b,
                aStarships: aStarships,
                bStarships: bStarships,
                aTotalFleet: aTotalFleet,
                bTotalFleet: bTotalFleet,
                aPlanets: aPlanets,
                bPlanets: bPlanets,
              ),
              const SizedBox(height: 20),
              _buildSectionTitle('FLEET DETAILS'),
              const SizedBox(height: 8),
              _buildFleetListsSection(a, b),
              const SizedBox(height: 20),
              _buildSectionTitle('LIHAT DETAIL FILM'),
              const SizedBox(height: AppDimens.buttonSpacing),
              Row(
                children: [
                  Expanded(
                    child: Semantics(
                      button: true,
                      label: 'Buka detail film ${a.title}',
                      child: SizedBox(
                        height: AppDimens.buttonHeight,
                        child: ElevatedButton.icon(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => MovieScreen(id: a.swapiId),
                              ),
                            );
                          },
                          icon: const Icon(Icons.movie_outlined,
                              size: AppDimens.iconSize),
                          label: Text(
                            a.title ?? 'Film A',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: AppDimens.textMain,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.teal,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: AppDimens.buttonSpacing),
                  Expanded(
                    child: Semantics(
                      button: true,
                      label: 'Buka detail film ${b.title}',
                      child: SizedBox(
                        height: AppDimens.buttonHeight,
                        child: ElevatedButton.icon(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => MovieScreen(id: b.swapiId),
                              ),
                            );
                          },
                          icon: const Icon(Icons.movie_outlined,
                              size: AppDimens.iconSize),
                          label: Text(
                            b.title ?? 'Film B',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: AppDimens.textMain,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF3B82F6),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 30),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 18,
          decoration: BoxDecoration(
            color: AppColors.teal,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            color: AppColors.deepSlate,
            fontSize: AppDimens.textMain,
            fontWeight: FontWeight.w900,
            letterSpacing: 0.8,
          ),
        ),
      ],
    );
  }

  Widget _buildMovieCardSelector({
    required Movie movie,
    required String label,
    required Color tagColor,
    required VoidCallback onTap,
  }) {
    return Semantics(
      button: true,
      label: 'Ganti pilihan film $label. Saat ini terpilih ${movie.title}',
      child: GestureDetector(
        onTap: onTap,
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: tagColor,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                  fontSize: AppDimens.captionSmall,
                  letterSpacing: 1.0,
                ),
              ),
            ),
            const SizedBox(height: AppDimens.buttonSpacing),
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.asset(
                movie.posterAsset,
                height: 130,
                width: 90,
                fit: BoxFit.cover,
                cacheWidth: 180,
                cacheHeight: 260,
                errorBuilder: (_, __, ___) => Container(
                  height: 130,
                  width: 90,
                  color: Colors.black26,
                  child: const Icon(Icons.movie, color: Colors.white54),
                ),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              movie.title ?? 'Movie',
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Colors.white,
                fontSize: AppDimens.textMain,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              'EP ${movie.episodeId} (${movie.releaseDate?.year ?? ''})',
              style: const TextStyle(
                color: Colors.white60,
                fontSize: AppDimens.captionSmall,
              ),
            ),
            const SizedBox(height: AppDimens.buttonSpacing),
            Container(
              height: AppDimens.buttonHeight,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: Colors.white.withAlpha(25),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.white38),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.touch_app,
                      size: AppDimens.iconSize, color: Color(0xFFFFE81F)),
                  SizedBox(width: 4),
                  Text(
                    'Ganti',
                    style: TextStyle(
                      color: Color(0xFFFFE81F),
                      fontSize: AppDimens.captionSmall,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildComparisonMetricCard({
    required String title,
    required IconData icon,
    required int valueA,
    required int valueB,
    required String subtitle,
    bool highlight = false,
  }) {
    final int maxVal = (valueA > valueB ? valueA : valueB);
    final double pctA = maxVal == 0 ? 0.5 : (valueA / (valueA + valueB + 0.001));
    final double pctB = maxVal == 0 ? 0.5 : (valueB / (valueA + valueB + 0.001));

    final bool aWins = valueA > valueB;
    final bool bWins = valueB > valueA;
    final bool isDraw = valueA == valueB;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: highlight ? AppColors.teal.withAlpha(120) : AppColors.border,
          width: highlight ? 1.5 : 1,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A000000),
            blurRadius: 6,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: highlight ? AppColors.teal : AppColors.slate),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    color: AppColors.deepSlate,
                    fontSize: AppDimens.textMain,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              if (aWins)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.teal.withAlpha(25),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    'A Leads +${valueA - valueB}',
                    style: const TextStyle(
                      color: AppColors.teal,
                      fontSize: AppDimens.captionSmall,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                )
              else if (bWins)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                  decoration: BoxDecoration(
                    color: const Color(0xFF3B82F6).withAlpha(25),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    'B Leads +${valueB - valueA}',
                    style: const TextStyle(
                      color: Color(0xFF3B82F6),
                      fontSize: AppDimens.captionSmall,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                )
              else if (isDraw)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.grey.withAlpha(30),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Text(
                    'Tied',
                    style: TextStyle(
                      color: AppColors.slate,
                      fontSize: AppDimens.captionSmall,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              SizedBox(
                width: 38,
                child: Text(
                  '$valueA',
                  textAlign: TextAlign.left,
                  style: TextStyle(
                    color: aWins ? AppColors.teal : AppColors.deepSlate,
                    fontSize: AppDimens.titleMain,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: Row(
                    children: [
                      Expanded(
                        flex: (pctA * 100).toInt().clamp(1, 99),
                        child: Container(
                          height: 10,
                          color: aWins
                              ? AppColors.teal
                              : AppColors.teal.withAlpha(100),
                        ),
                      ),
                      const SizedBox(width: 2),
                      Expanded(
                        flex: (pctB * 100).toInt().clamp(1, 99),
                        child: Container(
                          height: 10,
                          color: bWins
                              ? const Color(0xFF3B82F6)
                              : const Color(0xFF3B82F6).withAlpha(100),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(
                width: 38,
                child: Text(
                  '$valueB',
                  textAlign: TextAlign.right,
                  style: TextStyle(
                    color: bWins ? const Color(0xFF3B82F6) : AppColors.deepSlate,
                    fontSize: AppDimens.titleMain,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: const TextStyle(
              color: AppColors.slate,
              fontSize: AppDimens.captionSmall,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoreVerdictCard({
    required Movie movieA,
    required Movie movieB,
    required int aStarships,
    required int bStarships,
    required int aTotalFleet,
    required int bTotalFleet,
    required int aPlanets,
    required int bPlanets,
  }) {
    final String fleetSummary;
    if (aTotalFleet > bTotalFleet) {
      fleetSummary =
          '${movieA.title} dominates the military scale with a more massive combat fleet ($aTotalFleet vs $bTotalFleet units). In lore terms, this film highlights high-intensity space warfare escalation.';
    } else if (bTotalFleet > aTotalFleet) {
      fleetSummary =
          '${movieB.title} holds galactic military supremacy with a total fleet of $bTotalFleet units compared to $aTotalFleet units, reflecting a larger wartime mobilization.';
    } else {
      fleetSummary =
          'Both films demonstrate tactically balanced military fleet strength with a combined total of $aTotalFleet starships and combat vehicles each.';
    }

    final String worldSummary;
    if (aPlanets > bPlanets) {
      worldSummary =
          '${movieA.title} features broader world-building across $aPlanets galactic planets (vs $bPlanets), showcasing diverse civilizations and planetary battlegrounds.';
    } else if (bPlanets > aPlanets) {
      worldSummary =
          '${movieB.title} expands the Star Wars universe across $bPlanets planets (vs $aPlanets), offering deeper exploration of diverse planetary lore.';
    } else {
      worldSummary =
          'Both films explore galactic diversity on an equal scale, each featuring $aPlanets planetary systems.';
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFFFE81F).withAlpha(100)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.auto_stories, size: 18, color: Color(0xFFFFE81F)),
              SizedBox(width: 8),
              Text(
                'LORE & WORLD-BUILDING SUMMARY',
                style: TextStyle(
                  color: Color(0xFFFFE81F),
                  fontSize: AppDimens.textMain,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.1,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            fleetSummary,
            style: const TextStyle(
              color: Color(0xFFF1F5F9),
              fontSize: AppDimens.captionSmall,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            worldSummary,
            style: const TextStyle(
              color: Color(0xFF94A3B8),
              fontSize: AppDimens.captionSmall,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFleetListsSection(Movie a, Movie b) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.teal.withAlpha(100)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${a.title}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: AppDimens.textMain,
                    color: AppColors.teal,
                  ),
                ),
                const SizedBox(height: 6),
                FutureBuilder<List<Starships>>(
                  future: MovieProvider().starships(a.starships),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Center(
                          child: SizedBox(
                            width: 14,
                            height: 14,
                            child: CircularProgressIndicator(
                              strokeWidth: 1.5,
                              color: AppColors.teal,
                            ),
                          ),
                        ),
                      );
                    }
                    final ships = snapshot.data ?? [];
                    if (ships.isEmpty) {
                      return const Text(
                        'No starships registered',
                        style: TextStyle(
                          fontSize: AppDimens.captionSmall,
                          color: AppColors.slate,
                        ),
                      );
                    }
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: ships
                          .map((s) => Padding(
                                padding: const EdgeInsets.symmetric(vertical: 2),
                                child: Text(
                                  '• ${s.name ?? 'Ship'}',
                                  style: const TextStyle(
                                    fontSize: AppDimens.captionSmall,
                                    color: AppColors.deepSlate,
                                  ),
                                ),
                              ))
                          .toList(),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFF3B82F6).withAlpha(100)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${b.title}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: AppDimens.textMain,
                    color: Color(0xFF3B82F6),
                  ),
                ),
                const SizedBox(height: 6),
                FutureBuilder<List<Starships>>(
                  future: MovieProvider().starships(b.starships),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Center(
                          child: SizedBox(
                            width: 14,
                            height: 14,
                            child: CircularProgressIndicator(
                              strokeWidth: 1.5,
                              color: Color(0xFF3B82F6),
                            ),
                          ),
                        ),
                      );
                    }
                    final ships = snapshot.data ?? [];
                    if (ships.isEmpty) {
                      return const Text(
                        'No starships registered',
                        style: TextStyle(
                          fontSize: AppDimens.captionSmall,
                          color: AppColors.slate,
                        ),
                      );
                    }
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: ships
                          .map((s) => Padding(
                                padding: const EdgeInsets.symmetric(vertical: 2),
                                child: Text(
                                  '• ${s.name ?? 'Ship'}',
                                  style: const TextStyle(
                                    fontSize: AppDimens.captionSmall,
                                    color: AppColors.deepSlate,
                                  ),
                                ),
                              ))
                          .toList(),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
