import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/movie.dart';
import '../screens/detail_screen.dart';

class MovieCard extends StatelessWidget {
  final Movie movie;
  const MovieCard({super.key, required this.movie});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: ListTile(
        leading: SizedBox(
          width: 60,
          child: movie.posterFull.isEmpty
              ? const Icon(Icons.movie, size: 40)
              : CachedNetworkImage(
                  imageUrl: movie.posterFull,
                  placeholder: (_, __) => const Center(
                      child: CircularProgressIndicator(strokeWidth: 2)),
                  errorWidget: (_, __, ___) => const Icon(Icons.movie),
                  fit: BoxFit.cover,
                ),
        ),
        title: Text(movie.title),
        subtitle: Text('${movie.releaseDate} • ⭐ ${movie.rating}'),
        onTap: () => Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => DetailScreen(movie: movie))),
      ),
    );
  }
}
