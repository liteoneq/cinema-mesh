import 'package:flutter/material.dart';
import '../models/film.dart';
import '../services/mesh.dart';
import '../services/chunk_manager.dart';

class UploadScreen extends StatefulWidget {
  const UploadScreen({super.key});

  @override
  State<UploadScreen> createState() => _UploadScreenState();
}

class _UploadScreenState extends State<UploadScreen> {
  final MeshService _mesh = MeshService();
  final ChunkManager _chunkManager = ChunkManager();
  final TextEditingController _titleController = TextEditingController();
  FilmQuality _selectedQuality = FilmQuality.p480;
  int _selectedHours = 24;
  bool _isUploading = false;

  final List<int> _durationOptions = [6, 12, 24, 48];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A1A2E),
        title: const Text(
          'رفع فيلم',
          style: TextStyle(color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // اسم الفيلم
            const Text(
              'اسم الفيلم',
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _titleController,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                filled: true,
                fillColor: const Color(0xFF1A1A2E),
                hintText: 'أدخل اسم الفيلم',
                hintStyle: const TextStyle(color: Colors.grey),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 24),

            // الدقة
            const Text(
              'دقة الفيلم',
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 8),
            Row(
              children: FilmQuality.values.map((q) {
                final isSelected = _selectedQuality == q;
                return Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _selectedQuality = q),
                    child: Container(
                      margin: const EdgeInsets.only(right: 8),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? const Color(0xFF6C63FF)
                            : const Color(0xFF1A1A2E),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        q.name,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: isSelected ? Colors.white : Colors.grey,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 24),

            // مدة الصلاحية
            const Text(
              'مدة الصلاحية',
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 8),
            Row(
              children: _durationOptions.map((h) {
                final isSelected = _selectedHours == h;
                return Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _selectedHours = h),
                    child: Container(
                      margin: const EdgeInsets.only(right: 8),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? const Color(0xFF6C63FF)
                            : const Color(0xFF1A1A2E),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${h}س',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: isSelected ? Colors.white : Colors.grey,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 40),

            // زر الرفع
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6C63FF),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: _isUploading ? null : _uploadFilm,
                child: _isUploading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                        'رفع إلى الشبكة',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _uploadFilm() async {
    if (_titleController.text.isEmpty) return;

    setState(() => _isUploading = true);

    final film = Film(
      filmId: DateTime.now().millisecondsSinceEpoch.toString(),
      ownerId: 'owner_local',
      title: _titleController.text,
      quality: _selectedQuality,
      totalChunks: 0,
      createdAt: DateTime.now(),
      expiresAt: DateTime.now().add(Duration(hours: _selectedHours)),
    );

    await _mesh.uploadFilm(film: film, chunks: []);

    setState(() => _isUploading = false);

    if (mounted) Navigator.pop(context);
  }

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }
}
