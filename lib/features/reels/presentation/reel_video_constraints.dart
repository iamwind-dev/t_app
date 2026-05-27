const int maxReelVideoDurationSeconds = 60;

String? validateReelVideoDuration(Duration duration) {
  if (duration.inMilliseconds <= maxReelVideoDurationSeconds * 1000) {
    return null;
  }

  return 'Reel video must be 60 seconds or shorter.';
}
