import 'package:get_it/get_it.dart';
import 'package:manaweave/repositories/firebase_card_repository.dart';
import 'package:manaweave/repositories/firebase_collection_repository.dart';
import 'package:manaweave/repositories/firebase_deck_repository.dart';

final GetIt locator = GetIt.instance;

void setupLocator() {
  locator.registerLazySingleton(() => FirebaseCardRepository());
  locator.registerLazySingleton(() => FirebaseCollectionRepository());
  locator.registerLazySingleton(() => FirebaseDeckRepository());
}
