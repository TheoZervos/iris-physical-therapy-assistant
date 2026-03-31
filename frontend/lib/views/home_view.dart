import 'package:flutter/cupertino.dart';
import 'package:frontend/viewmodels/app_state_viewmodel.dart';
import 'package:provider/provider.dart';
import 'package:frontend/viewmodels/viewmodels_lib.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  late final AppStateViewModel appState;

  @override
  void initState() {
    super.initState();
    appState = Provider.of<AppStateViewModel>(context, listen: false);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      appState.loadAppState('assets/user_data', 'assets/all_exercises.json');
    });
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(middle: Text('Home')),
      child: Center(child: Text('Welcome to the Home View')),
    );
  }
}
