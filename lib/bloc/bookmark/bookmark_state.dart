part of 'bookmark_bloc.dart';

abstract class BookmarkState extends Equatable {
  const BookmarkState();

  @override
  List<Object?> get props => [];
}

class BookmarkInitial extends BookmarkState {}

class BookmarkLoading extends BookmarkState {}

class BookmarkLoaded extends BookmarkState {
  final Set<int> favoriteIds;
  const BookmarkLoaded(this.favoriteIds);

  bool isFavorite(int movieId) => favoriteIds.contains(movieId);

  @override
  List<Object?> get props => [favoriteIds.toList()..sort()];
}

class BookmarkError extends BookmarkState {
  final String message;
  const BookmarkError(this.message);

  @override
  List<Object?> get props => [message];
}
