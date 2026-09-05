part of 'all_movie_bloc.dart';

abstract class AllMovieState extends Equatable {
  const AllMovieState();

  @override
  List<Object> get props => [];
}

class AllMovieInitial extends AllMovieState {}

class AllMovieLoading extends AllMovieState {}

class AllMovieLoaded extends AllMovieState {
  final List<Movie> listMovie;
  final String searchQuery;
  const AllMovieLoaded(this.listMovie, {this.searchQuery = ''});

  @override
  List<Object> get props => [listMovie, searchQuery];
}

class AllMovieError extends AllMovieState {
  final String error;
  const AllMovieError(this.error);

  @override
  List<Object> get props => [error];
}
