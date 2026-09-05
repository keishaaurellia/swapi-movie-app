part of 'bookmark_bloc.dart';

abstract class BookmarkEvent extends Equatable {
  const BookmarkEvent();

  @override
  List<Object?> get props => [];
}

class LoadBookmarks extends BookmarkEvent {
  const LoadBookmarks();
}

class ToggleBookmark extends BookmarkEvent {
  final int movieId;
  const ToggleBookmark(this.movieId);

  @override
  List<Object?> get props => [movieId];
}
