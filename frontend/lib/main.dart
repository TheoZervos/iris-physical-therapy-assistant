import 'package:flutter/material.dart';
import "package:provider/provider.dart";
import "package:frontend/viewmodels/app_state_viewmodel.dart";
import 'package:frontend/views/home_view.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final AppStateViewModel appState = AppStateViewModel();
  await appState.loadAppState('assets/user_data', 'assets/all_exercises.json');

  runApp(
    ChangeNotifierProvider(
      create: (context) => appState,
      child: const App(),
    ),
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
