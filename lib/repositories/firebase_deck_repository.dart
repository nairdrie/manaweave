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

  Future<void> addCardToDeck(String deckId, DeckEntry entry) async {
    await _decksRef().doc(deckId).update({
      'mainboard': FieldValue.arrayUnion([entry.toFirestore()])
    });
  }

  Future<void> removeCardFromDeck(String deckId, DeckEntry entry) async {
    await _decksRef().doc(deckId).update({
      'mainboard': FieldValue.arrayRemove([entry.toFirestore()])
    });
  }

  Future<void> updateDeckMainboard(String deckId, List<DeckEntry> mainboard) async {
    await _decksRef().doc(deckId).update({
      'mainboard': mainboard.map((e) => e.toFirestore()).toList(),
    });
  }

  // A full implementation would require fetching cards and complex logic.
  // This is a placeholder that adds a few staples.
  Future<void> autofillDeck(Deck deck, AutofillConfig config, FirebaseCardRepository cardRepo) async {
    final commanderColorIdentity = deck.commanderIds.isEmpty
        ? <String>[]
        : (await cardRepo.getCardById(deck.commanderIds.first))
                ?.colorIdentity ??
            [];

    final autofillCards = await cardRepo.getAutofillCards(config.strategy, commanderColorIdentity);
    final newEntries = autofillCards.map((card) => DeckEntry(cardId: card.id, qty: 1, section: 'Autofill')).toList();

    await _decksRef().doc(deck.id).update({
      'mainboard': FieldValue.arrayUnion(newEntries.map((e) => e.toFirestore()).toList()),
      'landGoal': config.landGoal,
      'budgetPerCardUsd': config.budgetPerCardUsd,
    });
  }

  List<String> getValidationErrors(Deck deck, List<MTGCard> allCards) {
    final errors = <String>[];
    final mainboardCards = <String, int>{};

    for (final entry in deck.mainboard) {
      mainboardCards[entry.cardId] = (mainboardCards[entry.cardId] ?? 0) + entry.qty;
    }

    if (deck.totalCards != 100) {
      errors.add('Deck size ${deck.totalCards}/100');
    }

    final commander = allCards.firstWhere((c) => c.id == deck.commanderIds.first);
    final commanderColorIdentity = commander.colorIdentity;

    for (final entry in deck.mainboard) {
      final card = allCards.firstWhere((c) => c.id == entry.cardId);
      if (entry.qty > 1 && !card.isBasicLand && !card.isAnyNumber) {
        errors.add('${entry.qty}x ${card.name} (non-basic)');
      }
      if (!card.colorIdentity.every((c) => commanderColorIdentity.contains(c))) {
        errors.add('${card.name} is outside color identity');
      }
      if (card.isBanned) {
        errors.add('${card.name} is banned');
      }
    }
    return errors;
  }
}
