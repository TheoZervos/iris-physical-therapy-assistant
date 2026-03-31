import 'package:flutter/cupertino.dart';
import "package:provider/provider.dart";
import "package:frontend/viewmodels/app_state_viewmodel.dart";
import 'package:frontend/views/home_view.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => AppStateViewModel(),
      child: const App(),
    ),
  );
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return CupertinoApp(
      title: "Iris: Physical Therapy Assistant",
      debugShowCheckedModeBanner: true,
      theme: CupertinoThemeData(),
      home: const HomeView(),
    );
  }
}
