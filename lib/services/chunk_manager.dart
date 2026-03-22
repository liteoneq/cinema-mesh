import 'dart:convert';
import 'dart:typed_data';
import 'package:crypto/crypto.dart';
import '../models/chunk.dart';
import '../models/film.dart';

class ChunkManager {
  static const int chunkSize = 65536; // 64KB
  final Map<String, List<Chunk>> _filmChunks = {};

  // تقطيع الفيلم إلى أجزاء
  List<Chunk> splitFilm({
    required String filmId,
    required String ownerId,
    required Uint8List filmData,
    required DateTime expiresAt,
  }) {
    final chunks = <Chunk>[];
    final totalChunks = (filmData.length / chunkSize).ceil();

    for (int i = 0; i < totalChunks; i++) {
      final start = i * chunkSize;
      final end = (start + chunkSize).clamp(0, filmData.length);
      final chunkData = filmData.sublist(start, end);
      final checksum = md5.convert(chunkData).toString();

      chunks.add(Chunk(
        chunkId: '${filmId}_$i',
        filmId: filmId,
        ownerId: ownerId,
        chunkIndex: i,
        totalChunks: totalChunks,
        createdAt: DateTime.now(),
        expiresAt: expiresAt,
        checksum: checksum,
        data: chunkData,
      ));
    }

    _filmChunks[filmId] = chunks;
    return chunks;
  }

  // تجميع الأجزاء
  Uint8List? assembleChunks(String filmId) {
    final chunks = _filmChunks[filmId];
    if (chunks == null) return null;

    final sorted = chunks
      ..sort((a, b) => a.chunkIndex.compareTo(b.chunkIndex));

    final result = <int>[];
    for (final chunk in sorted) {
      result.addAll(chunk.data);
    }
    return Uint8List.fromList(result);
  }

  // تنظيف الأجزاء المنتهية
  void cleanExpiredChunks() {
    for (final filmId in _filmChunks.keys) {
      final chunks = _filmChunks[filmId]!;
      for (final chunk in chunks) {
        chunk.checkAndUpdateStatus();
      }
    }
  }

  // الأجزاء الموجودة لفيلم معين
  List<Chunk> getActiveChunks(String filmId) {
    return _filmChunks[filmId]
        ?.where((c) => c.isActive)
        .toList() ?? [];
  }

  // إيقاظ الأجزاء النائمة
  void wakeChunks(String filmId) {
    final chunks = _filmChunks[filmId];
    if (chunks == null) return;
    for (final chunk in chunks) {
      if (chunk.status == ChunkStatus.sleeping) {
        chunk.status = ChunkStatus.active;
      }
    }
  }

  // حذف فيلم نهائياً
  void deleteFilm(String filmId) {
    _filmChunks.remove(filmId);
  }
}
