import "package:flutter/material.dart";
import "package:frontend/viewmodels/app_state_viewmodel.dart";
import "package:provider/provider.dart";
import "../widgets/exercise_history_scroll_list.dart";

class ExerciseHistoryView extends StatefulWidget {
  const ExerciseHistoryView({super.key});

  @override
  State<ExerciseHistoryView> createState() => _ExerciseHistoryViewState();
}

class _ExerciseHistoryViewState extends State<ExerciseHistoryView> {

  @override
  Widget build(BuildContext context) {
    final AppStateViewModel userInfo = Provider.of<AppStateViewModel>(context);

    return CustomScrollView(
      slivers: <Widget>[
        SliverAppBar(
          floating: true,
          snap: true,
          centerTitle: true,
        ),
        ExerciseHistoryScrollList(
          appState: userInfo,
        ),
      ],
    );
  }
}
