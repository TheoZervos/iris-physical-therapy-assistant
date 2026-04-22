import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:frontend/viewmodels/viewmodels_lib.dart';
import 'package:frontend/widgets/exercise_scroll_list.dart';

class FavoriteExerciseSearchView extends StatefulWidget {
  const FavoriteExerciseSearchView({super.key});

  @override
  State<FavoriteExerciseSearchView> createState() => _FavoriteExerciseSearchViewState();
}

class _FavoriteExerciseSearchViewState extends State<FavoriteExerciseSearchView> {
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
          title: SearchBar(
            leading: Icon(Icons.search),
            hintText: "Search favorite exercises...",
            controller: textController,
          ),
        ),
        ExerciseScrollList(
          exercises: userInfo.favoriteExercises,
          userInfo: userInfo
        ),
      ],
    );
  }
}
