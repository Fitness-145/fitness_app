import 'package:flutter_bloc/flutter_bloc.dart';

enum SquatState {
  neutral,
  init,
  complete,
}

class SquatCounter extends Cubit<SquatState> {
  SquatCounter() : super(SquatState.neutral);
  int counter = 0;

  void setSquatState(SquatState current) {
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
