import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:manaweave/models/card.dart';

class FirebaseCardRepository {
  final CollectionReference _cardsCollection =
      FirebaseFirestore.instance.collection('cards');

  Future<List<MTGCard>> getAllCards() async {
    final snapshot = await _cardsCollection.get();
    return snapshot.docs
        .map((doc) =>
            MTGCard.fromFirestore(doc.data() as Map<String, dynamic>, doc.id))
        .toList();
  }

  Future<MTGCard?> getCardById(String id) async {
    final doc = await _cardsCollection.doc(id).get();
    if (doc.exists) {
      return MTGCard.fromFirestore(doc.data() as Map<String, dynamic>, doc.id);
    }
    return null;
  }

  Future<List<MTGCard>> getCommanderCards() async {
    final snapshot = await _cardsCollection
        .where('supertypes', arrayContains: 'Legendary')
        .where('types', arrayContains: 'Creature')
        .get();
    return snapshot.docs
        .map((doc) =>
            MTGCard.fromFirestore(doc.data() as Map<String, dynamic>, doc.id))
        .toList();
  }

  // searchCards, getCardsByColorIdentity, and getAutofillCards
  // will be more complex with Firestore and may require a search service
  // like Algolia or Elasticsearch for full-text search.
  // For now, I will implement a basic search.

  Future<List<MTGCard>> searchCards(String query) async {
    if (query.isEmpty) {
      return [];
    }
    final snapshot = await _cardsCollection
        .where('name', isGreaterThanOrEqualTo: query)
        .where('name', isLessThanOrEqualTo: query + '\uf8ff')
        .get();
    return snapshot.docs
        .map((doc) =>
            MTGCard.fromFirestore(doc.data() as Map<String, dynamic>, doc.id))
        .toList();
  }
}
