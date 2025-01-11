import 'package:flutter/material.dart';
import 'main_page.dart';  // Mengimpor file MainPage
import 'videos_tips.dart';  // Mengimpor file VideosTipsPage
import 'welcome_page.dart';  // Mengimpor file WelcomePage
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart'; // File ini dihasilkan oleh FlutterFire CLI

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'SIGN UP FOR FUN',
      theme: ThemeData(
        primarySwatch: Colors.brown,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.brown,
          foregroundColor: Colors.white,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.brown,
            textStyle: const TextStyle(color: Colors.white),
          ),
        ),
        checkboxTheme: CheckboxThemeData(
          fillColor: MaterialStateProperty.all(Colors.brown),
        ),
        radioTheme: RadioThemeData(
          fillColor: MaterialStateProperty.all(Colors.brown),
        ),
        switchTheme: SwitchThemeData(
          thumbColor: MaterialStateProperty.all(Colors.brown),
          trackColor: MaterialStateProperty.all(Colors.brown.shade200),
        ),
        inputDecorationTheme: const InputDecorationTheme(
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.brown),
          ),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.grey),
          ),
        ),
        dialogTheme: DialogTheme(
          backgroundColor: Colors.white,
          titleTextStyle: TextStyle(color: Colors.brown),
          contentTextStyle: TextStyle(color: Colors.brown),
        ),
        colorScheme: ColorScheme.light(primary: Colors.brown),
      ),
      initialRoute: '/welcome',  // Set langsung ke WelcomePage
      routes: {
        '/welcome': (context) => const WelcomePage(),  // Halaman WelcomePage
        '/home': (context) => const MyHomePage(),  // Halaman utama setelah WelcomePage
        '/videos': (context) => const VideosTipsPage(),
      },
      onUnknownRoute: (settings) {
        return MaterialPageRoute(
          builder: (context) => const WelcomePage(),  // Set default ke WelcomePage
        );
      },
    );
  }
}
