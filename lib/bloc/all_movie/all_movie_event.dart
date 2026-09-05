part of 'all_movie_bloc.dart';

abstract class AllMovieEvent extends Equatable {
  const AllMovieEvent();

  @override
  List<Object> get props => [];
}

class FetchAllMovie extends AllMovieEvent {}

class SearchMovie extends AllMovieEvent {
  final String query;
  const SearchMovie(this.query);

  @override
  List<Object> get props => [query];
}
