import 'package:bloc/bloc.dart';
import 'package:flutter/foundation.dart';

class MyObserver extends BlocObserver {
  @override
  void onChange(BlocBase bloc, Change change) {
    super.onChange(bloc, change);
    try {
      debugPrint("$bloc => $change");
    } catch (_) {}
  }

  @override
  void onError(BlocBase bloc, Object error, StackTrace stackTrace) {
    super.onError(bloc, error, stackTrace);
    debugPrint("$bloc => $error");
    debugPrint("$bloc => $stackTrace");
  }

  @override
  void onTransition(Bloc bloc, Transition transition) {
    super.onTransition(bloc, transition);
    try {
      debugPrint("$bloc => $transition");
    } catch (_) {}
  }
}
