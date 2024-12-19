import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'screens/tela_cadastro.dart';
import 'screens/tela_Login.dart';
import 'screens/tela_todolist.dart';
import 'screens/tela_adicionartask.dart';
import 'screens/tela_perfil.dart';
import 'screens/tela_flashcards.dart';
import 'screens/tela_mapa.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inicializando o Firebase com as opções
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions
        .currentPlatform, 
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const LoginScreen(),
      title: "ProAluno",
      routes: {
        "/tela_login": (context) => const LoginScreen(),
        "/tela_cadastro": (context) => const SignupScreen(),
        "/tela_todolist": (context) => const TodolistScreen(),
        "/tela_adicionartask": (context) => const AdicionarTask(),
        "/tela_perfil": (context) => const perfilScreen(),
        "/tela_flashcards": (context) => const flashcardScreen(),
        "/tela_mapa": (context) => const mapaScreen(),
      },
    );
  }
}
