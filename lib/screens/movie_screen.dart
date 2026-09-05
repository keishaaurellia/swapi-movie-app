import 'package:flutter/material.dart';
import 'package:cinemax_app/bloc/export.dart';
import 'package:cinemax_app/bloc/movie/movie_bloc.dart';
import 'package:cinemax_app/screens/cinema_map_screen.dart';
import 'package:cinemax_app/widgets/export_widgets.dart';

class MovieScreen extends StatefulWidget {
  final int id;
  const MovieScreen({super.key, required this.id});

  @override
  State<MovieScreen> createState() => _MovieScreenState();
}

class _MovieScreenState extends State<MovieScreen> {
  bool _show3dCrawl = true;

  @override
  Widget build(BuildContext context) {
    MovieBloc movieB = context.read<MovieBloc>();

    return Scaffold(
      backgroundColor: Colors.white,
      body: BlocBuilder<MovieBloc, MovieState>(
        bloc: movieB..add(FetchMovie(widget.id)),
        buildWhen: (prev, curr) =>
            prev.runtimeType != curr.runtimeType ||
            (prev is MovieLoaded &&
                curr is MovieLoaded &&
                prev.movie != curr.movie),
        builder: (context, state) {
          if (state is MovieInitial || state is MovieLoading) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primaryYellow),
            );
          } else if (state is MovieLoaded) {
            final movie = state.movie;
            final year = movie.releaseDate?.year ?? '1977';

            return CustomScrollView(
              slivers: [
                SliverAppBar(
                  expandedHeight: 320,
                  pinned: true,
                  backgroundColor: Colors.white,
                  elevation: 0,
                  leading: Padding(
                    padding: const EdgeInsets.only(left: 8.0),
                    child: Center(
                      child: Semantics(
                        button: true,
                        label: 'Kembali ke halaman sebelumnya',
                        child: Container(
                          width: AppDimens.buttonSize,
                          height: AppDimens.buttonSize,
                          decoration: BoxDecoration(
                            color: Colors.white.withAlpha(225),
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
                            tooltip: 'Back',
                            icon: const Icon(Icons.arrow_back,
                                color: Color(0xFF0F172A),
                                size: AppDimens.iconSize),
                            onPressed: () => Navigator.pop(context),
                          ),
                        ),
                      ),
                    ),
                  ),
                  actions: [
                    Center(
                      child: Semantics(
                        button: true,
                        label: 'Bandingkan film ${movie.title ?? ""}',
                        child: Container(
                          width: AppDimens.buttonSize,
                          height: AppDimens.buttonSize,
                          decoration: BoxDecoration(
                            color: Colors.white.withAlpha(225),
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
                            tooltip: 'Compare movie',
                            icon: const Icon(
                              Icons.compare_arrows_rounded,
                              color: Color(0xFF0F172A),
                              size: AppDimens.iconSize,
                            ),
                            onPressed: () {
                              Navigator.pushNamed(
                                context,
                                '/compare',
                                arguments: movie.swapiId,
                              );
                            },
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: AppDimens.buttonSpacing),
                    BlocBuilder<BookmarkBloc, BookmarkState>(
                      buildWhen: (prev, curr) {
                        if (prev is BookmarkLoaded && curr is BookmarkLoaded) {
                          final prevFav = prev.isFavorite(movie.swapiId);
                          final currFav = curr.isFavorite(movie.swapiId);
                          return prevFav != currFav;
                        }
                        return prev.runtimeType != curr.runtimeType;
                      },
                      builder: (context, bState) {
                        final isFav = bState is BookmarkLoaded &&
                            bState.isFavorite(movie.swapiId);
                        final movieTitle = movie.title ?? 'Movie';
                        return Center(
                          child: Semantics(
                            button: true,
                            label: isFav
                                ? 'Hapus $movieTitle dari film tersimpan'
                                : 'Simpan $movieTitle ke film tersimpan',
                            toggled: isFav,
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              width: AppDimens.buttonSize,
                              height: AppDimens.buttonSize,
                              decoration: BoxDecoration(
                                color: isFav
                                    ? AppColors.primaryYellow
                                    : Colors.white.withAlpha(225),
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
                                tooltip: isFav
                                    ? 'Remove from saved'
                                    : 'Save movie',
                                icon: Icon(
                                  isFav
                                      ? Icons.bookmark
                                      : Icons.bookmark_border,
                                  color: isFav
                                      ? AppColors.deepSlate
                                      : const Color(0xFF0F172A),
                                  size: AppDimens.iconSize,
                                ),
                                onPressed: () {
                                  context
                                      .read<BookmarkBloc>()
                                      .add(ToggleBookmark(movie.swapiId));
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        isFav
                                            ? 'Removed from saved'
                                            : 'Saved to watchlist',
                                      ),
                                      duration: const Duration(seconds: 1),
                                      backgroundColor:
                                          const Color(0xFF0F172A),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(width: 8),
                  ],
                  flexibleSpace: FlexibleSpaceBar(
                    background: Stack(
                      fit: StackFit.expand,
                      children: [
                        Image.asset(
                          movie.posterAsset,
                          fit: BoxFit.cover,
                          cacheWidth: 800,
                          errorBuilder: (_, __, ___) => Container(
                            color: const Color(0xFFF1F5F9),
                            child: const Center(
                              child: Icon(Icons.movie,
                                  size: 60, color: AppColors.primaryYellow),
                            ),
                          ),
                        ),
                        Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.transparent,
                                Colors.white.withAlpha(140),
                                Colors.white,
                              ],
                            ),
                          ),
                        ),
                        Positioned(
                          left: 16,
                          right: 16,
                          bottom: 12,
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Container(
                                width: 100,
                                height: 145,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                    color: AppColors.primaryYellow,
                                    width: 2,
                                  ),
                                  boxShadow: const [
                                    BoxShadow(
                                      color: Color(0x1F000000),
                                      blurRadius: 10,
                                    )
                                  ],
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image.asset(
                                    movie.posterAsset,
                                    fit: BoxFit.cover,
                                    cacheWidth: 200,
                                    cacheHeight: 290,
                                    errorBuilder: (_, __, ___) => Container(
                                      color: const Color(0xFFF1F5F9),
                                      child: const Center(
                                        child: Icon(Icons.movie,
                                            size: 32,
                                            color: AppColors.primaryYellow),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8, vertical: 3),
                                      decoration: BoxDecoration(
                                        color: AppColors.primaryYellow,
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Text(
                                        'Episode ${movie.episodeId}',
                                        style: const TextStyle(
                                          color: Color(0xFF0F172A),
                                          fontSize: AppDimens.captionSmall,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      '${movie.title}',
                                      style: const TextStyle(
                                        color: Color(0xFF0F172A),
                                        fontSize: AppDimens.titleMain,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      '$year • ${movie.duration}',
                                      style: const TextStyle(
                                        color: Color(0xFF64748B),
                                        fontSize: AppDimens.captionSmall,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      'Directed by ${movie.director}',
                                      style: const TextStyle(
                                        color: Color(0xFF64748B),
                                        fontSize: AppDimens.captionSmall,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Semantics(
                                button: true,
                                label:
                                    'Atur pengingat jadwal nonton film ${movie.title ?? ""}',
                                child: ElevatedButton.icon(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.primaryYellow,
                                    foregroundColor: const Color(0xFF0F172A),
                                    elevation: 0,
                                    minimumSize: const Size.fromHeight(
                                        AppDimens.buttonHeight),
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 14, vertical: 12),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                  onPressed: () => ScheduleDialog.show(
                                    context,
                                    initialMovieTitle: movie.title,
                                  ),
                                  icon: const Icon(Icons.alarm_add_rounded,
                                      size: AppDimens.iconSize,
                                      color: Color(0xFF0F172A)),
                                  label: const Text(
                                    'Set Reminder',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: AppDimens.textMain,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: AppDimens.buttonSpacing),
                            Expanded(
                              child: Semantics(
                                button: true,
                                label:
                                    'Cari bioskop terdekat untuk film ${movie.title ?? ""}',
                                child: OutlinedButton.icon(
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: const Color(0xFF0F172A),
                                    side: const BorderSide(
                                        color: Color(0xFFCBD5E1), width: 1.2),
                                    minimumSize: const Size.fromHeight(
                                        AppDimens.buttonHeight),
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 14, vertical: 12),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            const CinemaMapScreen(),
                                      ),
                                    );
                                  },
                                  icon: const Icon(Icons.location_on_outlined,
                                      size: AppDimens.iconSize,
                                      color: AppColors.deepSlate),
                                  label: const Text(
                                    'Find Cinemas',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: AppDimens.textMain,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 12),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF8FAFC),
                            borderRadius: BorderRadius.circular(12),
                            border:
                                Border.all(color: const Color(0xFFE2E8F0)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Overview',
                                style: TextStyle(
                                  color: Color(0xFF64748B),
                                  fontSize: AppDimens.captionSmall,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 0.8,
                                ),
                              ),
                              const SizedBox(height: 10),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  _buildQuickBadge(
                                    'Characters',
                                    '${movie.characters.length}',
                                    Icons.people_outline,
                                    const Color(0xFFF59E0B),
                                  ),
                                  _buildQuickBadge(
                                    'Planets',
                                    '${movie.planets.length}',
                                    Icons.public,
                                    AppColors.blue,
                                  ),
                                  _buildQuickBadge(
                                    'Starships',
                                    '${movie.starships.length}',
                                    Icons.rocket_launch_outlined,
                                    AppColors.deepSlate,
                                  ),
                                  _buildQuickBadge(
                                    'Vehicles',
                                    '${movie.vehicles.length}',
                                    Icons.directions_car_outlined,
                                    const Color(0xFF8B5CF6),
                                  ),
                                  _buildQuickBadge(
                                    'Species',
                                    '${movie.species.length}',
                                    Icons.pets_outlined,
                                    const Color(0xFFEC4899),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 22),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Synopsis',
                              style: TextStyle(
                                color: Color(0xFF0F172A),
                                fontSize: AppDimens.titleMain,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Container(
                              height: AppDimens.buttonHeight,
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF1F5F9),
                                borderRadius: BorderRadius.circular(
                                    AppDimens.buttonHeight / 2),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Semantics(
                                    button: true,
                                    selected: _show3dCrawl,
                                    label: 'Tampilan 3D Crawl',
                                    child: GestureDetector(
                                      behavior: HitTestBehavior.opaque,
                                      onTap: () {
                                        setState(() => _show3dCrawl = true);
                                      },
                                      child: AnimatedContainer(
                                        duration:
                                            const Duration(milliseconds: 200),
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 12, vertical: 7),
                                        decoration: BoxDecoration(
                                          color: _show3dCrawl
                                              ? const Color(0xFF0F172A)
                                              : Colors.transparent,
                                          borderRadius: BorderRadius.circular(
                                              (AppDimens.buttonHeight - 8) / 2),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Icon(
                                              Icons.view_in_ar_rounded,
                                              size: 15,
                                              color: _show3dCrawl
                                                  ? Colors.white
                                                  : const Color(0xFF64748B),
                                            ),
                                            const SizedBox(width: 4),
                                            Text(
                                              '3D Crawl',
                                              style: TextStyle(
                                                fontSize: AppDimens.captionSmall,
                                                fontWeight: FontWeight.bold,
                                                color: _show3dCrawl
                                                    ? Colors.white
                                                    : const Color(0xFF64748B),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  Semantics(
                                    button: true,
                                    selected: !_show3dCrawl,
                                    label: 'Tampilan Teks Biasa',
                                    child: GestureDetector(
                                      behavior: HitTestBehavior.opaque,
                                      onTap: () {
                                        setState(() => _show3dCrawl = false);
                                      },
                                      child: AnimatedContainer(
                                        duration:
                                            const Duration(milliseconds: 200),
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 12, vertical: 7),
                                        decoration: BoxDecoration(
                                          color: !_show3dCrawl
                                              ? const Color(0xFF0F172A)
                                              : Colors.transparent,
                                          borderRadius: BorderRadius.circular(
                                              (AppDimens.buttonHeight - 8) / 2),
                                        ),
                                        child: Text(
                                          'Plain Text',
                                          style: TextStyle(
                                            fontSize: AppDimens.captionSmall,
                                            fontWeight: FontWeight.bold,
                                            color: !_show3dCrawl
                                                ? Colors.white
                                                : const Color(0xFF64748B),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        if (_show3dCrawl)
                          StarWarsCrawlView(
                            title: movie.title ?? 'STAR WARS',
                            episodeId: movie.episodeId ?? 1,
                            openingCrawl: movie.openingCrawl ?? '',
                            onFullscreen: () => StarWarsCrawlDialog.show(
                              context,
                              title: movie.title ?? 'STAR WARS',
                              episodeId: movie.episodeId ?? 1,
                              openingCrawl: movie.openingCrawl ?? '',
                            ),
                          )
                        else
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF8FAFC),
                              borderRadius: BorderRadius.circular(12),
                              border:
                                  Border.all(color: const Color(0xFFE2E8F0)),
                            ),
                            child: Text(
                              movie.cleanedOpeningCrawl,
                              textAlign: TextAlign.justify,
                              style: const TextStyle(
                                color: Color(0xFF334155),
                                fontSize: AppDimens.textMain,
                                height: 1.65,
                              ),
                            ),
                          ),

                        const SizedBox(height: 24),
                        const Text(
                          'Production Details',
                          style: TextStyle(
                            color: Color(0xFF0F172A),
                            fontSize: AppDimens.titleMain,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF8FAFC),
                            borderRadius: BorderRadius.circular(12),
                            border:
                                Border.all(color: const Color(0xFFE2E8F0)),
                          ),
                          child: Column(
                            children: [
                              _buildInfoRow('Director', '${movie.director}'),
                              const Divider(
                                  color: Color(0xFFE2E8F0), height: 18),
                              _buildInfoRow('Producer', '${movie.producer}'),
                              const Divider(
                                  color: Color(0xFFE2E8F0), height: 18),
                              _buildInfoRow('Release Date',
                                  _formatReleaseDate(movie.releaseDate)),
                              const Divider(
                                  color: Color(0xFFE2E8F0), height: 18),
                              _buildInfoRow('Runtime', movie.duration),
                            ],
                          ),
                        ),

                        const SizedBox(height: 24),
                        _buildSectionHeader('Characters', count: movie.characters.length),
                        const SizedBox(height: 10),
                        FutureBuilder<List<People>>(
                          future: MovieProvider().characters(movie.characters),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return const Center(
                                child: Padding(
                                  padding: EdgeInsets.all(16.0),
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: AppColors.primaryYellow,
                                  ),
                                ),
                              );
                            }
                            final people = snapshot.data;
                            if (people == null || people.isEmpty) {
                              return const Text(
                                'No characters listed',
                                style: TextStyle(
                                  color: Color(0xFF94A3B8),
                                  fontSize: 12,
                                  fontStyle: FontStyle.italic,
                                ),
                              );
                            }
                            return SizedBox(
                              height: 100,
                              child: ListView.separated(
                                scrollDirection: Axis.horizontal,
                                itemCount: people.length,
                                separatorBuilder: (_, __) =>
                                    const SizedBox(width: 10),
                                itemBuilder: (context, idx) {
                                  final p = people[idx];
                                  return Container(
                                    width: 90,
                                    padding: const EdgeInsets.all(6),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFF8FAFC),
                                      borderRadius: BorderRadius.circular(10),
                                      border: Border.all(
                                          color: const Color(0xFFE2E8F0)),
                                    ),
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        CircleAvatar(
                                          radius: 18,
                                          backgroundColor:
                                              AppColors.primaryYellow
                                                  .withAlpha(60),
                                          child: const Icon(
                                            Icons.person,
                                            size: 20,
                                            color: AppColors.iconDarkAccent,
                                          ),
                                        ),
                                        const SizedBox(height: 6),
                                        Text(
                                          '${p.name}',
                                          style: const TextStyle(
                                            color: Color(0xFF0F172A),
                                            fontSize: AppDimens.captionSmall,
                                            fontWeight: FontWeight.bold,
                                          ),
                                          textAlign: TextAlign.center,
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                            );
                          },
                        ),

                        const SizedBox(height: 24),
                        _buildSectionHeader('Planets & Locations', count: movie.planets.length),
                        const SizedBox(height: 10),
                        FutureBuilder<List<Planets>>(
                          future: MovieProvider().planets(movie.planets),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return const SizedBox(
                                height: 38,
                                child: Align(
                                  alignment: Alignment.centerLeft,
                                  child: SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: AppColors.primaryYellow,
                                    ),
                                  ),
                                ),
                              );
                            }
                            final planets = snapshot.data;
                            if (planets == null || planets.isEmpty) {
                              return const Text(
                                'No planets listed',
                                style: TextStyle(
                                  color: Color(0xFF94A3B8),
                                  fontSize: 12,
                                  fontStyle: FontStyle.italic,
                                ),
                              );
                            }
                            return SizedBox(
                              height: 38,
                              child: ListView.separated(
                                scrollDirection: Axis.horizontal,
                                itemCount: planets.length,
                                separatorBuilder: (_, __) =>
                                    const SizedBox(width: 8),
                                itemBuilder: (context, idx) {
                                  final pl = planets[idx];
                                  return Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 12, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFF8FAFC),
                                      borderRadius: BorderRadius.circular(20),
                                      border: Border.all(
                                          color: const Color(0xFFE2E8F0)),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Icon(Icons.public,
                                            size: 16, color: AppColors.iconAccent),
                                        const SizedBox(width: 6),
                                        Text(
                                          '${pl.name} (${pl.climate ?? 'Unknown'})',
                                          style: const TextStyle(
                                            color: Color(0xFF334155),
                                            fontSize: 12,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                            );
                          },
                        ),

                        const SizedBox(height: 24),
                        _buildSectionHeader('Starships', count: movie.starships.length),
                        const SizedBox(height: 10),
                        FutureBuilder<List<Starships>>(
                          future: MovieProvider().starships(movie.starships),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return const SizedBox(
                                height: 38,
                                child: Align(
                                  alignment: Alignment.centerLeft,
                                  child: SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: AppColors.primaryYellow,
                                    ),
                                  ),
                                ),
                              );
                            }
                            final ships = snapshot.data;
                            if (ships == null || ships.isEmpty) {
                              return const Text(
                                'No starships listed',
                                style: TextStyle(
                                  color: Color(0xFF94A3B8),
                                  fontSize: 12,
                                  fontStyle: FontStyle.italic,
                                ),
                              );
                            }
                            return SizedBox(
                              height: 38,
                              child: ListView.separated(
                                scrollDirection: Axis.horizontal,
                                itemCount: ships.length,
                                separatorBuilder: (_, __) =>
                                    const SizedBox(width: 8),
                                itemBuilder: (context, idx) {
                                  final s = ships[idx];
                                  return Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 12, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFF8FAFC),
                                      borderRadius: BorderRadius.circular(20),
                                      border: Border.all(
                                          color: const Color(0xFFE2E8F0)),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Icon(Icons.flight,
                                            size: 16, color: AppColors.iconAccent),
                                        const SizedBox(width: 6),
                                        Text(
                                          '${s.name}',
                                          style: const TextStyle(
                                            color: Color(0xFF334155),
                                            fontSize: 12,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                            );
                          },
                        ),

                        if (movie.vehicles.isNotEmpty) ...[
                          const SizedBox(height: 24),
                          _buildSectionHeader('Vehicles', count: movie.vehicles.length),
                          const SizedBox(height: 10),
                          FutureBuilder<List<Vehicles>>(
                            future: MovieProvider().vehicles(movie.vehicles),
                            builder: (context, snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return const SizedBox(
                                  height: 38,
                                  child: Align(
                                    alignment: Alignment.centerLeft,
                                    child: SizedBox(
                                      width: 16,
                                      height: 16,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: AppColors.primaryYellow,
                                      ),
                                    ),
                                  ),
                                );
                              }
                              final vList = snapshot.data;
                              if (vList == null || vList.isEmpty) {
                                return const Text(
                                  'No vehicles listed',
                                  style: TextStyle(
                                    color: Color(0xFF94A3B8),
                                    fontSize: 12,
                                    fontStyle: FontStyle.italic,
                                  ),
                                );
                              }
                              return SizedBox(
                                height: 38,
                                child: ListView.separated(
                                  scrollDirection: Axis.horizontal,
                                  itemCount: vList.length,
                                  separatorBuilder: (_, __) =>
                                      const SizedBox(width: 8),
                                  itemBuilder: (context, idx) {
                                    final v = vList[idx];
                                    return Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 12, vertical: 6),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFF8FAFC),
                                        borderRadius:
                                            BorderRadius.circular(20),
                                        border: Border.all(
                                            color: const Color(0xFFE2E8F0)),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          const Icon(Icons.commute,
                                              size: 16,
                                              color: AppColors.iconAccent),
                                          const SizedBox(width: 6),
                                          Text(
                                            '${v.name}',
                                            style: const TextStyle(
                                              color: Color(0xFF334155),
                                              fontSize: 12,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                ),
                              );
                            },
                          ),
                        ],

                        if (movie.species.isNotEmpty) ...[
                          const SizedBox(height: 24),
                          _buildSectionHeader('Species', count: movie.species.length),
                          const SizedBox(height: 10),
                          FutureBuilder<List<Species>>(
                            future: MovieProvider().species(movie.species),
                            builder: (context, snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return const SizedBox(
                                  height: 38,
                                  child: Align(
                                    alignment: Alignment.centerLeft,
                                    child: SizedBox(
                                      width: 16,
                                      height: 16,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: AppColors.primaryYellow,
                                      ),
                                    ),
                                  ),
                                );
                              }
                              final spList = snapshot.data;
                              if (spList == null || spList.isEmpty) {
                                return const Text(
                                  'No species listed',
                                  style: TextStyle(
                                    color: Color(0xFF94A3B8),
                                    fontSize: 12,
                                    fontStyle: FontStyle.italic,
                                  ),
                                );
                              }
                              return SizedBox(
                                height: 38,
                                child: ListView.separated(
                                  scrollDirection: Axis.horizontal,
                                  itemCount: spList.length,
                                  separatorBuilder: (_, __) =>
                                      const SizedBox(width: 8),
                                  itemBuilder: (context, idx) {
                                    final sp = spList[idx];
                                    return Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 12, vertical: 6),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFF8FAFC),
                                        borderRadius:
                                            BorderRadius.circular(20),
                                        border: Border.all(
                                            color: const Color(0xFFE2E8F0)),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          const Icon(Icons.fingerprint,
                                              size: 16,
                                              color: AppColors.iconAccent),
                                          const SizedBox(width: 6),
                                          Text(
                                            '${sp.name} (${sp.classification ?? 'Unknown'})',
                                            style: const TextStyle(
                                              color: Color(0xFF334155),
                                              fontSize: 12,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                ),
                              );
                            },
                          ),
                        ],

                        const SizedBox(height: 32),
                      ],
                    ),
                  ),
                ),
              ],
            );
          } else if (state is MovieError) {
            return Scaffold(
              backgroundColor: Colors.white,
              appBar: AppBar(
                backgroundColor: Colors.white,
                elevation: 0,
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back, color: Color(0xFF0F172A)),
                  tooltip: 'Back',
                  onPressed: () => Navigator.pop(context),
                ),
              ),
              body: AppErrorView(
                error: state.error,
                onRetry: () => movieB.add(FetchMovie(widget.id)),
              ),
            );
          }
          return const SizedBox();
        },
      ),
    );
  }

  String _formatReleaseDate(DateTime? date) {
    if (date == null) return '-';
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December'
    ];
    final month = (date.month >= 1 && date.month <= 12)
        ? months[date.month - 1]
        : '${date.month}';
    return '${date.day} $month ${date.year}';
  }

  Widget _buildQuickBadge(
    String label,
    String count,
    IconData icon,
    Color color,
  ) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.all(7),
          decoration: BoxDecoration(
            color: color.withAlpha(25),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, size: 16, color: color),
        ),
        const SizedBox(height: 4),
        Text(
          count,
          style: const TextStyle(
            color: Color(0xFF0F172A),
            fontSize: AppDimens.textMain,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            color: Color(0xFF64748B),
            fontSize: AppDimens.captionSmall,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 100,
          child: Text(
            label,
            style: const TextStyle(
              color: Color(0xFF64748B),
              fontSize: AppDimens.captionSmall,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            value,
            textAlign: TextAlign.end,
            style: const TextStyle(
              color: Color(0xFF0F172A),
              fontWeight: FontWeight.bold,
              fontSize: AppDimens.textMain,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSectionHeader(String title, {int? count}) {
    return Row(
      children: [
        Text(
          title,
          style: const TextStyle(
            color: Color(0xFF0F172A),
            fontSize: AppDimens.titleMain,
            fontWeight: FontWeight.bold,
          ),
        ),
        if (count != null && count > 0) ...[
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              '$count',
              style: const TextStyle(
                color: Color(0xFF64748B),
                fontSize: AppDimens.captionSmall,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ],
    );
  }
}
