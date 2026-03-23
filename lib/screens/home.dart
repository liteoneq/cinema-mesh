import 'package:flutter/material.dart';
import '../models/film.dart';
import '../services/mesh.dart';
import 'upload.dart';
import 'player.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final MeshService _mesh = MeshService();
  List<Film> _films = [];

  @override
  void initState() {
    super.initState();
    _mesh.start();
    _mesh.filmStream.listen((film) {
      setState(() {
        _films = _mesh.availableFilms;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A1A2E),
        title: const Text(
          '🎬 سينما ميش',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.bluetooth, color: Colors.blue),
            onPressed: () {},
          ),
        ],
      ),
      body: _films.isEmpty
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.movie_outlined,
                      size: 80, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    'لا توجد أفلام في الشبكة',
                    style: TextStyle(color: Colors.grey),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'ابحث عن شبكة ميش قريبة',
                    style: TextStyle(color: Colors.grey54),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: _films.length,
              itemBuilder: (context, index) {
                final film = _films[index];
                return _FilmCard(
                  film: film,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => PlayerScreen(film: film),
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: const Color(0xFF6C63FF),
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const UploadScreen()),
        ),
        icon: const Icon(Icons.upload, color: Colors.white),
        label: const Text(
          'رفع فيلم',
          style: TextStyle(color: Colors.white),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _mesh.dispose();
    super.dispose();
  }
}

class _FilmCard extends StatelessWidget {
  final Film film;
  final VoidCallback onTap;

  const _FilmCard({required this.film, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final remaining = film.expiresAt.difference(DateTime.now());
    final hours = remaining.inHours;

    return Card(
      color: const Color(0xFF1A1A2E),
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        onTap: onTap,
        leading: const CircleAvatar(
          backgroundColor: Color(0xFF6C63FF),
          child: Icon(Icons.movie, color: Colors.white),
        ),
        title: Text(
          film.title,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Text(
          '${film.quality.name} • ينتهي بعد ${hours}س',
          style: const TextStyle(color: Colors.grey),
        ),
        trailing: Icon(
          film.isExpired ? Icons.lock : Icons.play_arrow,
          color: film.isExpired ? Colors.red : Colors.green,
        ),
      ),
    );
  }
}
