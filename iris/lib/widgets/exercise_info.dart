import 'package:flutter/material.dart';
import 'package:frontend/viewmodels/app_state_viewmodel.dart';
import '../models/tracking_models/exercise_specifications.dart';
import '../viewmodels/exercise_list_viewmodel.dart';
import '../viewmodels/exercise_viewmodel.dart';
import '../views/exercise_tracking_view.dart';
import 'package:provider/provider.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

class ExerciseInfo extends StatefulWidget {
  final List<String> images;
  final ExerciseViewModel exercise;
  final AppStateViewModel appState;

  const ExerciseInfo({
    super.key,
    required this.images,
    required this.exercise,
    required this.appState,
  });

  @override
  State<ExerciseInfo> createState() => _ExerciseInfoState();
}

class _ExerciseInfoState extends State<ExerciseInfo> {
  // for embedded tutorial
  late final String videoId;
  late final YoutubePlayerController _controller;
  Widget? _cachedVideo;

  @override
  void initState() {
    super.initState();
    videoId = YoutubePlayer.convertUrlToId(widget.exercise.tutorialLink)!;
    _controller = YoutubePlayerController(
      initialVideoId: videoId,
      flags: const YoutubePlayerFlags(autoPlay: false, mute: false),
    );

    _cachedVideo = EmbeddedVideo(videoId: videoId, controller: _controller);
  }

  @override
  Widget build(BuildContext context) {
    final specs = context.read<Map<String, ExerciseSpecifications>>();
    final corrections = context.read<Map<String, dynamic>>();
    final jointMap = context.read<Map<String, List<int>>>();
    final bodyVecMap = context.read<Map<String, List<int>>>();

    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const SizedBox.shrink(), // Cleaner than empty padding
            Text(widget.exercise.exerciseName),
            MaterialButton(
              padding: EdgeInsets.zero,
              onPressed: () {
                widget.appState.exerciseIsFavorite(widget.exercise)
                    ? widget.appState.removeExerciseFromFavorites(widget.exercise)
                    : widget.appState.addExerciseToFavorites(widget.exercise);
              },
              child: Icon(
                widget.appState.exerciseIsFavorite(widget.exercise)
                    ? Icons.favorite
                    : Icons.favorite_border,
                size: 40,
              ),
            ),
          ],
        ),
        titleTextStyle: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 30,
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          // <--- 1. Add this
          padding: const EdgeInsets.all(
            20,
          ), // Move padding here for better scroll behavior
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min, // Allows column to wrap content
            children: [
              _cachedVideo!, // Manual spacing if using older Flutter, or keep spacing: 20
              ExerciseInfoCard(exercise: widget.exercise),
              const SizedBox(height: 20),
              Center(
                child: MaterialButton(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  color: Colors.lightBlue,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 30,
                    vertical: 10,
                  ),
                  child: const Text(
                    "Start Exercise",
                    style: TextStyle(fontSize: 40),
                  ),
                  onPressed: () {
                    Navigator.of(context, rootNavigator: true).push(
                      MaterialPageRoute(
                        builder: (context) => ExerciseTrackingView(
                          exercise: widget.exercise,
                          specs: specs,
                          corrections: corrections,
                          jointMap: jointMap,
                          bodyVecMap: bodyVecMap,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
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
            Center(
              child: Text(
                exercise.exerciseName,
                style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold),
              ),
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
