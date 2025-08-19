import 'package:manaweave/models/card.dart';

class CardRepository {
  static final CardRepository _instance = CardRepository._internal();
  factory CardRepository() => _instance;
  CardRepository._internal();

  // Mock card database
  final List<MTGCard> _allCards = [
    // Commanders
    MTGCard(
      id: 'atraxa-grand-unifier',
      name: 'Atraxa, Grand Unifier',
      set: 'ONE',
      collectorNumber: '196',
      manaCost: '{2}{G}{W}{U}{B}',
      cmc: 7.0,
      colors: ['G', 'W', 'U', 'B'],
      colorIdentity: ['G', 'W', 'U', 'B'],
      types: ['Creature'],
      supertypes: ['Legendary'],
      subtypes: ['Phyrexian', 'Angel'],
      rarity: 'Mythic',
      imageUrl: 'https://pixabay.com/get/gd367d87fc0567b290146fd000632f2fabdf910c20865d4b43a2eca87a9d4ddd1d377c6beb871553cda60879fccf125e2576bbd16e1796aec8a98b0f98e0c8bdd_1280.png',
      oracleText: 'Flying, vigilance, deathtouch, lifelink\nWhen Atraxa, Grand Unifier enters the battlefield, reveal the top ten cards of your library. For each card type among them, put a card of that type into your hand and the rest on the bottom of your library in a random order.',
      legalities: {'commander': 'legal'},
      isAnyNumber: false,
      price: CardPrice(usd: 25.99, usdFoil: 45.99),
      tags: ['Value', 'Control', 'ETB'],
    ),
    MTGCard(
      id: 'teysa-karlov',
      name: 'Teysa Karlov',
      set: 'RNA',
      collectorNumber: '212',
      manaCost: '{2}{W}{B}',
      cmc: 4.0,
      colors: ['W', 'B'],
      colorIdentity: ['W', 'B'],
      types: ['Creature'],
      supertypes: ['Legendary'],
      subtypes: ['Human', 'Advisor'],
      rarity: 'Rare',
      imageUrl: 'https://pixabay.com/get/g81414e5dc80ce7bc040a5d4bbab21e03308f92fcc1364373113342118bfe875afd9474f8f5dc55c90891789a2f0d44e92b2d3daff82532b758178c6af75dda46_1280.jpg',
      oracleText: 'If a creature dying causes a triggered ability of a permanent you control to trigger, that ability triggers an additional time.\nCreature tokens you control have vigilance and lifelink.',
      legalities: {'commander': 'legal'},
      isAnyNumber: false,
      price: CardPrice(usd: 8.99, usdFoil: 18.99),
      tags: ['Tokens', 'Death-Triggers', 'Value'],
    ),
    MTGCard(
      id: 'ezuri-claw-of-progress',
      name: 'Ezuri, Claw of Progress',
      set: 'C15',
      collectorNumber: '44',
      manaCost: '{2}{G}{U}',
      cmc: 4.0,
      colors: ['G', 'U'],
      colorIdentity: ['G', 'U'],
      types: ['Creature'],
      supertypes: ['Legendary'],
      subtypes: ['Elf', 'Warrior'],
      rarity: 'Mythic',
      imageUrl: 'https://pixabay.com/get/g9c1eb4d0cf72d64855516c3c39bbfe2d3394cf507bb6e351a98af2850ff209f249078a063c1214bafb54ed79df221d790ce7aba6f9a4901dac4990e5f719b4da_1280.jpg',
      oracleText: 'Whenever a creature with power 2 or less enters the battlefield under your control, you get an experience counter.\nAt the beginning of combat on your turn, put X +1/+1 counters on another target creature you control, where X is the number of experience counters you have.',
      legalities: {'commander': 'legal'},
      isAnyNumber: false,
      price: CardPrice(usd: 12.50, usdFoil: 25.00),
      tags: ['Counters', 'Small-Creatures', 'Experience'],
    ),
    // Staple Cards
    MTGCard(
      id: 'sol-ring',
      name: 'Sol Ring',
      set: 'CMD',
      collectorNumber: '261',
      manaCost: '{1}',
      cmc: 1.0,
      colors: [],
      colorIdentity: [],
      types: ['Artifact'],
      supertypes: [],
      subtypes: [],
      rarity: 'Uncommon',
      imageUrl: 'https://pixabay.com/get/g52992386fa00603a7b3bd8622185241a8a814befa71ddb83be14229caad58320e71472a8ee7ba4daf9cef19761d85144106abfe346d3850d77d503415c47b960_1280.jpg',
      oracleText: '{T}: Add {C}{C}.',
      legalities: {'commander': 'legal'},
      isAnyNumber: false,
      price: CardPrice(usd: 1.25, usdFoil: 5.00),
      tags: ['Ramp', 'Artifact', 'Staple'],
    ),
    MTGCard(
      id: 'command-tower',
      name: 'Command Tower',
      set: 'CMD',
      collectorNumber: '281',
      manaCost: '',
      cmc: 0.0,
      colors: [],
      colorIdentity: [],
      types: ['Land'],
      supertypes: [],
      subtypes: [],
      rarity: 'Common',
      imageUrl: 'https://pixabay.com/get/g9c1eb4d0cf72d64855516c3c39bbfe2d3394cf507bb6e351a98af2850ff209f249078a063c1214bafb54ed79df221d790ce7aba6f9a4901dac4990e5f719b4da_1280.jpg',
      oracleText: '{T}: Add one mana of any color in your commander\'s color identity.',
      legalities: {'commander': 'legal'},
      isAnyNumber: false,
      price: CardPrice(usd: 0.50, usdFoil: 2.00),
      tags: ['Lands', 'Commander-Staple', 'Multicolor'],
    ),
    MTGCard(
      id: 'cultivate',
      name: 'Cultivate',
      set: 'M21',
      collectorNumber: '177',
      manaCost: '{2}{G}',
      cmc: 3.0,
      colors: ['G'],
      colorIdentity: ['G'],
      types: ['Sorcery'],
      supertypes: [],
      subtypes: [],
      rarity: 'Common',
      imageUrl: 'https://pixabay.com/get/g81414e5dc80ce7bc040a5d4bbab21e03308f92fcc1364373113342118bfe875afd9474f8f5dc55c90891789a2f0d44e92b2d3daff82532b758178c6af75dda46_1280.jpg',
      oracleText: 'Search your library for up to two basic land cards, reveal them, put one onto the battlefield tapped and the other into your hand, then shuffle.',
      legalities: {'commander': 'legal'},
      isAnyNumber: false,
      price: CardPrice(usd: 0.25, usdFoil: 1.50),
      tags: ['Ramp', 'Land-Ramp', 'Green'],
    ),
    MTGCard(
      id: 'swords-to-plowshares',
      name: 'Swords to Plowshares',
      set: 'CMR',
      collectorNumber: '387',
      manaCost: '{W}',
      cmc: 1.0,
      colors: ['W'],
      colorIdentity: ['W'],
      types: ['Instant'],
      supertypes: [],
      subtypes: [],
      rarity: 'Uncommon',
      imageUrl: 'https://pixabay.com/get/gd367d87fc0567b290146fd000632f2fabdf910c20865d4b43a2eca87a9d4ddd1d377c6beb871553cda60879fccf125e2576bbd16e1796aec8a98b0f98e0c8bdd_1280.png',
      oracleText: 'Exile target creature. Its controller gains life equal to its power.',
      legalities: {'commander': 'legal'},
      isAnyNumber: false,
      price: CardPrice(usd: 1.50, usdFoil: 5.00),
      tags: ['Removal', 'White', 'Efficient'],
    ),
    MTGCard(
      id: 'counterspell',
      name: 'Counterspell',
      set: 'CMR',
      collectorNumber: '395',
      manaCost: '{U}{U}',
      cmc: 2.0,
      colors: ['U'],
      colorIdentity: ['U'],
      types: ['Instant'],
      supertypes: [],
      subtypes: [],
      rarity: 'Common',
      imageUrl: 'https://pixabay.com/get/g8b58c71149511974865cd86cd55da59a519f79d6fdb9ed686bcc7668b08a5828e2f1356787f59b7f896104727bdaa5f0a4e979e885504756d26f35352bbaee17_1280.png',
      oracleText: 'Counter target spell.',
      legalities: {'commander': 'legal'},
      isAnyNumber: false,
      price: CardPrice(usd: 0.75, usdFoil: 3.00),
      tags: ['Counterspell', 'Blue', 'Control'],
    ),
    // Basic Lands
    MTGCard(
      id: 'plains',
      name: 'Plains',
      set: 'UNF',
      collectorNumber: '235',
      manaCost: '',
      cmc: 0.0,
      colors: [],
      colorIdentity: [],
      types: ['Land'],
      supertypes: ['Basic'],
      subtypes: ['Plains'],
      rarity: 'Common',
      imageUrl: 'https://pixabay.com/get/g81414e5dc80ce7bc040a5d4bbab21e03308f92fcc1364373113342118bfe875afd9474f8f5dc55c90891789a2f0d44e92b2d3daff82532b758178c6af75dda46_1280.jpg',
      oracleText: '{T}: Add {W}.',
      legalities: {'commander': 'legal'},
      isAnyNumber: true,
      price: CardPrice(usd: 0.05, usdFoil: 0.25),
      tags: ['Lands', 'Basic'],
    ),
    MTGCard(
      id: 'island',
      name: 'Island',
      set: 'UNF',
      collectorNumber: '236',
      manaCost: '',
      cmc: 0.0,
      colors: [],
      colorIdentity: [],
      types: ['Land'],
      supertypes: ['Basic'],
      subtypes: ['Island'],
      rarity: 'Common',
      imageUrl: 'https://pixabay.com/get/g8b58c71149511974865cd86cd55da59a519f79d6fdb9ed686bcc7668b08a5828e2f1356787f59b7f896104727bdaa5f0a4e979e885504756d26f35352bbaee17_1280.png',
      oracleText: '{T}: Add {U}.',
      legalities: {'commander': 'legal'},
      isAnyNumber: true,
      price: CardPrice(usd: 0.05, usdFoil: 0.25),
      tags: ['Lands', 'Basic'],
    ),
    // Banned card example
    MTGCard(
      id: 'black-lotus',
      name: 'Black Lotus',
      set: 'LEA',
      collectorNumber: '232',
      manaCost: '{0}',
      cmc: 0.0,
      colors: [],
      colorIdentity: [],
      types: ['Artifact'],
      supertypes: [],
      subtypes: [],
      rarity: 'Rare',
      imageUrl: 'https://pixabay.com/get/g52992386fa00603a7b3bd8622185241a8a814befa71ddb83be14229caad58320e71472a8ee7ba4daf9cef19761d85144106abfe346d3850d77d503415c47b960_1280.jpg',
      oracleText: '{T}, Sacrifice Black Lotus: Add three mana of any one color.',
      legalities: {'commander': 'banned'},
      isAnyNumber: false,
      price: CardPrice(usd: 25000.00),
      tags: ['Power-Nine', 'Banned'],
    ),
  ];

  List<MTGCard> get allCards => List.unmodifiable(_allCards);
  
  MTGCard? getCardById(String id) {
    try {
      return _allCards.firstWhere((card) => card.id == id);
    } catch (e) {
      return null;
    }
  }
  
  List<MTGCard> getCommanderCards() => _allCards.where((card) => card.isLegendary && card.types.contains('Creature')).toList();
  
  List<MTGCard> searchCards(String query) => _allCards.where((card) => 
    card.name.toLowerCase().contains(query.toLowerCase()) ||
    card.oracleText.toLowerCase().contains(query.toLowerCase()) ||
    card.typeLine.toLowerCase().contains(query.toLowerCase())
  ).toList();
  
  List<MTGCard> getCardsByColorIdentity(List<String> colorIdentity) {
    if (colorIdentity.isEmpty) return _allCards;
    return _allCards.where((card) => 
      card.colorIdentity.every((color) => colorIdentity.contains(color))
    ).toList();
  }
  
  List<MTGCard> getAutofillCards(String strategy, List<String> colorIdentity) {
    // Mock autofill logic
    final strategyMap = {
      'Blink': ['ETB', 'Blink', 'Value'],
      'Tokens': ['Tokens', 'Anthems', 'Token-Generation'],
      'Control': ['Counterspell', 'Control', 'Card-Draw'],
      'Voltron': ['Equipment', 'Auras', 'Protection'],
      'Ramp': ['Ramp', 'Land-Ramp', 'Mana'],
    };
    
    final relevantTags = strategyMap[strategy] ?? [];
    return _allCards.where((card) => 
      card.tags.any((tag) => relevantTags.contains(tag)) &&
      card.colorIdentity.every((color) => colorIdentity.contains(color)) &&
      !card.isLegendary
    ).take(30).toList();
  }
}