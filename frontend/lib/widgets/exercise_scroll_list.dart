import 'package:flutter/material.dart';
import 'package:frontend/viewmodels/viewmodels_lib.dart';
import 'package:frontend/views/exercise_info_view.dart';
import 'package:provider/provider.dart';

class ExerciseListTile extends StatelessWidget {
  const ExerciseListTile({super.key});

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
            SizedBox(
              width: 100,
              height: 100,
              child: Image(
                image: AssetImage(
                  '${exercise.assetsFolder}/${exercise.exerciseName.toLowerCase().replaceAll(" ", "_")}_thumbnail.png',
                ),
              )
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
                exercise.isFavorite
                    ? userInfo.favoriteExercises.removeExercise(exercise)
                    : userInfo.favoriteExercises.addExercise(exercise);
                exercise.toggleFavorite();
              },
              child: Icon(
                exercise.isFavorite ? Icons.favorite : Icons.favorite_border,
                size: 40,
              ),
            ),
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

class ExerciseScrollList extends StatelessWidget {
  final ExerciseListViewModel exercises;
  final UserInfoViewModel userInfo;

  const ExerciseScrollList({
    super.key,
    required this.exercises,
    required this.userInfo,
  });

  @override
  Widget build(BuildContext context) {
    if (exercises.exerciseList.isEmpty) {
      return const SliverFillRemaining(
        hasScrollBody: false, // Prevents unnecessary scroll behavior for a spinner
        child: Center(
          child: Text(
            "This list is empty.",
            style: TextStyle(fontSize: 18),
          ),
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
              child: const ExerciseListTile(),
            ),
          );
        }).toList(),
      ),
    );
  }
}
