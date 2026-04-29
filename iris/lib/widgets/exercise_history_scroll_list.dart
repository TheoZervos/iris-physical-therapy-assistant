import 'package:flutter/material.dart';
import 'package:frontend/models/exercise_session.dart';
import '../utils/utils.dart';
import '../viewmodels/viewmodels_lib.dart';
import '../views/exercise_info_view.dart';
import 'package:provider/provider.dart';

class ExerciseHistoryListTile extends StatelessWidget {
  final ExerciseSession session;

  const ExerciseHistoryListTile({super.key, required this.session});

  @override
  Widget build(BuildContext context) {
    final exercise = context.watch<ExerciseViewModel>();
    final userInfo = context.watch<UserInfoViewModel>();

    return ListTile(
      minTileHeight: 110,
      title: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            SafeArea(
              minimum: EdgeInsets.all(5),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    "${session.date.month}-${session.date.day}",
                    style: TextStyle(fontSize: 35, fontWeight: FontWeight.bold),
                  ),
                  Text("${session.date.year}"),
                ],
              ),
            ),
            Text(
              exercise.exerciseName,
              style: TextStyle(fontSize: 35, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            SafeArea(
              minimum: EdgeInsets.all(5),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    "${session.sessionLength.inMinutes}:${formatSeconds(session.sessionLength.inSeconds)}",
                    style: TextStyle(fontSize: 35, fontWeight: FontWeight.bold),
                  ),
                  Text("Duration"),
                ],
              ),
            ),
          ],
        ),
      ),
      onTap: () {
        Navigator.of(context, rootNavigator: true).push(
          MaterialPageRoute(
            builder: (context) => ExerciseInfoView(
              exercise: exercise,
              favoriteExercises: userInfo.favoriteExercises,
            ),
          ),
        );
      },
    );
  }
}

class ExerciseHistoryScrollList extends StatelessWidget {
  final AppStateViewModel appState;

  const ExerciseHistoryScrollList({super.key, required this.appState});

  @override
  Widget build(BuildContext context) {
    UserInfoViewModel userInfo = appState.userInfo;
    ExerciseHistoryViewModel exerciseHistory = userInfo.exerciseHistory;
    if (exerciseHistory.exerciseHistory.exerciseSessions.isEmpty) {
      return SliverFillRemaining(
        hasScrollBody:
            false, // Prevents unnecessary scroll behavior for a spinner
        child: Center(
          child: SizedBox(
            width: MediaQuery.sizeOf(context).width * 0.8,
            child: Text(
              "There are no past exercise sessions to display.\nPlease track an exercise to add it to your history.",
              style: TextStyle(fontSize: 18),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      );
    }

    return SliverList(
      delegate: SliverChildListDelegate(
        exerciseHistory.exerciseHistory.exerciseSessions.map((session) {
          return ChangeNotifierProvider<ExerciseViewModel>.value(
            value: ExerciseViewModel(session.sessionExercise),
            child: ChangeNotifierProvider<UserInfoViewModel>.value(
              value: userInfo,
              child: ExerciseHistoryListTile(session: session),
            ),
          );
        }).toList(),
      ),
    );
  }
}
