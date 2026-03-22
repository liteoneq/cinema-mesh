import 'chunk.dart';

enum FilmQuality { p480, p720, p1080 }

class Film {
  final String filmId;
  final String ownerId;
  final String title;
  final FilmQuality quality;
  final int totalChunks;
  final DateTime createdAt;
  final DateTime expiresAt;
  final int activeUsers;
  final int viewCount;
  bool isPlaying;
  List<Chunk> chunks;

  Film({
    required this.filmId,
    required this.ownerId,
    required this.title,
    required this.quality,
    required this.totalChunks,
    required this.createdAt,
    required this.expiresAt,
    this.activeUsers = 0,
    this.viewCount = 0,
    this.isPlaying = false,
    this.chunks = const [],
  });

  bool get isExpired =>
      DateTime.now().isAfter(expiresAt);

  bool canWatch() {
    if (isPlaying) return true;
    return !isExpired;
  }

  double get activityScore {
    return (activeUsers * 0.4) + (viewCount * 0.6);
  }

  Duration get sleepDuration {
    if (activityScore > 100) return const Duration(days: 7);
    if (activityScore > 50)  return const Duration(days: 3);
    if (activityScore > 10)  return const Duration(days: 1);
    if (activityScore > 0)   return const Duration(hours: 6);
    return Duration.zero;
  }

  Map<String, dynamic> toJson() => {
    'filmId': filmId,
    'ownerId': ownerId,
    'title': title,
    'quality': quality.name,
    'totalChunks': totalChunks,
    'createdAt': createdAt.toIso8601String(),
    'expiresAt': expiresAt.toIso8601String(),
    'activeUsers': activeUsers,
    'viewCount': viewCount,
  };
}
