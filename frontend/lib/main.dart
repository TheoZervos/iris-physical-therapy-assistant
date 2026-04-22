import 'package:flutter/material.dart';
import 'package:frontend/core/mapping_constants.dart';
import 'package:frontend/viewmodels/app_state_viewmodel.dart';
import "package:provider/provider.dart";
import "package:frontend/viewmodels/viewmodels_lib.dart";
import 'package:frontend/views/home_view.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:frontend/service_locator.dart';
import 'package:camera/camera.dart';

late final List<CameraDescription> cameras;
late UserInfoViewModel userInfo;
late final ExerciseListViewModel allExercises;

void main() async {
  // starting backend
  WidgetsFlutterBinding.ensureInitialized();
  await setupLocator();
  final AppStateViewModel appState = AppStateViewModel();
  await appState.loadAppState();
  await ExerciseTrackingMapping.loadExerciseSpecifications(
    'assets/exercise_specifications.json',
  );
  await ExerciseTrackingMapping.loadCorrectionMessages(
    'assets/exercise_corrections.json',
  );
  await ExerciseTrackingMapping.loadExerciseMap('assets/all_exercises.json');

  runApp(
    ChangeNotifierProvider(
      create: (context) => appState,
      child: const IrisApp(),
    ),
  );
}

class IrisApp extends StatefulWidget {
  const IrisApp({super.key});

  @override
  State<IrisApp> createState() => _IrisAppState();
}

class _IrisAppState extends State<IrisApp> {
  @override
  void initState() {
    super.initState();
    requestCameraPermission();
  }

  void requestCameraPermission() async {
    var cameraStatus = await Permission.camera.status;
    if (!cameraStatus.isGranted) {
      await Permission.camera.request();
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Iris: Physical Therapy Assistant",
      debugShowCheckedModeBanner: true,
      theme: ThemeData.dark(),
      home: const HomeView(),
    );
  }
}
