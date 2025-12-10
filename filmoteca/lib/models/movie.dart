import '../config.dart';

class Movie {
  final int id;
  final String title;
  final String overview;
  final String posterPath;
  final String releaseDate;
  final double rating;

  Movie({
    required this.id,
    required this.title,
    required this.overview,
    required this.posterPath,
    required this.releaseDate,
    required this.rating,
  });

  String get posterFull => posterPath.isEmpty
      ? ''
      : (posterPath.startsWith('http')
          ? posterPath
          : '$tmdbImageBase$posterPath');

  factory Movie.fromTmdbJson(Map<String, dynamic> json) {
    return Movie(
      id: json['id'] ?? 0,
      title: json['title'] ?? json['name'] ?? 'Unknown',
      overview: json['overview'] ?? '',
      posterPath: json['poster_path'] ?? '',
      releaseDate: json['release_date'] ?? json['first_air_date'] ?? '',
      rating: (json['vote_average'] != null)
          ? (json['vote_average'] as num).toDouble()
          : 0.0,
    );
  }

  factory Movie.fromLocalJson(Map<String, dynamic> json) {
    return Movie(
      id: int.tryParse(json['id'].toString()) ?? 0,
      title: json['title'] ?? 'Unknown',
      overview: json['overview'] ?? '',
      posterPath: json['posterPath'] ?? '',
      releaseDate: json['releaseDate'] ?? '',
      rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toLocalJson() => {
        'id': id,
        'title': title,
        'overview': overview,
        'posterPath': posterPath,
        'releaseDate': releaseDate,
        'rating': rating,
      };
}
