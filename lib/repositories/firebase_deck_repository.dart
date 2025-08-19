import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:manaweave/models/card.dart';

class FirebaseDeckRepository {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  User? get currentUser => _firebaseAuth.currentUser;

  CollectionReference<Deck> _decksRef() {
    if (currentUser == null) {
      throw Exception('User not logged in');
    }
    return _firestore
        .collection('users')
        .doc(currentUser!.uid)
        .collection('decks')
        .withConverter<Deck>(
          fromFirestore: (snapshot, _) =>
              Deck.fromFirestore(snapshot.data()!, snapshot.id),
          toFirestore: (deck, _) => deck.toFirestore(),
        );
  }

  Stream<List<Deck>> getDecks() {
    return _decksRef().snapshots().map(
          (snapshot) => snapshot.docs.map((doc) => doc.data()).toList(),
        );
  }

  Future<Deck?> getDeckById(String id) async {
    final doc = await _decksRef().doc(id).get();
    return doc.data();
  }

  Future<void> saveDeck(Deck deck) async {
    await _decksRef().doc(deck.id).set(deck, SetOptions(merge: true));
  }

  Future<void> deleteDeck(String id) async {
    await _decksRef().doc(id).delete();
  }

  Future<String> createNewDeck(String name, List<String> commanderIds,
      {String? strategy}) async {
    final docRef = await _decksRef().add(
      Deck(
        id: '', // Firestore will generate the ID
        name: name,
        commanderIds: commanderIds,
        mainboard: [],
        strategyTags: strategy != null ? [strategy] : [],
      ),
    );
    return docRef.id;
  }
}
