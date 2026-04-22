import "package:flutter/material.dart";
import "package:provider/provider.dart";
import "package:frontend/viewmodels/user_info_viewmodel.dart";
import "package:frontend/widgets/exercise_history_scroll_list.dart";

class ExerciseHistoryView extends StatefulWidget {
  const ExerciseHistoryView({super.key});

  @override
  State<ExerciseHistoryView> createState() => _ExerciseHistoryViewState();
}

class _ExerciseHistoryViewState extends State<ExerciseHistoryView> {
  late TextEditingController textController;

  @override
  void initState() {
    super.initState();
    textController = TextEditingController();
  }

  @override
  Widget build(BuildContext context) {
    final UserInfoViewModel userInfo = Provider.of<UserInfoViewModel>(context);

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
        ExerciseHistoryScrollList(
          userInfo: userInfo,
        ),
      ],
    );
  }
}
