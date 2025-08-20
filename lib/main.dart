import 'package:flutter/material.dart';
import 'package:manaweave/locator.dart';
import 'package:manaweave/repositories/firebase_card_repository.dart';
import 'package:manaweave/repositories/firebase_collection_repository.dart';
import 'package:manaweave/repositories/firebase_deck_repository.dart';
import 'package:manaweave/theme.dart';
import 'package:manaweave/screens/home_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  setupLocator();
  runApp(const ManaWeaveApp());
}

class ManaWeaveApp extends StatelessWidget {
  const ManaWeaveApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<FirebaseCardRepository>(
          create: (_) => locator<FirebaseCardRepository>(),
        ),
        Provider<FirebaseCollectionRepository>(
          create: (_) => locator<FirebaseCollectionRepository>(),
        ),
        Provider<FirebaseDeckRepository>(
          create: (_) => locator<FirebaseDeckRepository>(),
        ),
      ],
      child: MaterialApp(
        title: 'ManaWeave',
        debugShowCheckedModeBanner: false,
        theme: lightTheme,
        darkTheme: darkTheme,
        themeMode: ThemeMode.system,
        home: const HomeScreen(),
      ),
    );
  }
}
