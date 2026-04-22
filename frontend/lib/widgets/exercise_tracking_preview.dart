import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

class ExerciseTrackingPreview extends StatefulWidget {
  final CameraDescription camera;
  const ExerciseTrackingPreview({super.key, required this.camera});

  @override
  State<ExerciseTrackingPreview> createState() =>
      _ExerciseTrackingPreviewState();
}

class _ExerciseTrackingPreviewState extends State<ExerciseTrackingPreview> {
  late CameraController _cameraController;

  @override
  void initState() {
    super.initState();
    _cameraController = CameraController(
      widget.camera,
      ResolutionPreset.max,
      enableAudio: false,
    );
    _cameraController
        .initialize()
        .then((_) {
          if (!mounted) return;
          setState(() {});
        })
        .catchError((e) {
          print("Error initializing camera: $e");
        });
  }

  @override
  void dispose() {
    _cameraController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    print(MediaQuery.of(context).orientation);
    return SafeArea(
      child: Column(
        spacing: 20,
        children: [
          // if camera is initialized, show preview, else show loading indicator
          _cameraController.value.isInitialized ?
            Expanded(
              child: ClipRRect(
                clipBehavior: Clip.antiAlias,
                borderRadius: BorderRadius.circular(30),
                child: AspectRatio(
                    aspectRatio: _cameraController.value.aspectRatio,
                    child: CameraPreview(_cameraController),
                  )
              )
            ) :  // uninitialized camera, 
            CircularProgressIndicator(),
          Text("Body tracking will go here", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),),
        ],
      ),
    );
  }
}
