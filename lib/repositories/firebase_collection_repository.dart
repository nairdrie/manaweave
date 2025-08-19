import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:manaweave/models/card.dart';

class FirebaseCollectionRepository {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  User? get currentUser => _firebaseAuth.currentUser;

  CollectionReference<CollectionEntry> _collectionRef() {
    if (currentUser == null) {
      throw Exception('User not logged in');
    }
    return _firestore
        .collection('users')
        .doc(currentUser!.uid)
        .collection('collection')
        .withConverter<CollectionEntry>(
          fromFirestore: (snapshot, _) =>
              CollectionEntry.fromFirestore(snapshot.data()!),
          toFirestore: (entry, _) => entry.toFirestore(),
        );
  }

  Stream<List<CollectionEntry>> getCollection() {
    return _collectionRef().snapshots().map(
          (snapshot) => snapshot.docs.map((doc) => doc.data()).toList(),
        );
  }

  Future<void> addCard(String cardId, {int count = 1, int foilCount = 0}) async {
    final docRef = _collectionRef().doc(cardId);
    final doc = await docRef.get();

    if (doc.exists) {
      await docRef.update({
        'count': FieldValue.increment(count),
        'foilCount': FieldValue.increment(foilCount),
      });
    } else {
      await docRef.set(CollectionEntry(
        cardId: cardId,
        count: count,
        foilCount: foilCount,
      ));
    }
  }

  Future<void> removeCard(String cardId, {int count = 1, int foilCount = 0}) async {
    final docRef = _collectionRef().doc(cardId);
    final doc = await docRef.get();

    if (doc.exists) {
      final data = doc.data()!;
      final newCount = data.count - count;
      final newFoilCount = data.foilCount - foilCount;

      if (newCount <= 0 && newFoilCount <= 0) {
        await docRef.delete();
      } else {
        await docRef.update({
          'count': newCount.clamp(0, data.count),
          'foilCount': newFoilCount.clamp(0, data.foilCount),
        });
      }
    }
  }
}
