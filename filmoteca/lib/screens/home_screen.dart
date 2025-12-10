import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:http/http.dart' as http;
import '../app/app_shell.dart';
import '../models/movie.dart';
import 'detail_screen.dart';
import 'search_delegate.dart';
import '../config.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen>
    with AutomaticKeepAliveClientMixin {
  DateTime? _lastFetched;
  List<Movie> movies = [];
  bool loading = true;
  bool hasError = false;
  String? errorMsg;

  Future<void> fetchPopular(String lang) async {
    setState(() {
      loading = true;
      hasError = false;
      errorMsg = null;
    });
    try {
      final url = Uri.parse(
          '$tmdbBase/movie/popular?api_key=$tmdbApiKey&language=$lang&page=1');
      final res = await http.get(url).timeout(const Duration(seconds: 10));
      if (res.statusCode == 200) {
        final body = jsonDecode(res.body);
        final List results = body['results'] ?? [];
        movies = results.map((e) => Movie.fromTmdbJson(e)).toList();
        _lastFetched = DateTime.now();
      } else {
        hasError = true;
        errorMsg = 'Server TMDb error ${res.statusCode}';
      }
    } catch (e) {
      hasError = true;
      errorMsg = 'Network error: $e';
    } finally {
      if (mounted) {
        setState(() => loading = false);
      }
    }
  }

  Future<void> refreshIfNeeded() async {
    final lang = FilmotecaApp.languageNotifier.value;
    if (_lastFetched == null ||
        DateTime.now().difference(_lastFetched!).inSeconds > 60) {
      await fetchPopular(lang);
    }
  }

  Future<void> manualRefresh() async {
    final lang = FilmotecaApp.languageNotifier.value;
    await fetchPopular(lang);
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      fetchPopular(FilmotecaApp.languageNotifier.value);
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return ValueListenableBuilder<String>(
      valueListenable: FilmotecaApp.languageNotifier,
      builder: (_, lang, __) {
        return Scaffold(
          appBar: AppBar(
            title: Text(lang == 'id-ID' ? 'Film Populer' : 'Popular Movies'),
            actions: [
              IconButton(
                icon: const Icon(Icons.search),
                onPressed: () async {
                  final Movie? picked = await showSearch<Movie?>(
                    context: context,
                    delegate: MovieSearchDelegate(
                        lang: lang, searchFn: (q, l) => searchMovies(q, l)),
                  );
                  if (!context.mounted) return;
                  if (picked != null) {
                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (_) => DetailScreen(movie: picked)));
                  }
                },
              )
            ],
          ),
          body: loading
              ? const Center(child: CircularProgressIndicator())
              : (hasError
                  ? _buildError(context, errorMsg ?? 'Unknown error')
                  : RefreshIndicator(
                      onRefresh: manualRefresh,
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          int crossAxisCount = 2;
                          final w = constraints.maxWidth;
                          if (w >= 1200) {
                            crossAxisCount = 6;
                          } else if (w >= 900) {
                            crossAxisCount = 4;
                          } else if (w >= 600) {
                            crossAxisCount = 3;
                          }
                          return GridView.builder(
                            padding: const EdgeInsets.all(12),
                            gridDelegate:
                                SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: crossAxisCount,
                              mainAxisSpacing: 12,
                              crossAxisSpacing: 12,
                              childAspectRatio: 0.6,
                            ),
                            itemCount: movies.length,
                            itemBuilder: (c, i) {
                              final m = movies[i];
                              return _MovieGridItem(movie: m);
                            },
                          );
                        },
                      ),
                    )),
        );
      },
    );
  }

  Widget _buildError(BuildContext context, String message) {
    final lang = FilmotecaApp.languageNotifier.value;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Text(lang == 'id-ID' ? 'Gagal memuat film' : 'Failed to load movies',
              style:
                  const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text(message, textAlign: TextAlign.center),
          const SizedBox(height: 12),
          ElevatedButton(
              onPressed: () =>
                  fetchPopular(FilmotecaApp.languageNotifier.value),
              child: Text(lang == 'id-ID' ? 'Coba lagi' : 'Retry'))
        ]),
      ),
    );
  }

  Future<List<Movie>> searchMovies(String q, String lang) async {
    if (q.trim().isEmpty) return [];
    final url = Uri.parse(
        '$tmdbBase/search/movie?api_key=$tmdbApiKey&language=$lang&query=${Uri.encodeQueryComponent(q)}');
    final res = await http.get(url).timeout(const Duration(seconds: 10));
    if (res.statusCode == 200) {
      final body = jsonDecode(res.body);
      final List results = body['results'] ?? [];
      return results.map((e) => Movie.fromTmdbJson(e)).toList();
    } else {
      return [];
    }
  }

  @override
  bool get wantKeepAlive => true;
}

class _MovieGridItem extends StatelessWidget {
  final Movie movie;
  const _MovieGridItem({required this.movie});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => DetailScreen(movie: movie)),
      ),
      child: Card(
        elevation: 1,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: movie.posterFull.isEmpty
                  ? const Center(child: Icon(Icons.movie, size: 40))
                  : CachedNetworkImage(
                      imageUrl: movie.posterFull,
                      fit: BoxFit.cover,
                      width: double.infinity,
                      placeholder: (_, __) => const Center(
                        child: SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      ),
                      errorWidget: (_, __, ___) => const Center(
                        child: Icon(Icons.movie),
                      ),
                    ),
            ),
            Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    movie.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${movie.releaseDate} • ⭐ ${movie.rating.toStringAsFixed(1)}',
                    style: const TextStyle(color: Colors.black54, fontSize: 12),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
