import 'package:flutter/material.dart';
import '../screens/login_page.dart';
import '../screens/home_screen.dart';
import '../screens/favorites_screen.dart';
import '../screens/profile_screen.dart';

class FilmotecaApp extends StatelessWidget {
  final String initialLang;
  final String? loggedName;
  const FilmotecaApp(
      {super.key, required this.initialLang, required this.loggedName});

  static final ValueNotifier<String> languageNotifier =
      ValueNotifier<String>('id-ID');

  @override
  Widget build(BuildContext context) {
    languageNotifier.value = initialLang;
    return ValueListenableBuilder<String>(
      valueListenable: languageNotifier,
      builder: (_, lang, __) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Filmoteca',
          theme: ThemeData(primarySwatch: Colors.indigo),
          home: loggedName == null ? const LoginPage() : const MainShell(),
        );
      },
    );
  }
}

class MainShell extends StatefulWidget {
  const MainShell({super.key});
  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _index = 0;

  final GlobalKey<HomeScreenState> homeKey = GlobalKey<HomeScreenState>();
  final GlobalKey<FavoritesScreenState> favKey =
      GlobalKey<FavoritesScreenState>();
  final GlobalKey<ProfileScreenState> profileKey =
      GlobalKey<ProfileScreenState>();

  List<Widget> get _pages => [
        HomeScreen(key: homeKey),
        FavoritesScreen(key: favKey),
        ProfileScreen(key: profileKey),
      ];

  void _onTap(int i) {
    setState(() {
      _index = i;
    });
    if (i == 0) {
      homeKey.currentState?.refreshIfNeeded();
    } else if (i == 1) {
      favKey.currentState?.loadFromCacheThenSync();
    }
  }

  @override
  Widget build(BuildContext context) {
    final lang = FilmotecaApp.languageNotifier.value;
    return Scaffold(
      body: _pages[_index],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _index,
        onTap: _onTap,
        items: [
          BottomNavigationBarItem(
              icon: const Icon(Icons.home),
              label: lang == 'id-ID' ? 'Beranda' : 'Home'),
          BottomNavigationBarItem(
              icon: const Icon(Icons.favorite),
              label: lang == 'id-ID' ? 'Favorit' : 'Favorites'),
          BottomNavigationBarItem(
              icon: const Icon(Icons.person),
              label: lang == 'id-ID' ? 'Profil' : 'Profile'),
        ],
      ),
    );
  }
}
