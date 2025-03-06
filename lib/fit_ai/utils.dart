import 'dart:io';
import 'dart:math' as math;


import 'package:fitness_app/fit_ai/model/pull_ups.dart';
import 'package:fitness_app/fit_ai/model/pushups.dart';
import 'package:fitness_app/fit_ai/model/squat_model.dart';
import 'package:flutter/services.dart';
import 'package:google_ml_kit/google_ml_kit.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

Future<String> getAssetPath(String asset) async {
  final path = await getLocalPath(asset);
  await Directory(dirname(path)).create(recursive: true);
  final file = File(path);
  if (!await file.exists()) {
    final byteData = await rootBundle.load(asset);
    await file.writeAsBytes(byteData.buffer
        .asUint8List(byteData.offsetInBytes, byteData.lengthInBytes));
  }
  return file.path;
}

Future<String> getLocalPath(String path) async {
  return '${(await getApplicationSupportDirectory()).path}/$path';
}


double angle(
  PoseLandmark firstLandmark,
  PoseLandmark midLandmark,
  PoseLandmark lastLandmark,
) {
  final radians = 
      math.atan2(lastLandmark.y - midLandmark.y, lastLandmark.x - midLandmark.x) -
      math.atan2(firstLandmark.y - midLandmark.y, firstLandmark.x - midLandmark.x);
  
  double degrees = radians * 180.0 / math.pi;
  degrees = degrees.abs();
  
  if (degrees > 180.0) {
    degrees = 360.0 - degrees;
  }

  return degrees;
}


PushUpState? isPushUp(double angleElbow, PushUpState current) {
  final umbralElbow = 60.0;
  final umbralElbowExt = 160.0;

  if (current == PushUpState.neutral && angleElbow > umbralElbowExt && angleElbow < 180.0) {
    return PushUpState.init;
  } else if (current == PushUpState.init && angleElbow < umbralElbow && angleElbow > 0.0) {
    return PushUpState.complete;
  }

  
}

PullUpState? isPullUp(double elbowAngle, PullUpState current) {
  const startAngleThreshold = 160.0; // Elbow almost straight (start)
  const completeAngleThreshold = 60.0; // Elbow bent (chin up)

  if (current == PullUpState.neutral && elbowAngle < startAngleThreshold) {
    return PullUpState.init;
  } else if (current == PullUpState.init && elbowAngle < completeAngleThreshold) {
    return PullUpState.complete;
  }

  
}



double calculateAngle(
  PoseLandmark firstLandmark,
  PoseLandmark midLandmark,
  PoseLandmark lastLandmark,
) {
  final radians =
      math.atan2(lastLandmark.y - midLandmark.y, lastLandmark.x - midLandmark.x) -
      math.atan2(firstLandmark.y - midLandmark.y, firstLandmark.x - midLandmark.x);

  double degrees = radians * 180.0 / math.pi;
  degrees = degrees.abs();

  if (degrees > 180.0) {
    degrees = 360.0 - degrees;
  }

  return degrees;
}

SquatState? isSquat(double kneeAngle, SquatState current) {
  const standingThreshold = 160.0; // Knee almost straight (standing)
  const squatThreshold = 60.0; // Knee bent (deep squat)

  if (current == SquatState.neutral && kneeAngle > standingThreshold) {
    print('standddddddddddddddddddddddddddddddddddddddddddddddddddddddddd');
    return SquatState.init; // Standing position detected
  } else if (current == SquatState.init && kneeAngle < squatThreshold) {
        print('------------------------------------------------------');

    return SquatState.complete; // Squat completed
  }

  return null;
}








