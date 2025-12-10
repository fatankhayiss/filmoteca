import 'package:flutter/material.dart';
import '../models/movie.dart';

class MovieSearchDelegate extends SearchDelegate<Movie?> {
  final String lang;
  final Future<List<Movie>> Function(String q, String lang) searchFn;
  MovieSearchDelegate({required this.lang, required this.searchFn});

  @override
  String? get searchFieldLabel =>
      lang == 'id-ID' ? 'Cari film...' : 'Search movies...';

  @override
  List<Widget>? buildActions(BuildContext context) => [
        if (query.isNotEmpty)
          IconButton(onPressed: () => query = '', icon: const Icon(Icons.clear))
      ];

  @override
  Widget? buildLeading(BuildContext context) => IconButton(
      onPressed: () => close(context, null),
      icon: const Icon(Icons.arrow_back));

  @override
  Widget buildResults(BuildContext context) {
    return FutureBuilder<List<Movie>>(
      future: searchFn(query, lang),
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snap.hasError) return Center(child: Text('Error: ${snap.error}'));
        final results = snap.data ?? [];
        if (results.isEmpty) {
          return Center(
              child: Text(lang == 'id-ID' ? 'Tidak ditemukan' : 'Not found'));
        }
        return ListView.builder(
          itemCount: results.length,
          itemBuilder: (c, i) => ListTile(
            title: Text(results[i].title),
            subtitle: Text(results[i].releaseDate),
            onTap: () => close(context, results[i]),
          ),
        );
      },
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) => const SizedBox.shrink();
}
