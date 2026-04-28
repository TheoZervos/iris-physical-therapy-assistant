import 'package:flutter/material.dart';
import 'package:frontend/main.dart';
import '../viewmodels/viewmodels_lib.dart';
import '../views/exercise_info_view.dart';
import 'package:provider/provider.dart';

class ExerciseListTile extends StatelessWidget {
  const ExerciseListTile({super.key});

  @override
  Widget build(BuildContext context) {
    final exercise = context.watch<ExerciseViewModel>();
    final userInfo = context.watch<UserInfoViewModel>();
    final appState = context.watch<AppStateViewModel>();

    return ListTile(
      minTileHeight: 110,
      title: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            SizedBox(
              width: 100,
              height: 100,
              child: Image(
                image: AssetImage(
                  '${exercise.assetsFolder}/${exercise.exerciseName.toLowerCase().replaceAll(" ", "_")}_thumbnail.png',
                ),
              ),
            ),
            Column(
              children: [
                Text(
                  exercise.exerciseName,
                  style: TextStyle(fontSize: 35, fontWeight: FontWeight.bold),
                ),
                Text(
                  exercise.muscleRegions.join(', '),
                  style: TextStyle(fontSize: 13),
                ),
              ],
            ),
            MaterialButton(
              padding: EdgeInsets.zero,
              onPressed: () {
                appState.exerciseIsFavorite(exercise)
                    ? appState.removeExerciseFromFavorites(exercise)
                    : appState.addExerciseToFavorites(exercise);
              },
              child: Icon(
                appState.exerciseIsFavorite(exercise) ? Icons.favorite : Icons.favorite_border,
                size: 40,
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

class ExerciseScrollList extends StatelessWidget {
  final AppStateViewModel appState;
  final bool isFavoritesList;

  const ExerciseScrollList({
    super.key,
    required this.appState,
    required this.isFavoritesList,
  });

  @override
  Widget build(BuildContext context) {
    late final ExerciseListViewModel exercises;
    final userInfo = appState.userInfo;
    if (isFavoritesList) {
      exercises = userInfo.favoriteExercises;
    } else {
      exercises = appState.allExercises;
    }

    if (exercises.exerciseList.isEmpty) {
      return const SliverFillRemaining(
        hasScrollBody:
            false, // Prevents unnecessary scroll behavior for a spinner
        child: Center(
          child: Text("This list is empty.", style: TextStyle(fontSize: 18)),
        ),
      );
    }

    return SliverList(
      delegate: SliverChildListDelegate(
        exercises.exerciseList.map((exercise) {
          return ChangeNotifierProvider<ExerciseViewModel>.value(
            value: exercise,
            child: ChangeNotifierProvider<UserInfoViewModel>.value(
              value: userInfo,
              child: ChangeNotifierProvider<AppStateViewModel>.value(
                value: appState,
                child: const ExerciseListTile(),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
