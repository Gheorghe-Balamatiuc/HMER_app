import 'dart:developer';

import 'package:flutter_bloc/flutter_bloc.dart';

/// Custom BLoC observer for debugging purposes
/// Logs various BLoC lifecycle events to the console
class ProductBlocObserver extends BlocObserver {
  const ProductBlocObserver();

  /// Called when a new event is added to a bloc
  @override
  void onEvent(Bloc<dynamic, dynamic> bloc, Object? event) {
    super.onEvent(bloc, event);
    log('onEvent $event');
  }

  /// Called when a bloc's state changes
  @override
  void onChange(BlocBase<dynamic> bloc, Change<dynamic> change) {
    super.onChange(bloc, change);
    log('onChange $change');
  }

  /// Called when a bloc transitions from one state to another
  @override
  void onTransition(
    Bloc<dynamic, dynamic> bloc,
    Transition<dynamic, dynamic> transition,
  ) {
    super.onTransition(bloc, transition);
    log('onTransition $transition');
  }

  /// Called when an error occurs in a bloc
  @override
  void onError(BlocBase<dynamic> bloc, Object error, StackTrace stackTrace) {
    super.onError(bloc, error, stackTrace);
    log('onError $error');
  }
}