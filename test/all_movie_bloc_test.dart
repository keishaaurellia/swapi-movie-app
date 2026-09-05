import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:cinemax_app/bloc/all_movie/all_movie_bloc.dart';
import 'package:cinemax_app/bloc/export.dart';

class MockMovieProvider extends MovieProvider {
  final List<Movie> mockMovies;
  MockMovieProvider(this.mockMovies);

  @override
  Future<List<Movie>> getAllMovie() async => mockMovies;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final List<Movie> testMovies = [
    Movie.fromJson({
      'title': 'A New Hope',
      'episode_id': 4,
      'opening_crawl': 'It is a period of civil war...',
      'director': 'George Lucas',
      'producer': 'Gary Kurtz, Rick McCallum',
      'release_date': '1977-05-25',
      'url': 'https://swapi.dev/api/films/1/',
    }),
    Movie.fromJson({
      'title': 'The Empire Strikes Back',
      'episode_id': 5,
      'opening_crawl': 'It is a dark time for the Rebellion...',
      'director': 'Irvin Kershner',
      'producer': 'Gary Kurtz, Rick McCallum',
      'release_date': '1980-05-21',
      'url': 'https://swapi.dev/api/films/2/',
    }),
  ];

  group('AllMovieBloc & Debounce Event Transformer Tests', () {
    test('initial state is AllMovieInitial', () {
      final provider = MockMovieProvider(testMovies);
      final bloc = AllMovieBloc(provider);
      expect(bloc.state, equals(AllMovieInitial()));
      bloc.close();
    });

    blocTest<AllMovieBloc, AllMovieState>(
      'emits [AllMovieLoading, AllMovieLoaded] when FetchAllMovie is added',
      build: () => AllMovieBloc(MockMovieProvider(testMovies)),
      act: (bloc) => bloc.add(FetchAllMovie()),
      expect: () => [
        AllMovieLoading(),
        AllMovieLoaded(testMovies, searchQuery: ''),
      ],
    );

    test('debounces rapid SearchMovie events and only emits the last query after 500ms',
        () async {
      final bloc = AllMovieBloc(MockMovieProvider(testMovies));
      bloc.add(FetchAllMovie());
      await Future.delayed(const Duration(milliseconds: 50));

      final states = <AllMovieState>[];
      final subscription = bloc.stream.listen(states.add);

      bloc.add(const SearchMovie('E'));
      await Future.delayed(const Duration(milliseconds: 100));
      bloc.add(const SearchMovie('Em'));
      await Future.delayed(const Duration(milliseconds: 100));
      bloc.add(const SearchMovie('Emp'));
      await Future.delayed(const Duration(milliseconds: 100));
      bloc.add(const SearchMovie('Empire'));

      await Future.delayed(const Duration(milliseconds: 300));
      expect(
        states.whereType<AllMovieLoaded>().where((s) => s.searchQuery.isNotEmpty).length,
        equals(0),
        reason: 'Should not emit state while user is still typing within debounce duration',
      );

      await Future.delayed(const Duration(milliseconds: 300));

      final loadedSearchStates =
          states.whereType<AllMovieLoaded>().where((s) => s.searchQuery.isNotEmpty).toList();
      expect(loadedSearchStates.length, equals(1));
      expect(loadedSearchStates.first.searchQuery, equals('Empire'));

      await subscription.cancel();
      await bloc.close();
    });
  });
}
