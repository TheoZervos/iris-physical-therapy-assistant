import 'package:flutter/material.dart';
import '../viewmodels/app_state_viewmodel.dart';
import '../viewmodels/viewmodels_lib.dart';
import 'package:provider/provider.dart';
import '../widgets/exercise_scroll_list.dart';

class ExerciseSearchView extends StatefulWidget {
  const ExerciseSearchView({super.key});

  @override
  State<ExerciseSearchView> createState() => _ExerciseSearchViewState();
}

class _ExerciseSearchViewState extends State<ExerciseSearchView> {

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppStateViewModel>(context);

    if (!appState.isInitialized) {
      return Center(child: CircularProgressIndicator());
    }

    return CustomScrollView(
      slivers: <Widget>[
        ExerciseScrollList(
          appState: appState,
          isFavoritesList: false,
        ),
      ],
    );
  }
}
