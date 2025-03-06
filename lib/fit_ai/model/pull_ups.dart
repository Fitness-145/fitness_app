import 'package:flutter_bloc/flutter_bloc.dart';

enum PullUpState {
  neutral,
  init,
  complete,
}

class PullUpCounter extends Cubit<PullUpState> {
  PullUpCounter() : super(PullUpState.neutral);
  int counter = 0;

  void setPullUpState(PullUpState current) {
    emit(current);
  }


  void increment() {
    counter++;
    emit(state);
  }

  void reset() {
    counter = 0;
    emit(state);
  }
}


