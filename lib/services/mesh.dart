import 'dart:async';
import '../models/chunk.dart';
import '../models/film.dart';
import 'bluetooth.dart';
import 'chunk_manager.dart';

class MeshService {
  final BluetoothService _bluetooth = BluetoothService();
  final ChunkManager _chunkManager = ChunkManager();
  final Map<String, Film> _films = {};
  final StreamController<Film> _filmController =
      StreamController.broadcast();

  Stream<Film> get filmStream => _filmController.stream;
  List<Film> get availableFilms => _films.values
      .where((f) => !f.isExpired)
      .toList();

  // بدء الشبكة
  Future<void> start() async {
    await _bluetooth.enable();
    await _bluetooth.startScan();
    _listenForChunks();
    _startCleanupTimer();
  }

  // الاستماع للأجزاء القادمة
  void _listenForChunks() {
    _bluetooth.receivedChunkStream.listen((chunk) {
      _processReceivedChunk(chunk);
    });
  }

  // معالجة جزء مستقبل
  void _processReceivedChunk(Chunk chunk) {
    if (chunk.isExpired) return;

    final film = _films[chunk.filmId];
    if (film != null) {
      film.chunks.add(chunk);
      _filmController.add(film);
    }
  }

  // رفع فيلم جديد
  Future<void> uploadFilm({
    required Film film,
    required List<Chunk> chunks,
  }) async {
    _films[film.filmId] = film;

    // توزيع الأجزاء على الأجهزة القريبة
    for (final device in _bluetooth.nearbyDevices) {
      for (final chunk in chunks) {
        await _bluetooth.sendChunk(
          device: device,
          chunk: chunk,
        );
      }
    }

    _filmController.add(film);
  }

  // إعادة رفع فيلم
  Future<void> reuploadFilm({
    required String filmId,
    required DateTime newExpiresAt,
  }) async {
    final film = _films[filmId];
    if (film == null) return;

    // إيقاظ الأجزاء النائمة
    _chunkManager.wakeChunks(filmId);

    // تحديث وقت الانتهاء
    final chunks = _chunkManager.getActiveChunks(filmId);
    for (final device in _bluetooth.nearbyDevices) {
      for (final chunk in chunks) {
        await _bluetooth.sendChunk(
          device: device,
          chunk: chunk,
        );
      }
    }
  }

  // حساب مدة النوم
  Duration calculateSleepDuration(Film film) {
    return film.sleepDuration;
  }

  // تنظيف دوري كل 30 دقيقة
  void _startCleanupTimer() {
    Timer.periodic(const Duration(minutes: 30), (_) {
      _chunkManager.cleanExpiredChunks();
      _updateFilmStatuses();
    });
  }

  void _updateFilmStatuses() {
    for (final film in _films.values) {
      if (film.isExpired && !film.isPlaying) {
        // إشعار المستخدم
        _filmController.add(film);
      }
    }
  }

  // حذف فيلم نهائياً
  void deleteFilm(String filmId) {
    _chunkManager.deleteFilm(filmId);
    _films.remove(filmId);
  }

  void dispose() {
    _bluetooth.dispose();
    _filmController.close();
  }
}
