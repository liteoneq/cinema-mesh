import 'package:flutter/material.dart';
import '../models/film.dart';

class PlayerScreen extends StatefulWidget {
  final Film film;
  const PlayerScreen({super.key, required this.film});

  @override
  State<PlayerScreen> createState() => _PlayerScreenState();
}

class _PlayerScreenState extends State<PlayerScreen> {
  bool _isPlaying = false;
  double _progress = 0.0;
  bool _showExpiryWarning = false;

  @override
  void initState() {
    super.initState();
    widget.film.isPlaying = true;
    _checkExpiry();
  }

  void _checkExpiry() {
    final remaining = widget.film.expiresAt.difference(DateTime.now());

    // تحذير قبل 30 دقيقة
    if (remaining.inMinutes <= 30 && remaining.inMinutes > 0) {
      setState(() => _showExpiryWarning = true);
    }

    // انتهت الصلاحية أثناء المشاهدة
    if (remaining.isNegative && widget.film.isPlaying) {
      _showExpiredDialog();
    }
  }

  void _showExpiredDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A2E),
        title: const Text(
          '⏰ انتهت الصلاحية',
          style: TextStyle(color: Colors.white),
        ),
        content: const Text(
          'انتهت صلاحية الفيلم في الشبكة\nتكمل مشاهدتك حتى النهاية',
          style: TextStyle(color: Colors.grey),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'حسناً',
              style: TextStyle(color: Color(0xFF6C63FF)),
            ),
          ),
        ],
      ),
    );
  }

  void _showSaveDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A2E),
        title: const Text(
          '🎬 ماذا تريد أن تفعل؟',
          style: TextStyle(color: Colors.white),
        ),
        content: const Text(
          'انتهت صلاحية الفيلم في الشبكة',
          style: TextStyle(color: Colors.grey),
        ),
        actions: [
          // مفضلة
          TextButton.icon(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('✅ أُضيف للمفضلة')),
              );
            },
            icon: const Icon(Icons.star, color: Colors.amber),
            label: const Text(
              'مفضلة',
              style: TextStyle(color: Colors.amber),
            ),
          ),
          // حفظ
          TextButton.icon(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('💾 جاري الحفظ...')),
              );
            },
            icon: const Icon(Icons.download, color: Colors.green),
            label: const Text(
              'حفظ',
              style: TextStyle(color: Colors.green),
            ),
          ),
          // حذف
          TextButton.icon(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.delete, color: Colors.red),
            label: const Text(
              'حذف',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text(
          widget.film.title,
          style: const TextStyle(color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert, color: Colors.white),
            onPressed: _showSaveDialog,
          ),
        ],
      ),
      body: Column(
        children: [
          // منطقة الفيديو
          Expanded(
            child: Container(
              color: Colors.black,
              child: const Center(
                child: Icon(
                  Icons.play_circle_outline,
                  size: 80,
                  color: Colors.white54,
                ),
              ),
            ),
          ),

          // تحذير انتهاء الصلاحية
          if (_showExpiryWarning)
            Container(
              color: Colors.orange.withOpacity(0.2),
              padding: const EdgeInsets.all(8),
              child: const Row(
                children: [
                  Icon(Icons.warning, color: Colors.orange, size: 16),
                  SizedBox(width: 8),
                  Text(
                    'الفيلم سيختفي من الشبكة خلال 30 دقيقة',
                    style: TextStyle(color: Colors.orange, fontSize: 12),
                  ),
                ],
              ),
            ),

          // شريط التحكم
          Container(
            color: const Color(0xFF1A1A2E),
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // شريط التقدم
                SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    activeTrackColor: const Color(0xFF6C63FF),
                    thumbColor: const Color(0xFF6C63FF),
                    inactiveTrackColor: Colors.grey,
                  ),
                  child: Slider(
                    value: _progress,
                    onChanged: (v) => setState(() => _progress = v),
                  ),
                ),
                // أزرار التحكم
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.replay_10, color: Colors.white),
                      onPressed: () {},
                    ),
                    IconButton(
                      iconSize: 48,
                      icon: Icon(
                        _isPlaying ? Icons.pause_circle : Icons.play_circle,
                        color: Colors.white,
                      ),
                      onPressed: () =>
                          setState(() => _isPlaying = !_isPlaying),
                    ),
                    IconButton(
                      icon: const Icon(Icons.forward_10, color: Colors.white),
                      onPressed: () {},
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    widget.film.isPlaying = false;
    super.dispose();
  }
}
