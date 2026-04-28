import 'package:flutter/material.dart';
import '../models/exercise_history.dart';
import '../viewmodels/viewmodels_lib.dart';
import '../views/exercise_info_view.dart';
import 'package:provider/provider.dart';

class ExerciseHistoryListTile extends StatelessWidget {
  const ExerciseHistoryListTile({super.key});

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
            Center(
              child: Text(
                exercise.exerciseName,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            )
          ],
        ),
      ),
      onTap: () {
        Navigator.of(context, rootNavigator: true).push(
          MaterialPageRoute(
            builder: (context) => ExerciseInfoView(exercise: exercise, favoriteExercises: userInfo.favoriteExercises),
          ),
        );
      },
    );
  }
}

class ExerciseHistoryScrollList extends StatelessWidget {
  final UserInfoViewModel userInfo;

  const ExerciseHistoryScrollList({
    super.key,
    required this.userInfo,
  });

  @override
  Widget build(BuildContext context) {
    ExerciseHistory exerciseHistory = userInfo.exerciseHistory.exerciseHistory;
    if (exerciseHistory.exerciseSessions.isEmpty) {
      return SliverFillRemaining(
        hasScrollBody: false, // Prevents unnecessary scroll behavior for a spinner
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
        exerciseHistory.exerciseSessions.map((session) {
          return const ExerciseHistoryListTile();
        }).toList(),
      ),
    );
  }
}
