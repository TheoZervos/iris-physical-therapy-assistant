import 'package:flutter/material.dart';
import 'core/mapping_constants.dart';
import "package:provider/provider.dart";
import "viewmodels/viewmodels_lib.dart";
import 'views/home_view.dart';
import 'package:permission_handler/permission_handler.dart';
import 'service_locator.dart';
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

  final specs = await ExerciseTrackingMapping.loadExerciseSpecifications('assets/exercise_specifications.json',);
  final corrections = await ExerciseTrackingMapping.loadCorrectionMessages('assets/exercise_corrections.json');
  final jointMap = ExerciseTrackingMapping.jointMap;
  final bodyVecMap = ExerciseTrackingMapping.bodyVectorsMap;
  final exerciseMap = await ExerciseTrackingMapping.loadExerciseMap('assets/all_exercises.json');

  //getting camera
  late final CameraDescription frontCamera;
  try {
    final cameras = await availableCameras();
    if (cameras.isNotEmpty) {
      frontCamera = cameras.firstWhere(
        (camera) => camera.lensDirection == CameraLensDirection.front,
        orElse: () => cameras.first,
      );
    } else {
      debugPrint("No cameras found!");
    }
  } catch (e) {
    debugPrint("Camera hardware failed: $e");
  }

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: appState),
        Provider.value(value: frontCamera),
        Provider.value(value: specs),
        Provider.value(value: corrections),
        Provider.value(value: jointMap),
        Provider.value(value: bodyVecMap),
        Provider.value(value: exerciseMap),
      ],
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
    while (!cameraStatus.isGranted) {
      if (!cameraStatus.isGranted) {
        await Permission.camera.request();
      }
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
