enum ChunkStatus { active, sleeping, deleted }

class Chunk {
  final String chunkId;
  final String filmId;
  final String ownerId;
  final int chunkIndex;
  final int totalChunks;
  final DateTime createdAt;
  final DateTime expiresAt;
  ChunkStatus status;
  final String checksum;
  final List<int> data;

  Chunk({
    required this.chunkId,
    required this.filmId,
    required this.ownerId,
    required this.chunkIndex,
    required this.totalChunks,
    required this.createdAt,
    required this.expiresAt,
    this.status = ChunkStatus.active,
    required this.checksum,
    required this.data,
  });

  bool get isExpired =>
      DateTime.now().isAfter(expiresAt);

  bool get isActive =>
      status == ChunkStatus.active && !isExpired;

  void checkAndUpdateStatus() {
    if (isExpired && status == ChunkStatus.active) {
      status = ChunkStatus.sleeping;
    }
  }

  Map<String, dynamic> toJson() => {
    'chunkId': chunkId,
    'filmId': filmId,
    'ownerId': ownerId,
    'chunkIndex': chunkIndex,
    'totalChunks': totalChunks,
    'createdAt': createdAt.toIso8601String(),
    'expiresAt': expiresAt.toIso8601String(),
    'status': status.name,
    'checksum': checksum,
  };
