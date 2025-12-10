Place your launcher icon image here as `assets/icon.png`.

Requirements:
- PNG format
- Prefer a large square image (1024x1024) for best results

After you add `assets/icon.png`, run these commands in project root (PowerShell):

flutter pub get
flutter pub run flutter_launcher_icons:main

Notes:
- For Android adaptive icons, you can provide a foreground and background separately. The package will auto-generate masks where possible.
- If you run on Android emulator (AVD), you may need to `flutter clean` and rebuild the app to see the updated launcher icon.
