import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../app/app_shell.dart';
import 'login_page.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});
  @override
  State<ProfileScreen> createState() => ProfileScreenState();
}

class ProfileScreenState extends State<ProfileScreen> {
  String userName = '';
  String lang = 'id-ID';

  @override
  void initState() {
    super.initState();
    load();
  }

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    userName = prefs.getString("user_name") ?? "User";
    lang = prefs.getString("app_lang") ?? "id-ID";
    FilmotecaApp.languageNotifier.value = lang;
    if (!mounted) return;
    setState(() {});
  }

  Future<void> _confirmAndSetLang(String l) async {
    final langNow = FilmotecaApp.languageNotifier.value;
    if (langNow == l) return;
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(langNow == 'id-ID' ? 'Konfirmasi' : 'Confirm'),
        content: Text(langNow == 'id-ID'
            ? 'Ganti bahasa aplikasi?'
            : 'Change app language?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text(langNow == 'id-ID' ? 'Batal' : 'Cancel')),
          TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: Text(langNow == 'id-ID' ? 'Ya' : 'Yes')),
        ],
      ),
    );
    if (confirm == true) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString("app_lang", l);
      FilmotecaApp.languageNotifier.value = l;
      if (!mounted) return;
      setState(() => lang = l);
    }
  }

  Future<void> _confirmLogout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(lang == 'id-ID' ? 'Logout' : 'Logout'),
        content: Text(lang == 'id-ID'
            ? 'Yakin ingin logout?'
            : 'Are you sure to logout?'),
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
    if (confirm == true) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();
      if (!mounted) return;
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const LoginPage()),
        (_) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final langNow = FilmotecaApp.languageNotifier.value;
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FB),
      appBar: AppBar(title: Text(langNow == 'id-ID' ? 'Profil' : 'Profile')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 520),
          child: Card(
            elevation: 0,
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Avatar + Name
                  CircleAvatar(
                    radius: 40,
                    backgroundColor: const Color.fromARGB(38, 63, 81, 181),
                    child: const Icon(Icons.person,
                        size: 40, color: Colors.indigo),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    userName,
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    langNow == 'id-ID' ? 'Pengaturan Akun' : 'Account Settings',
                    style: theme.textTheme.bodyMedium
                        ?.copyWith(color: Colors.black54),
                  ),

                  const SizedBox(height: 24),
                  // Language Section
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      langNow == 'id-ID' ? 'Bahasa Aplikasi' : 'App Language',
                      style: theme.textTheme.titleMedium,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 10,
                    runSpacing: 8,
                    children: [
                      ChoiceChip(
                        label: const Text('Indonesia'),
                        selected: langNow == 'id-ID',
                        onSelected: (_) => _confirmAndSetLang('id-ID'),
                      ),
                      ChoiceChip(
                        label: const Text('English'),
                        selected: langNow == 'en-US',
                        onSelected: (_) => _confirmAndSetLang('en-US'),
                      ),
                    ],
                  ),

                  const SizedBox(height: 28),
                  // Logout button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _confirmLogout,
                      icon: const Icon(Icons.logout),
                      label: Text(langNow == 'id-ID' ? 'Logout' : 'Logout'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
