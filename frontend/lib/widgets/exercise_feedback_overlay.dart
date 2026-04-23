import 'package:flutter/material.dart';
import 'package:frontend/models/tracking_models/formatted_tracking_feedback.dart';

class ExerciseFeedbackOverlay extends StatelessWidget {
  final AsyncSnapshot<FormattedTrackingFeedback> dataSnapshot;

  ExerciseFeedbackOverlay({required this.dataSnapshot});

  @override
  Widget build(BuildContext context) {
    // error state
    if (dataSnapshot.hasError) {
      return Center(child: Text('Error: ${dataSnapshot.error}'));
    }

    // waiting/loading
    if (dataSnapshot.connectionState == ConnectionState.waiting) {
      return Center(child: CircularProgressIndicator());
    }

    // active/data
    if (dataSnapshot.hasData) {
      Color feedbackColor;
      switch (dataSnapshot.data!.severity) {
        case ("info"):
          feedbackColor = Colors.yellow.shade300;
        case ("warning"):
          feedbackColor = Colors.red.shade700;
        default:
          feedbackColor = Colors.green.shade800;
      }

      return ClipRRect(
        clipBehavior: Clip.antiAlias,
        borderRadius: BorderRadius.circular(30),
        child:  Container(
          color: feedbackColor,
          child: Center(
            child: Text(
              dataSnapshot.data?.correctionMessage != null
                  ? dataSnapshot.data!.correctionMessage
                  : "No correction",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.black, fontSize: 40),
            ),
          ),
        ),
      );
    }

    // no data
    return Center(child: Text('Something went wrong! No data found!'));
  }
}
