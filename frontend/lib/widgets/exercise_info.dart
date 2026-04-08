import 'package:flutter/material.dart';
import 'package:frontend/viewmodels/exercise_list_viewmodel.dart';
import 'package:frontend/viewmodels/exercise_viewmodel.dart';
import 'package:frontend/views/exercise_tracking_view.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

class ExerciseInfo extends StatefulWidget {
  final List<String> images;
  final ExerciseViewModel exercise;
  final ExerciseListViewModel favoriteExercises;

  const ExerciseInfo({
    super.key,
    required this.images,
    required this.exercise,
    required this.favoriteExercises,
  });

  @override
  State<ExerciseInfo> createState() => _ExerciseInfoState();
}

class _ExerciseInfoState extends State<ExerciseInfo> {
  // for embedded tutorial
  late final String videoId;
  late final YoutubePlayerController _controller;

  @override
  void initState() {
    super.initState();
    videoId = YoutubePlayer.convertUrlToId(widget.exercise.tutorialLink)!;
    _controller = YoutubePlayerController(
      initialVideoId: videoId,
      flags: const YoutubePlayerFlags(autoPlay: false, mute: false),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Padding(padding: EdgeInsets.all(0)),
            Text(widget.exercise.exerciseName),
            MaterialButton(
              padding: EdgeInsets.zero,
              onPressed: () {
                widget.exercise.isFavorite
                    ? widget.favoriteExercises.removeExercise(widget.exercise)
                    : widget.favoriteExercises.addExercise(widget.exercise);
                widget.exercise.toggleFavorite();
                setState(() {});
              },
              child: Icon(
                widget.exercise.isFavorite
                    ? Icons.favorite
                    : Icons.favorite_border,
                size: 40,
              ),
            ),
          ],
        ),
        titleTextStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 30),
        centerTitle: true,
      ),
      body: SafeArea(
        minimum: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 20,
          children: [
            EmbeddedVideo(videoId: videoId, controller: _controller),
            ExerciseInfoCard(exercise: widget.exercise),
            Center(
              child: MaterialButton(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                color: Colors.lightBlue,
                child: Text("Start Exercise", style: TextStyle(fontSize: 40)),
                onPressed: () {
                  Navigator.of(context, rootNavigator: true).push(
                    MaterialPageRoute(
                      builder: (context) => ExerciseTrackingView(exercise: widget.exercise),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}

class ExerciseInfoCard extends StatelessWidget {
  final ExerciseViewModel exercise;

  const ExerciseInfoCard({super.key, required this.exercise});

  @override
  Widget build(BuildContext context) {
    List<String> instructions = exercise.exerciseDescription.split('\n');

    return ClipRRect(
      clipBehavior: Clip.antiAlias,
      borderRadius: BorderRadius.circular(20),
      child: Card(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              exercise.exerciseName,
              style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold),
            ),
            ...instructions.map((instruction) {
              return Column(
                children: [
                  Text(instruction, style: TextStyle(fontSize: 20)),
                  Padding(padding: EdgeInsets.all(10)),
                ],
              );
            }),
            Text.rich(
              TextSpan(
                text: "Targets: ",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                children: [
                  ...exercise.muscleRegions.map((muscle) {
                    if (muscle == exercise.muscleRegions.last) {
                      return TextSpan(
                        text: muscle,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.normal,
                        ),
                      );
                    }

                    return TextSpan(
                      text: "$muscle, ",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.normal,
                      ),
                    );
                  }),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class EmbeddedVideo extends StatelessWidget {
  final String videoId;
  final YoutubePlayerController controller;

  const EmbeddedVideo({
    super.key,
    required this.videoId,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        width: MediaQuery.of(context).size.width * 0.8,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(30),
          clipBehavior: Clip.antiAlias,
          child: YoutubePlayerBuilder(
            player: YoutubePlayer(
              controller: controller,
              showVideoProgressIndicator: true,
              progressIndicatorColor: Colors.lightBlue,
            ),
            builder: (context, player) {
              return AspectRatio(aspectRatio: 16 / 9, child: player);
            },
          ),
        ),
      ),
    );
  }
}
