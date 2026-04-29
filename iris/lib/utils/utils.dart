String formatSeconds(int timeInSeconds) {
  var seconds = timeInSeconds % 60;

  if (seconds >= 10) {
    return "$seconds";
  } else {
    return "0$seconds";
  }
}
