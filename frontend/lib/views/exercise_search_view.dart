import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:frontend/viewmodels/app_state_viewmodel.dart';
import 'package:frontend/widgets/exercise_scroll_list.dart';

class ExerciseSearchView extends StatefulWidget {
  const ExerciseSearchView({super.key});

  @override
  State<ExerciseSearchView> createState() => _ExerciseSearchViewState();
}

class _ExerciseSearchViewState extends State<ExerciseSearchView> {
  late TextEditingController textController;

  @override
  void initState() {
    super.initState();
    textController = TextEditingController();
  }

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppStateViewModel>(context);
    return CustomScrollView(
      slivers: <Widget>[
        SliverAppBar(
          floating: true,
          snap: true,
          centerTitle: true,
          title: SearchBar(
            leading: Icon(Icons.search),
            hintText: "Search exercises...",
            controller: textController,
          ),
        ),
        ExerciseScrollList(
          exercises: appState.allExercises,
          userInfo: appState.userInfo,
        ),
      ],
    );
  }
}
