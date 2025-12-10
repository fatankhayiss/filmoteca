import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../app/app_shell.dart';
import '../models/movie.dart';
import '../config.dart';
import '../services/favorite_service.dart';
import '../widgets/movie_card.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});
  @override
  State<FavoritesScreen> createState() => FavoritesScreenState();
}

class FavoritesScreenState extends State<FavoritesScreen> {
  List<Movie>? cachedMovies;
  bool isLoading = true;
  bool isSyncing = false;
  static const String _prefsFavoritesCacheKey = 'favorites_cache_v1';

  @override
  void initState() {
    super.initState();
    loadFromCacheThenSync();
  }

  Future<void> loadFromCacheThenSync() async => _loadFromCacheAndSync();

  Future<void> _loadFromCacheAndSync() async {
    await _loadCache();
    await _syncFromServer();
  }

  Future<void> _loadCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final list = prefs.getStringList(_prefsFavoritesCacheKey) ?? [];
      cachedMovies = list.map((s) {
        final m = jsonDecode(s);
        return Movie.fromLocalJson(m);
      }).toList();
    } catch (_) {
      cachedMovies = [];
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  Future<void> _syncFromServer() async {
    if (isSyncing) return;
    setState(() => isSyncing = true);
    try {
      final data = await FavoriteService.getFavorites();
      final lang = FilmotecaApp.languageNotifier.value;
      final movies = <Movie>[];
      for (final e in data) {
        final mid = int.parse(e["movie_id"].toString());
        double r = 0.0;
        r = double.tryParse(
                (e["rating"] ?? e["vote_average"] ?? e["vote"] ?? '0')
                    .toString()) ??
            0.0;
        if (r == 0.0) {
          try {
            final url = Uri.parse(
                '$tmdbBase/movie/$mid?api_key=$tmdbApiKey&language=$lang');
            final res = await http.get(url).timeout(const Duration(seconds: 8));
            if (res.statusCode == 200) {
              final body = jsonDecode(res.body);
              final va = body['vote_average'];
              if (va is num) r = va.toDouble();
            }
          } catch (_) {}
        }

        movies.add(Movie(
          id: mid,
          title: e["title"] ?? '',
          overview: e["overview"] ?? '',
          posterPath: e["poster_url"] ?? '',
          releaseDate: e["release_date"] ?? '',
          rating: r,
        ));
      }

      final prefs = await SharedPreferences.getInstance();
      final snapshots = movies.map((m) => jsonEncode(m.toLocalJson())).toList();
      await prefs.setStringList(_prefsFavoritesCacheKey, snapshots);

      if (!mounted) return;
      setState(() {
        cachedMovies = movies;
        isLoading = false;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(FilmotecaApp.languageNotifier.value == 'id-ID'
                ? 'Sinkron gagal, tampilkan cache'
                : 'Sync failed, showing cache')));
      }
    } finally {
      if (mounted) {
        setState(() => isSyncing = false);
      }
    }
  }

  Future<void> _refresh() async => _syncFromServer();

  Future<bool?> _confirmDismiss(int movieId) async {
    final lang = FilmotecaApp.languageNotifier.value;
    return showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(lang == 'id-ID' ? 'Konfirmasi' : 'Confirm'),
        content: Text(lang == 'id-ID'
            ? 'Hapus film dari favorit?'
            : 'Remove movie from favorites?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text(lang == 'id-ID' ? 'Batal' : 'Cancel')),
          TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: Text(lang == 'id-ID' ? 'Ya' : 'Yes')),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final lang = FilmotecaApp.languageNotifier.value;
    return Scaffold(
      appBar: AppBar(
        title: Text(lang == 'id-ID' ? 'Favorit' : 'Favorites'),
        actions: [
          if (isSyncing)
            const Padding(
                padding: EdgeInsets.symmetric(horizontal: 12),
                child: Center(
                    child: SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2)))),
          IconButton(icon: const Icon(Icons.refresh), onPressed: _refresh),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : (cachedMovies == null || cachedMovies!.isEmpty)
              ? Center(
                  child: Text(lang == 'id-ID'
                      ? 'Belum ada favorit'
                      : 'No favorites yet'))
              : RefreshIndicator(
                  onRefresh: _refresh,
                  child: ListView.builder(
                    itemCount: cachedMovies!.length,
                    itemBuilder: (c, i) {
                      final m = cachedMovies![i];
                      return Dismissible(
                        key: Key('${m.id}-$i'),
                        background: Container(
                            color: Colors.red,
                            alignment: Alignment.centerLeft,
                            padding: const EdgeInsets.only(left: 20),
                            child:
                                const Icon(Icons.delete, color: Colors.white)),
                        confirmDismiss: (_) async {
                          final confirm = await _confirmDismiss(m.id);
                          if (confirm == true) {
                            try {
                              final favs = await FavoriteService.getFavorites();
                              for (var f in favs) {
                                if (f['movie_id'].toString() ==
                                    m.id.toString()) {
                                  await FavoriteService.removeFavorite(f['id']);
                                  break;
                                }
                              }
                            } catch (_) {}
                            cachedMovies!.removeAt(i);
                            final prefs = await SharedPreferences.getInstance();
                            await prefs.setStringList(
                                _prefsFavoritesCacheKey,
                                cachedMovies!
                                    .map((x) => jsonEncode(x.toLocalJson()))
                                    .toList());
                            if (!mounted) return false;
                            setState(() {});
                            return true;
                          }
                          return false;
                        },
                        child: MovieCard(movie: m),
                      );
                    },
                  ),
                ),
    );
  }
}
