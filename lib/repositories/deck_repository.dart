import 'package:manaweave/models/card.dart';
import 'package:manaweave/repositories/card_repository.dart';

class DeckRepository {
  static final DeckRepository _instance = DeckRepository._internal();
  factory DeckRepository() => _instance;
  DeckRepository._internal();

  final CardRepository _cardRepository = CardRepository();
  final List<Deck> _decks = [
    Deck(
      id: 'deck-1',
      name: 'Teysa Aristocrats',
      commanderIds: ['teysa-karlov'],
      mainboard: [
        DeckEntry(cardId: 'sol-ring', qty: 1, section: 'Ramp', cmc: 1.0),
        DeckEntry(cardId: 'command-tower', qty: 1, section: 'Lands', cmc: 0.0),
        DeckEntry(cardId: 'swords-to-plowshares', qty: 1, section: 'Removal', cmc: 1.0),
        DeckEntry(cardId: 'plains', qty: 10, section: 'Lands', cmc: 0.0),
        DeckEntry(cardId: 'island', qty: 5, section: 'Lands', cmc: 0.0),
      ],
      landGoal: 36,
      strategyTags: ['Tokens', 'Aristocrats', 'Death-Triggers'],
      budgetPerCardUsd: 5.0,
      notes: 'Focus on token generation and sacrifice synergies.',
    ),
  ];

  List<Deck> get decks => List.unmodifiable(_decks);
  
  Deck? getDeckById(String id) {
    try {
      return _decks.firstWhere((deck) => deck.id == id);
    } catch (e) {
      return null;
    }
  }
  
  void saveDeck(Deck deck) {
    final existingIndex = _decks.indexWhere((d) => d.id == deck.id);
    if (existingIndex != -1) {
      _decks[existingIndex] = deck;
    } else {
      _decks.add(deck);
    }
  }
  
  void deleteDeck(String id) {
    _decks.removeWhere((deck) => deck.id == id);
  }
  
  Deck createNewDeck(String name, List<String> commanderIds, {String? strategy}) {
    final deck = Deck(
      id: 'deck-${DateTime.now().millisecondsSinceEpoch}',
      name: name,
      commanderIds: commanderIds,
      mainboard: [],
      strategyTags: strategy != null ? [strategy] : [],
    );
    _decks.add(deck);
    return deck;
  }
  
  void addCardToDeck(String deckId, String cardId, {String section = 'Flex Slots', int qty = 1}) {
    final deckIndex = _decks.indexWhere((d) => d.id == deckId);
    if (deckIndex == -1) return;
    
    final deck = _decks[deckIndex];
    final card = _cardRepository.getCardById(cardId);
    if (card == null) return;
    
    final existingEntryIndex = deck.mainboard.indexWhere((entry) => entry.cardId == cardId);
    List<DeckEntry> newMainboard = List.from(deck.mainboard);
    
    if (existingEntryIndex != -1) {
      final existingEntry = deck.mainboard[existingEntryIndex];
      newMainboard[existingEntryIndex] = DeckEntry(
        cardId: cardId,
        qty: existingEntry.qty + qty,
        section: existingEntry.section,
        cmc: existingEntry.cmc,
      );
    } else {
      newMainboard.add(DeckEntry(
        cardId: cardId,
        qty: qty,
        section: section,
        cmc: card.cmc,
      ));
    }
    
    _decks[deckIndex] = Deck(
      id: deck.id,
      name: deck.name,
      format: deck.format,
      commanderIds: deck.commanderIds,
      partnerEnabled: deck.partnerEnabled,
      backgroundId: deck.backgroundId,
      mainboard: newMainboard,
      landGoal: deck.landGoal,
      strategyTags: deck.strategyTags,
      budgetPerCardUsd: deck.budgetPerCardUsd,
      notes: deck.notes,
    );
  }
  
  void removeCardFromDeck(String deckId, String cardId, {int qty = 1}) {
    final deckIndex = _decks.indexWhere((d) => d.id == deckId);
    if (deckIndex == -1) return;
    
    final deck = _decks[deckIndex];
    final existingEntryIndex = deck.mainboard.indexWhere((entry) => entry.cardId == cardId);
    if (existingEntryIndex == -1) return;
    
    List<DeckEntry> newMainboard = List.from(deck.mainboard);
    final existingEntry = deck.mainboard[existingEntryIndex];
    final newQty = (existingEntry.qty - qty).clamp(0, existingEntry.qty);
    
    if (newQty == 0) {
      newMainboard.removeAt(existingEntryIndex);
    } else {
      newMainboard[existingEntryIndex] = DeckEntry(
        cardId: cardId,
        qty: newQty,
        section: existingEntry.section,
        cmc: existingEntry.cmc,
      );
    }
    
    _decks[deckIndex] = Deck(
      id: deck.id,
      name: deck.name,
      format: deck.format,
      commanderIds: deck.commanderIds,
      partnerEnabled: deck.partnerEnabled,
      backgroundId: deck.backgroundId,
      mainboard: newMainboard,
      landGoal: deck.landGoal,
      strategyTags: deck.strategyTags,
      budgetPerCardUsd: deck.budgetPerCardUsd,
      notes: deck.notes,
    );
  }
  
  List<String> getValidationErrors(Deck deck) {
    final errors = <String>[];
    final cards = <String, int>{}; // cardId -> total quantity
    
    // Count all cards
    for (final entry in deck.mainboard) {
      cards[entry.cardId] = (cards[entry.cardId] ?? 0) + entry.qty;
    }
    
    // Check deck size
    if (deck.totalCards != 100) {
      errors.add('Deck size ${deck.totalCards}/100');
    }
    
    // Check singleton rule
    for (final entry in cards.entries) {
      if (entry.value > 1) {
        final card = _cardRepository.getCardById(entry.key);
        if (card != null && !card.isBasicLand && !card.isAnyNumber) {
          errors.add('${entry.value}x ${card.name} (non-basic)');
        }
      }
    }
    
    // Check color identity
    final commanderColorIdentity = deck.commanderIds.isEmpty ? <String>[] :
      _cardRepository.getCardById(deck.commanderIds.first)?.colorIdentity ?? [];
    
    int colorIdentityViolations = 0;
    for (final entry in deck.mainboard) {
      final card = _cardRepository.getCardById(entry.cardId);
      if (card != null && !card.types.contains('Land')) {
        if (!card.colorIdentity.every((color) => commanderColorIdentity.contains(color))) {
          colorIdentityViolations++;
        }
      }
    }
    
    if (colorIdentityViolations > 0) {
      errors.add('$colorIdentityViolations cards outside color identity');
    }
    
    // Check banned cards
    int bannedCount = 0;
    for (final entry in deck.mainboard) {
      final card = _cardRepository.getCardById(entry.cardId);
      if (card != null && card.isBanned) {
        bannedCount++;
      }
    }
    
    if (bannedCount > 0) {
      errors.add('$bannedCount banned cards');
    }
    
    // Check land goal
    if (deck.landCount < deck.landGoal) {
      errors.add('Under land goal (${deck.landCount}/${deck.landGoal})');
    }
    
    return errors;
  }
  
  void autofillDeck(String deckId, AutofillConfig config) {
    final deckIndex = _decks.indexWhere((d) => d.id == deckId);
    if (deckIndex == -1) return;
    
    final deck = _decks[deckIndex];
    final commanderColorIdentity = deck.commanderIds.isEmpty ? <String>[] :
      _cardRepository.getCardById(deck.commanderIds.first)?.colorIdentity ?? [];
    
    // Mock autofill logic - add some cards based on strategy
    final autofillCards = _cardRepository.getAutofillCards(config.strategy, commanderColorIdentity);
    final newMainboard = List<DeckEntry>.from(deck.mainboard);
    
    int cardsToAdd = (100 - deck.totalCards).clamp(0, 30);
    for (int i = 0; i < cardsToAdd && i < autofillCards.length; i++) {
      final card = autofillCards[i];
      String section = 'Flex Slots';
      
      if (card.tags.contains('Ramp')) section = 'Ramp';
      else if (card.tags.contains('Card-Draw')) section = 'Card Draw';
      else if (card.tags.contains('Removal')) section = 'Removal';
      else if (card.tags.contains('Lands')) section = 'Lands';
      
      newMainboard.add(DeckEntry(
        cardId: card.id,
        qty: 1,
        section: section,
        cmc: card.cmc,
      ));
    }
    
    _decks[deckIndex] = Deck(
      id: deck.id,
      name: deck.name,
      format: deck.format,
      commanderIds: deck.commanderIds,
      partnerEnabled: deck.partnerEnabled,
      backgroundId: deck.backgroundId,
      mainboard: newMainboard,
      landGoal: config.landGoal,
      strategyTags: deck.strategyTags,
      budgetPerCardUsd: config.budgetPerCardUsd,
      notes: deck.notes,
    );
  }
}