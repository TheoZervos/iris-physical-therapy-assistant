import 'package:flutter/material.dart';
import 'package:frontend/core/mapping_constants.dart';
import "package:provider/provider.dart";
import "package:frontend/viewmodels/app_state_viewmodel.dart";
import 'package:frontend/views/home_view.dart';
import 'package:frontend/service_locator.dart';

void main() async {
  // starting backend
  WidgetsFlutterBinding.ensureInitialized();
  await setupLocator();
  final AppStateViewModel appState = AppStateViewModel();
  await appState.loadAppState();
  await ExerciseTrackingMapping.loadExerciseSpecifications('assets/exercise_specifications.json');
  await ExerciseTrackingMapping.loadCorrectionMessages('assets/exercise_corrections.json');
  await ExerciseTrackingMapping.loadExerciseMap('assets/all_exercises.json');

  runApp(
    ChangeNotifierProvider(create: (context) => appState, child: const App()),
  );
}

class App extends StatelessWidget {
  const App({super.key});

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
