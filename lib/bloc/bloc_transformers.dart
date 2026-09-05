import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:stream_transform/stream_transform.dart';

const Duration defaultDebounceDuration = Duration(milliseconds: 500);
EventTransformer<Event> debounceRestartable<Event>([
  Duration duration = defaultDebounceDuration,
]) {
  return (events, mapper) => events.debounce(duration).switchMap(mapper);
}
