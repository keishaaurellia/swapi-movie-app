import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/providers/bookmark_provider.dart';

part 'bookmark_event.dart';
part 'bookmark_state.dart';

class BookmarkBloc extends Bloc<BookmarkEvent, BookmarkState> {
  final BookmarkProvider bookmarkProvider;

  BookmarkBloc(this.bookmarkProvider) : super(BookmarkInitial()) {
    on<LoadBookmarks>((event, emit) async {
      emit(BookmarkLoading());
      try {
        final list = await bookmarkProvider.getFavorites();
        emit(BookmarkLoaded(list.toSet()));
      } catch (_) {
        emit(const BookmarkLoaded(<int>{}));
      }
    });

    on<ToggleBookmark>((event, emit) async {
      try {
        await bookmarkProvider.toggleFavorite(event.movieId);
      } catch (_) {}
      final list = await bookmarkProvider.getFavorites();
      emit(BookmarkLoaded(list.toSet()));
    });
  }
}
