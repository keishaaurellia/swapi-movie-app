part of 'maps_bloc.dart';

abstract class MapsEvent extends Equatable {
  const MapsEvent();

  @override
  List<Object?> get props => [];
}

class FetchCurrentLocation extends MapsEvent {}

class SelectCinema extends MapsEvent {
  final Cinema cinema;
  const SelectCinema(this.cinema);

  @override
  List<Object?> get props => [cinema];
}
