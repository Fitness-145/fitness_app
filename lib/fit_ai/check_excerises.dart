
import 'package:fitness_app/fit_ai/model/pushups.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

dynamic getBloc(String  workout, BuildContext context) {

  switch(workout){
    case 'pushups':
      return  BlocProvider.of<PushUpCounter>(context);
        
    case 'pullups':
      return  BlocProvider.of<PushUpCounter>(context);
    default:
      return  BlocProvider.of<PushUpCounter>(context);     

}
}