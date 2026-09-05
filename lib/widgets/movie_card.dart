import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../data/models/movie.dart';
import '../data/config/app_colors.dart';
import '../data/config/app_dimens.dart';
import '../bloc/bookmark/bookmark_bloc.dart';
class MovieCard extends StatelessWidget {
  final Movie movie;
  final int index;
  final VoidCallback onTap;

  const MovieCard({
    super.key,
    required this.movie,
    required this.index,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final movieTitle = movie.title ?? 'Movie';

    return Semantics(
      button: true,
      label: 'Film $movieTitle, Episode ${movie.episodeId}',
      child: GestureDetector(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x18000000),
                      blurRadius: 10,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      Image.asset(
                        movie.posterAsset,
                        fit: BoxFit.cover,
                        cacheWidth: 300,
                        errorBuilder: (_, __, ___) => Container(
                          color: AppColors.surface,
                          child: const Center(
                            child: Icon(
                              Icons.movie_outlined,
                              size: 36,
                              color: AppColors.teal,
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        top: 8,
                        left: 8,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.black.withAlpha(180),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            'EP ${movie.episodeId}',
                            style: const TextStyle(
                              color: AppColors.primaryYellow,
                              fontSize: AppDimens.captionSmall,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        top: 8,
                        right: 8,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Semantics(
                              button: true,
                              label: 'Bandingkan film $movieTitle',
                              child: Tooltip(
                                message: 'Compare',
                                child: GestureDetector(
                                  behavior: HitTestBehavior.opaque,
                                  onTap: () {
                                    Navigator.pushNamed(
                                      context,
                                      '/compare',
                                      arguments: movie.swapiId,
                                    );
                                  },
                                  child: Container(
                                    width: AppDimens.buttonSize,
                                    height: AppDimens.buttonSize,
                                    decoration: BoxDecoration(
                                      color: Colors.white.withAlpha(240),
                                      shape: BoxShape.circle,
                                      boxShadow: const [
                                        BoxShadow(
                                          color: Color(0x30000000),
                                          blurRadius: 6,
                                          offset: Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                    child: const Center(
                                      child: Icon(
                                        Icons.compare_arrows,
                                        size: AppDimens.iconSize,
                                        color: AppColors.slate,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: AppDimens.buttonSpacing),
                            BlocBuilder<BookmarkBloc, BookmarkState>(
                              builder: (context, state) {
                                final isFav = state is BookmarkLoaded &&
                                    state.isFavorite(movie.swapiId);
                                return Semantics(
                                  button: true,
                                  label: isFav
                                      ? 'Hapus $movieTitle dari film tersimpan'
                                      : 'Simpan $movieTitle ke film tersimpan',
                                  toggled: isFav,
                                  child: Tooltip(
                                    message: isFav ? 'Remove from Saved' : 'Save Movie',
                                    child: GestureDetector(
                                      behavior: HitTestBehavior.opaque,
                                      onTap: () {
                                        context
                                            .read<BookmarkBloc>()
                                            .add(ToggleBookmark(movie.swapiId));
                                        ScaffoldMessenger.of(context)
                                            .hideCurrentSnackBar();
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(
                                            content: Text(
                                              isFav
                                                  ? '$movieTitle removed from Favorites'
                                                  : '$movieTitle added to Favorites',
                                            ),
                                            duration: const Duration(seconds: 1),
                                            backgroundColor: const Color(0xFF0F172A),
                                          ),
                                        );
                                      },
                                      child: AnimatedContainer(
                                        duration: const Duration(milliseconds: 200),
                                        width: AppDimens.buttonSize,
                                        height: AppDimens.buttonSize,
                                        decoration: BoxDecoration(
                                          color: isFav
                                              ? AppColors.primaryYellow
                                              : Colors.white.withAlpha(240),
                                          shape: BoxShape.circle,
                                          boxShadow: const [
                                            BoxShadow(
                                              color: Color(0x30000000),
                                              blurRadius: 6,
                                              offset: Offset(0, 2),
                                            ),
                                          ],
                                        ),
                                        child: Center(
                                          child: Icon(
                                            isFav
                                                ? Icons.bookmark
                                                : Icons.bookmark_border,
                                            size: AppDimens.iconSize,
                                            color: isFav
                                                ? AppColors.deepSlate
                                                : AppColors.slate,
                                          ),
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
                  ),
                ),
              ),
            ),
          const SizedBox(height: 8),
          Text(
            (movie.title ?? 'Movie').toUpperCase(),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: AppColors.deepSlate,
              fontSize: AppDimens.textMain,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            'Episode ${movie.episodeId}',
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: AppColors.darkAmber,
              fontSize: AppDimens.captionSmall,
              fontWeight: FontWeight.w600,
              fontStyle: FontStyle.italic,
            ),
          ),
          if (movie.formattedReleaseDate.isNotEmpty) ...[
            const SizedBox(height: 2),
            Text(
              movie.formattedReleaseDate,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: AppColors.slate,
                fontSize: AppDimens.captionSmall,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: AppColors.border),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.rocket_launch,
                        size: 11, color: AppColors.teal),
                    const SizedBox(width: 3),
                    Text(
                      '${movie.starships.length}',
                      style: const TextStyle(
                        color: AppColors.deepSlate,
                        fontSize: AppDimens.captionSmall,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 4),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: AppColors.border),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.public,
                        size: 11, color: Color(0xFF3B82F6)),
                    const SizedBox(width: 3),
                    Text(
                      '${movie.planets.length}',
                      style: const TextStyle(
                        color: AppColors.deepSlate,
                        fontSize: AppDimens.captionSmall,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 4),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: AppColors.border),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.people,
                        size: 11, color: Color(0xFFF59E0B)),
                    const SizedBox(width: 3),
                    Text(
                      '${movie.characters.length}',
                      style: const TextStyle(
                        color: AppColors.deepSlate,
                        fontSize: AppDimens.captionSmall,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    ),
  );
}
}
