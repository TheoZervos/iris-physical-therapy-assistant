import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/viewmodels_lib.dart';
import '../widgets/exercise_scroll_list.dart';

class FavoriteExerciseSearchView extends StatefulWidget {
  const FavoriteExerciseSearchView({super.key});

  @override
  State<FavoriteExerciseSearchView> createState() => _FavoriteExerciseSearchViewState();
}

class _FavoriteExerciseSearchViewState extends State<FavoriteExerciseSearchView> {

  @override
  Widget build(BuildContext context) {
    final AppStateViewModel appState = Provider.of<AppStateViewModel>(context);

    return CustomScrollView(
      slivers: <Widget>[
        ExerciseScrollList(
          appState: appState,
          isFavoritesList: true,
        ),
      ],
    );
  }
}
