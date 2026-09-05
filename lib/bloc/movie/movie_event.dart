part of 'movie_bloc.dart';

abstract class MovieEvent extends Equatable {
  const MovieEvent();

  @override
  List<Object> get props => [];
}

class FetchMovie extends MovieEvent {
  final int id;
  const FetchMovie(this.id);

  @override
  List<Object> get props => [id];
}
