import 'package:flutter/material.dart';
import 'presentation/theme/orvyan_theme.dart';
import 'presentation/upload_screen.dart';

void main() {
  runApp(const FileHasherApp());
}

class FileHasherApp extends StatelessWidget {
  const FileHasherApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: OrvyanTheme.light,
      darkTheme: OrvyanTheme.dark,
      themeMode: ThemeMode.system,
      home: const UploadScreen(),
    );
  }
}
