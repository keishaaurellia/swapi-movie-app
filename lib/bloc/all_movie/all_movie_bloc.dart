import 'package:equatable/equatable.dart';
import 'package:cinemax_app/bloc/export.dart';
import '../bloc_transformers.dart';

part 'all_movie_event.dart';
part 'all_movie_state.dart';

class AllMovieBloc extends Bloc<AllMovieEvent, AllMovieState> {
  final MovieProvider movieProvider;
  List<Movie> _rawMovies = [];

  AllMovieBloc(this.movieProvider) : super(AllMovieInitial()) {
    on<FetchAllMovie>(
      (event, emit) async {
        emit(AllMovieLoading());
        try {
          final result = await movieProvider.getAllMovie();
          _rawMovies = result;
          emit(AllMovieLoaded(_rawMovies));
        } catch (e) {
          emit(AllMovieError(e.toString()));
        }
      },
    );

    on<SearchMovie>(
      (event, emit) {
        final currentState = state;
        if (currentState is AllMovieLoaded) {
          emit(AllMovieLoaded(
            _rawMovies.isNotEmpty ? _rawMovies : currentState.listMovie,
            searchQuery: event.query,
          ));
        }
      },
      transformer: debounceRestartable(const Duration(milliseconds: 500)),
    );
  }
}
