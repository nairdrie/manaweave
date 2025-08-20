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

  Future<List<MTGCard>> getCardsByIds(List<String> ids) async {
    if (ids.isEmpty) {
      return [];
    }
    final snapshot = await _cardsCollection.where(FieldPath.documentId, whereIn: ids).get();
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
    // Firestore does not support case-insensitive search natively.
    // A more robust solution would involve a third-party search service like Algolia or Elasticsearch,
    // or using a cloud function to normalize data.
    // This implementation performs a case-sensitive prefix search on the name.
    final snapshot = await _cardsCollection
        .where('name', isGreaterThanOrEqualTo: query)
        .where('name', isLessThanOrEqualTo: query + '\uf8ff')
        .limit(20)
        .get();
    return snapshot.docs
        .map((doc) =>
            MTGCard.fromFirestore(doc.data() as Map<String, dynamic>, doc.id))
        .toList();
  }

  Future<List<MTGCard>> getCardsByColorIdentity(
      List<String> colorIdentity) async {
    if (colorIdentity.isEmpty) {
      return getAllCards();
    }
    // This query is tricky in Firestore. A common approach is to store a sorted string
    // or a map of colors. For this implementation, I will assume the `colorIdentity`
    // field is an array and use `array-contains-all` if it were available,
    // but it's not. A workaround is to fetch all cards and filter client-side,
    // which is inefficient but works for smaller datasets.
    // For a real-world app, the data model should be optimized for this query.
    final allCards = await getAllCards();
    return allCards
        .where((card) =>
            card.colorIdentity.every((color) => colorIdentity.contains(color)))
        .toList();
  }

  Future<List<MTGCard>> getAutofillCards(
      String strategy, List<String> colorIdentity) async {
    // Mock autofill logic - this is difficult to implement purely in Firestore
    // without a more complex data model or a dedicated search service.
    // Returning a few staple cards that fit the color identity.
    final staples = [
      'sol-ring',
      'command-tower',
      'arcane-signet',
      'fellwar-stone'
    ];
    final cards = await getCardsByIds(staples);
    return cards
        .where((card) =>
            card.colorIdentity.every((color) => colorIdentity.contains(color)))
        .toList();
  }
}
