import 'package:manaweave/models/card.dart';
import 'package:manaweave/repositories/card_repository.dart';

class CollectionRepository {
  static final CollectionRepository _instance = CollectionRepository._internal();
  factory CollectionRepository() => _instance;
  CollectionRepository._internal();

  final CardRepository _cardRepository = CardRepository();
  final List<CollectionEntry> _collection = [
    CollectionEntry(cardId: 'sol-ring', count: 3, foilCount: 1, purchasePrice: 1.25),
    CollectionEntry(cardId: 'command-tower', count: 2, purchasePrice: 0.50),
    CollectionEntry(cardId: 'cultivate', count: 1, purchasePrice: 0.25),
    CollectionEntry(cardId: 'swords-to-plowshares', count: 1, foilCount: 1, purchasePrice: 1.50),
    CollectionEntry(cardId: 'counterspell', count: 2, purchasePrice: 0.75),
    CollectionEntry(cardId: 'plains', count: 15, purchasePrice: 0.05),
    CollectionEntry(cardId: 'island', count: 12, purchasePrice: 0.05),
    CollectionEntry(cardId: 'teysa-karlov', count: 1, purchasePrice: 8.99),
  ];

  List<CollectionEntry> get collection => List.unmodifiable(_collection);
  
  CollectionEntry? getEntry(String cardId) {
    try {
      return _collection.firstWhere((entry) => entry.cardId == cardId);
    } catch (e) {
      return null;
    }
  }
  
  void addCard(String cardId, {int count = 1, int foilCount = 0}) {
    final existingIndex = _collection.indexWhere((entry) => entry.cardId == cardId);
    if (existingIndex != -1) {
      final existing = _collection[existingIndex];
      _collection[existingIndex] = CollectionEntry(
        cardId: cardId,
        count: existing.count + count,
        foilCount: existing.foilCount + foilCount,
        condition: existing.condition,
        purchasePrice: existing.purchasePrice,
      );
    } else {
      final card = _cardRepository.getCardById(cardId);
      if (card != null) {
        _collection.add(CollectionEntry(
          cardId: cardId,
          count: count,
          foilCount: foilCount,
          purchasePrice: card.price.usd,
        ));
      }
    }
  }
  
  void removeCard(String cardId, {int count = 1, int foilCount = 0}) {
    final existingIndex = _collection.indexWhere((entry) => entry.cardId == cardId);
    if (existingIndex != -1) {
      final existing = _collection[existingIndex];
      final newCount = (existing.count - count).clamp(0, existing.count);
      final newFoilCount = (existing.foilCount - foilCount).clamp(0, existing.foilCount);
      
      if (newCount == 0 && newFoilCount == 0) {
        _collection.removeAt(existingIndex);
      } else {
        _collection[existingIndex] = CollectionEntry(
          cardId: cardId,
          count: newCount,
          foilCount: newFoilCount,
          condition: existing.condition,
          purchasePrice: existing.purchasePrice,
        );
      }
    }
  }
  
  int getTotalCards() => _collection.fold(0, (sum, entry) => sum + entry.totalCount);
  
  int getUniqueCards() => _collection.length;
  
  int getFoilCount() => _collection.fold(0, (sum, entry) => sum + entry.foilCount);
  
  double getEstimatedValue() {
    double total = 0.0;
    for (final entry in _collection) {
      final card = _cardRepository.getCardById(entry.cardId);
      if (card != null) {
        total += (card.price.usd ?? 0.0) * entry.count;
        total += (card.price.usdFoil ?? card.price.usd ?? 0.0) * entry.foilCount;
      }
    }
    return total;
  }
  
  List<String> getOwnedCardIds() => _collection.map((entry) => entry.cardId).toList();
  
  void addCardsFromScan(List<ScanResult> scanResults) {
    for (final scanResult in scanResults) {
      if (scanResult.candidates.isNotEmpty) {
        final bestCandidate = scanResult.candidates.first;
        addCard(bestCandidate.cardId, count: scanResult.count);
      }
    }
  }
}