import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:cinemax_app/app.dart';
import 'package:cinemax_app/general_observer.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  Bloc.observer = MyObserver();
  runApp(const App());
}
