import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:cached_network_image/cached_network_image.dart';
import 'package:url_launcher/url_launcher.dart';
import '../app/app_shell.dart';
import '../models/movie.dart';
import '../config.dart';
import '../services/favorite_service.dart';

class DetailScreen extends StatefulWidget {
  final Movie movie;
  const DetailScreen({super.key, required this.movie});

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  bool isFavorite = false;
  int? favoriteId;
  bool isChecking = true;
  bool isWorking = false;
  List<_Trailer> trailers = [];

  @override
  void initState() {
    super.initState();
    checkFavorite();
    _fetchTrailers();
  }

  Future<void> _fetchTrailers() async {
    final lang = FilmotecaApp.languageNotifier.value;
    try {
      final urlLang = Uri.parse(
          '$tmdbBase/movie/${widget.movie.id}/videos?api_key=$tmdbApiKey&language=$lang');
      final resLang =
          await http.get(urlLang).timeout(const Duration(seconds: 10));
      List results = [];
      if (resLang.statusCode == 200) {
        final body = jsonDecode(resLang.body);
        results = (body['results'] ?? []) as List;
      }
      if (results.isEmpty) {
        final url = Uri.parse(
            '$tmdbBase/movie/${widget.movie.id}/videos?api_key=$tmdbApiKey');
        final res = await http.get(url).timeout(const Duration(seconds: 10));
        if (res.statusCode == 200) {
          final body2 = jsonDecode(res.body);
          results = (body2['results'] ?? []) as List;
        }
      }
      trailers = results
          .where((e) => (e['site'] == 'YouTube') && (e['key'] != null))
          .map<_Trailer>((e) => _Trailer(
                key: (e['key'] ?? '').toString(),
                name: (e['name'] ?? 'Trailer').toString(),
              ))
          .toList();
      if (mounted) setState(() {});
    } catch (_) {
      // ignore
    }
  }

  Future<void> checkFavorite() async {
    setState(() => isChecking = true);
    try {
      final list = await FavoriteService.getFavorites();
      // Normalize and match favorites regardless of payload shape
      Map<String, dynamic>? match;
      for (final item in list) {
        if (item is Map<String, dynamic>) {
          // Common shapes: {id, movie_id} OR {id, movieId} OR {movie: {id}}
          // capture id (may be string/int), used later if match found
          final movieIdAny = item.containsKey('movie_id')
              ? item['movie_id']
              : (item.containsKey('movieId')
                  ? item['movieId']
                  : (item['movie'] is Map
                      ? (item['movie'] as Map)['id']
                      : null));
          int? movieId;
          if (movieIdAny is int) movieId = movieIdAny;
          if (movieIdAny is String) {
            final parsed = int.tryParse(movieIdAny);
            movieId = parsed;
          }
          if (movieId == widget.movie.id) {
            match = item;
            break;
          }
        }
      }
      isFavorite = match != null;
      favoriteId = match != null
          ? (match['id'] is int
              ? match['id'] as int
              : (match['id'] is String
                  ? int.tryParse(match['id'] as String)
                  : null))
          : null;
    } catch (_) {}
    if (mounted) setState(() => isChecking = false);
  }

  Future<void> _refreshDetail() async {
    await _fetchTrailers();
    await checkFavorite();
  }

  Future<void> _confirmAndToggleFavorite() async {
    if (!isFavorite) {
      // Confirm before adding to favorites
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (ctx) {
          return AlertDialog(
            title: Text(FilmotecaApp.languageNotifier.value == 'id-ID'
                ? 'Tambah ke Favorit?'
                : 'Add to Favorites?'),
            content: Text(FilmotecaApp.languageNotifier.value == 'id-ID'
                ? 'Apakah Anda yakin ingin menambahkan film ini ke favorit?'
                : 'Are you sure you want to add this movie to favorites?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(false),
                child: Text(FilmotecaApp.languageNotifier.value == 'id-ID'
                    ? 'Batal'
                    : 'Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(true),
                child: Text(FilmotecaApp.languageNotifier.value == 'id-ID'
                    ? 'Tambah'
                    : 'Add'),
              ),
            ],
          );
        },
      );
      if (confirmed != true) return;
      setState(() => isWorking = true);
      final ok = await FavoriteService.addFavorite({
        'movie_id': widget.movie.id,
        'title': widget.movie.title,
        'poster_url': widget.movie.posterPath,
        'overview': widget.movie.overview,
        'release_date': widget.movie.releaseDate,
        'rating': widget.movie.rating,
      });
      setState(() => isWorking = false);
      if (ok) {
        // Optimistic UI: mark as favorite, then verify
        setState(() => isFavorite = true);
        await checkFavorite();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Added to favorites')),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to add favorite')),
          );
        }
      }
    } else {
      // Confirm before removing from favorites
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (ctx) {
          return AlertDialog(
            title: Text(FilmotecaApp.languageNotifier.value == 'id-ID'
                ? 'Hapus Favorit?'
                : 'Remove Favorite?'),
            content: Text(FilmotecaApp.languageNotifier.value == 'id-ID'
                ? 'Apakah Anda yakin ingin menghapus film ini dari favorit?'
                : 'Are you sure you want to remove this movie from favorites?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(false),
                child: Text(FilmotecaApp.languageNotifier.value == 'id-ID'
                    ? 'Batal'
                    : 'Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(true),
                child: Text(FilmotecaApp.languageNotifier.value == 'id-ID'
                    ? 'Hapus'
                    : 'Remove'),
              ),
            ],
          );
        },
      );
      if (confirmed != true) return;
      setState(() => isWorking = true);
      if (favoriteId != null) {
        final ok = await FavoriteService.removeFavorite(favoriteId!);
        setState(() => isWorking = false);
        if (ok) {
          await checkFavorite();
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Removed from favorites')),
            );
          }
        }
      } else {
        setState(() => isWorking = false);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Favorite not found')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final lang = FilmotecaApp.languageNotifier.value;
    return Scaffold(
      // Tombol lengket di bawah untuk tambah/hapus favorit
      bottomNavigationBar: SafeArea(
        top: false,
        child: BottomAppBar(
          elevation: 8,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: SizedBox(
              height: 48,
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: (isChecking || isWorking)
                    ? null
                    : _confirmAndToggleFavorite,
                icon: Icon(
                  isFavorite ? Icons.favorite : Icons.favorite_border,
                  color: Colors.red,
                ),
                label: isWorking
                    ? const SizedBox(
                        height: 18,
                        width: 18,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white),
                      )
                    : Text(
                        isFavorite
                            ? (lang == 'id-ID'
                                ? 'Hapus dari Favorit'
                                : 'Remove Favorite')
                            : (lang == 'id-ID'
                                ? 'Tambah ke Favorit'
                                : 'Add to Favorites'),
                      ),
              ),
            ),
          ),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: _refreshDetail,
        child: ScrollConfiguration(
          behavior: const _MomentumScrollBehavior(),
          child: CustomScrollView(
            physics: const BouncingScrollPhysics(
              parent: AlwaysScrollableScrollPhysics(),
            ),
            slivers: [
              SliverAppBar(
                pinned: true,
                floating: false,
                snap: false,
                expandedHeight: 560,
                stretch: true,
                backgroundColor: Colors.transparent,
                forceElevated: true,
                title: Text(
                  widget.movie.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurface,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                // title removed per request
                actions: [
                  isChecking
                      ? const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 12),
                          child: Center(
                              child: SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                      strokeWidth: 2))))
                      : IconButton(
                          icon: Icon(
                            isFavorite ? Icons.favorite : Icons.favorite_border,
                            color: Colors.red,
                          ),
                          onPressed: _confirmAndToggleFavorite,
                        ),
                ],
                flexibleSpace: LayoutBuilder(
                  builder: (context, constraints) {
                    final theme = Theme.of(context);
                    final min =
                        kToolbarHeight + MediaQuery.of(context).padding.top;
                    final max = 480.0;
                    final t = (constraints.maxHeight - min) / (max - min);
                    final overlayOpacity = 1.0 - t.clamp(0.0, 1.0);
                    return Stack(
                      fit: StackFit.expand,
                      children: [
                        // Poster background
                        widget.movie.posterFull.isEmpty
                            ? Container(color: Colors.black12)
                            : CachedNetworkImage(
                                imageUrl: widget.movie.posterFull,
                                fit: BoxFit.cover,
                              ),
                        // Readability gradient on poster
                        Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.black.withOpacity(0.02),
                                Colors.black.withOpacity(0.10),
                                Colors.black.withOpacity(0.25),
                              ],
                            ),
                          ),
                        ),
                        // Bottom meta overlay
                        Align(
                          alignment: Alignment.bottomLeft,
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                            child: Opacity(
                              opacity: t.clamp(0.0, 1.0),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    widget.movie.title,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    "${lang == 'id-ID' ? 'Tanggal Rilis' : 'Release'}: ${widget.movie.releaseDate} • ⭐ ${widget.movie.rating}",
                                    style:
                                        const TextStyle(color: Colors.white70),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        // Collapsed header title: appears only when scrolled past the header
                        Positioned(
                          left: 16,
                          right: 72, // room for actions
                          top: MediaQuery.of(context).padding.top + 8,
                          child: Opacity(
                            opacity: overlayOpacity > 0.95 ? 1.0 : 0.0,
                            child: Text(
                              widget.movie.title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: Colors.black,
                                fontSize: 20,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                        // Collapsed header title removed (reverted per request)
                        // Top overlay that becomes solid on collapse, matching detail surface color
                        Positioned.fill(
                          child: IgnorePointer(
                            ignoring: true,
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 150),
                              color: theme.colorScheme.surface
                                  .withOpacity(overlayOpacity),
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                  child: Card(
                    elevation: 1,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            lang == 'id-ID' ? 'Sinopsis' : 'Synopsis',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            widget.movie.overview,
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (trailers.isNotEmpty) ...[
                        Text(
                          lang == 'id-ID' ? 'Trailer' : 'Trailers',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 8),
                        SizedBox(
                          height: 120,
                          child: PageView.builder(
                            controller: PageController(viewportFraction: 0.7),
                            itemCount: trailers.length,
                            itemBuilder: (_, i) {
                              final t = trailers[i];
                              final thumb =
                                  'https://i.ytimg.com/vi/${t.key}/hqdefault.jpg';
                              return Padding(
                                padding: const EdgeInsets.only(right: 8),
                                child: GestureDetector(
                                  onTap: () async {
                                    final url = Uri.parse(
                                        'https://www.youtube.com/watch?v=${t.key}');
                                    if (await canLaunchUrl(url)) {
                                      await launchUrl(url,
                                          mode: LaunchMode.externalApplication);
                                    }
                                  },
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: Stack(
                                      fit: StackFit.expand,
                                      children: [
                                        CachedNetworkImage(
                                          imageUrl: thumb,
                                          fit: BoxFit.cover,
                                        ),
                                        Align(
                                          alignment: Alignment.center,
                                          child: Icon(
                                            Icons.play_circle_fill,
                                            color: Colors.white,
                                            size: 42,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ] else ...[
                        Text(
                          lang == 'id-ID'
                              ? 'Trailer tidak tersedia'
                              : 'Trailer not available',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              // Bottom spacer to allow comfortable scrolling past trailers
              const SliverToBoxAdapter(
                child: SizedBox(height: 300),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Trailer {
  final String key;
  final String name;
  _Trailer({required this.key, required this.name});
}

class _MomentumScrollBehavior extends ScrollBehavior {
  const _MomentumScrollBehavior();
  @override
  ScrollPhysics getScrollPhysics(BuildContext context) {
    // Stronger momentum via Bouncing + AlwaysScrollable
    return const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics());
  }
}
