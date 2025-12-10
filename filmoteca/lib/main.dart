import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'app/app_shell.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  final lang = prefs.getString('app_lang') ?? 'id-ID';
  final logged = prefs.getString('user_name');
  runApp(FilmotecaApp(initialLang: lang, loggedName: logged));
}
