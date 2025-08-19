class MTGCard {
  final String id;
  final String name;
  final String set;
  final String collectorNumber;
  final String manaCost;
  final double cmc;
  final List<String> colors;
  final List<String> colorIdentity;
  final List<String> types;
  final List<String> supertypes;
  final List<String> subtypes;
  final String rarity;
  final String imageUrl;
  final String oracleText;
  final Map<String, String> legalities;
  final bool isAnyNumber;
  final CardPrice price;
  final List<String> tags;

  const MTGCard({
    required this.id,
    required this.name,
    required this.set,
    required this.collectorNumber,
    required this.manaCost,
    required this.cmc,
    required this.colors,
    required this.colorIdentity,
    required this.types,
    required this.supertypes,
    required this.subtypes,
    required this.rarity,
    required this.imageUrl,
    required this.oracleText,
    required this.legalities,
    required this.isAnyNumber,
    required this.price,
    required this.tags,
  });

  factory MTGCard.fromFirestore(Map<String, dynamic> data, String documentId) {
    return MTGCard(
      id: documentId,
      name: data['name'] ?? '',
      set: data['set'] ?? '',
      collectorNumber: data['collectorNumber'] ?? '',
      manaCost: data['manaCost'] ?? '',
      cmc: (data['cmc'] as num?)?.toDouble() ?? 0.0,
      colors: List<String>.from(data['colors'] ?? []),
      colorIdentity: List<String>.from(data['colorIdentity'] ?? []),
      types: List<String>.from(data['types'] ?? []),
      supertypes: List<String>.from(data['supertypes'] ?? []),
      subtypes: List<String>.from(data['subtypes'] ?? []),
      rarity: data['rarity'] ?? '',
      imageUrl: data['imageUrl'] ?? '',
      oracleText: data['oracleText'] ?? '',
      legalities: Map<String, String>.from(data['legalities'] ?? {}),
      isAnyNumber: data['isAnyNumber'] ?? false,
      price: CardPrice.fromFirestore(data['price'] ?? {}),
      tags: List<String>.from(data['tags'] ?? []),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'set': set,
      'collectorNumber': collectorNumber,
      'manaCost': manaCost,
      'cmc': cmc,
      'colors': colors,
      'colorIdentity': colorIdentity,
      'types': types,
      'supertypes': supertypes,
      'subtypes': subtypes,
      'rarity': rarity,
      'imageUrl': imageUrl,
      'oracleText': oracleText,
      'legalities': legalities,
      'isAnyNumber': isAnyNumber,
      'price': price.toFirestore(),
      'tags': tags,
    };
  }

  bool get isLegendary => supertypes.contains('Legendary');
  bool get isBanned => legalities['commander'] == 'banned';
  bool get isBasicLand => types.contains('Land') && supertypes.contains('Basic');
  
  String get typeLine {
    final supertypeStr = supertypes.isNotEmpty ? '${supertypes.join(' ')} ' : '';
    final typeStr = types.join(' ');
    final subtypeStr = subtypes.isNotEmpty ? ' — ${subtypes.join(' ')}' : '';
    return '$supertypeStr$typeStr$subtypeStr';
  }
}

class CardPrice {
  final double? usd;
  final double? usdFoil;

  const CardPrice({this.usd, this.usdFoil});

  factory CardPrice.fromFirestore(Map<String, dynamic> data) {
    return CardPrice(
      usd: (data['usd'] as num?)?.toDouble(),
      usdFoil: (data['usdFoil'] as num?)?.toDouble(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'usd': usd,
      'usdFoil': usdFoil,
    };
  }
}

class CollectionEntry {
  final String cardId;
  final int count;
  final int foilCount;
  final String condition;
  final double? purchasePrice;

  const CollectionEntry({
    required this.cardId,
    required this.count,
    this.foilCount = 0,
    this.condition = 'NM',
    this.purchasePrice,
  });

  factory CollectionEntry.fromFirestore(Map<String, dynamic> data) {
    return CollectionEntry(
      cardId: data['cardId'] ?? '',
      count: data['count'] ?? 0,
      foilCount: data['foilCount'] ?? 0,
      condition: data['condition'] ?? 'NM',
      purchasePrice: (data['purchasePrice'] as num?)?.toDouble(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'cardId': cardId,
      'count': count,
      'foilCount': foilCount,
      'condition': condition,
      'purchasePrice': purchasePrice,
    };
  }

  int get totalCount => count + foilCount;
}

class Deck {
  final String id;
  final String name;
  final String format;
  final List<String> commanderIds;
  final bool partnerEnabled;
  final String? backgroundId;
  final List<DeckEntry> mainboard;
  final int landGoal;
  final List<String> strategyTags;
  final double? budgetPerCardUsd;
  final String notes;

  const Deck({
    required this.id,
    required this.name,
    this.format = 'Commander',
    required this.commanderIds,
    this.partnerEnabled = false,
    this.backgroundId,
    required this.mainboard,
    this.landGoal = 36,
    this.strategyTags = const [],
    this.budgetPerCardUsd,
    this.notes = '',
  });

  factory Deck.fromFirestore(Map<String, dynamic> data, String documentId) {
    return Deck(
      id: documentId,
      name: data['name'] ?? '',
      format: data['format'] ?? 'Commander',
      commanderIds: List<String>.from(data['commanderIds'] ?? []),
      partnerEnabled: data['partnerEnabled'] ?? false,
      backgroundId: data['backgroundId'],
      mainboard: (data['mainboard'] as List<dynamic>?)
              ?.map((e) => DeckEntry.fromFirestore(e as Map<String, dynamic>))
              .toList() ??
          [],
      landGoal: data['landGoal'] ?? 36,
      strategyTags: List<String>.from(data['strategyTags'] ?? []),
      budgetPerCardUsd: (data['budgetPerCardUsd'] as num?)?.toDouble(),
      notes: data['notes'] ?? '',
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'format': format,
      'commanderIds': commanderIds,
      'partnerEnabled': partnerEnabled,
      'backgroundId': backgroundId,
      'mainboard': mainboard.map((e) => e.toFirestore()).toList(),
      'landGoal': landGoal,
      'strategyTags': strategyTags,
      'budgetPerCardUsd': budgetPerCardUsd,
      'notes': notes,
    };
  }

  int get totalCards => commanderIds.length + mainboard.fold(0, (sum, entry) => sum + entry.qty);
  int get nonCommanderCards => mainboard.fold(0, (sum, entry) => sum + entry.qty);
  int get landCount => mainboard.where((entry) => entry.section == 'Lands').fold(0, (sum, entry) => sum + entry.qty);
  double get averageCmc => mainboard.isEmpty ? 0.0 : mainboard.fold(0.0, (sum, entry) => sum + (entry.cmc * entry.qty)) / nonCommanderCards;
}

class DeckEntry {
  final String cardId;
  final int qty;
  final String section;
  final double cmc;

  const DeckEntry({
    required this.cardId,
    required this.qty,
    required this.section,
    this.cmc = 0.0,
  });

  factory DeckEntry.fromFirestore(Map<String, dynamic> data) {
    return DeckEntry(
      cardId: data['cardId'] ?? '',
      qty: data['qty'] ?? 0,
      section: data['section'] ?? '',
      cmc: (data['cmc'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'cardId': cardId,
      'qty': qty,
      'section': section,
      'cmc': cmc,
    };
  }
}

class ScanResult {
  final String imagePath;
  final List<ScanCandidate> candidates;
  final int count;

  const ScanResult({
    required this.imagePath,
    required this.candidates,
    this.count = 1,
  });
}

class ScanCandidate {
  final String cardId;
  final double confidence;

  const ScanCandidate({required this.cardId, required this.confidence});
}

class AutofillConfig {
  final String strategy;
  final bool respectCollection;
  final int landGoal;
  final int rampTarget;
  final int drawTarget;
  final int removalTarget;
  final int wipeTarget;
  final int interactionTarget;
  final double? budgetPerCardUsd;

  const AutofillConfig({
    required this.strategy,
    this.respectCollection = true,
    this.landGoal = 36,
    this.rampTarget = 8,
    this.drawTarget = 8,
    this.removalTarget = 8,
    this.wipeTarget = 3,
    this.interactionTarget = 6,
    this.budgetPerCardUsd,
  });
}