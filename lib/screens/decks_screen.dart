import 'package:flutter/material.dart';
import 'package:manaweave/models/card.dart';
import 'package:manaweave/repositories/firebase_deck_repository.dart';
import 'package:manaweave/repositories/firebase_card_repository.dart';
import 'package:manaweave/components/mana_cost_display.dart';
import 'package:manaweave/components/card_components.dart';
import 'package:manaweave/screens/deck_builder_screen.dart';
import 'package:manaweave/screens/commander_selection_screen.dart';
import 'package:provider/provider.dart';

class DecksScreen extends StatefulWidget {
  const DecksScreen({super.key});

  @override
  State<DecksScreen> createState() => _DecksScreenState();
}

class _DecksScreenState extends State<DecksScreen> {
  late final FirebaseDeckRepository _deckRepository;
  late final FirebaseCardRepository _cardRepository;

  @override
  void initState() {
    super.initState();
    _deckRepository = context.read<FirebaseDeckRepository>();
    _cardRepository = context.read<FirebaseCardRepository>();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('⚔️ Decks'),
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
        foregroundColor: Theme.of(context).colorScheme.onPrimaryContainer,
        actions: [
          IconButton(
            onPressed: _createNewDeck,
            icon: const Icon(Icons.add),
          ),
        ],
      ),
      body: _buildDecksList(),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _createNewDeck,
        icon: const Icon(Icons.add),
        label: const Text('New Deck'),
      ),
    );
  }

  Widget _buildDecksList() {
    return StreamBuilder<List<Deck>>(
      stream: _deckRepository.getDecks(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return _buildEmptyState();
        }

        final decks = snapshot.data!;
        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: decks.length,
          separatorBuilder: (context, index) => const SizedBox(height: 12),
          itemBuilder: (context, index) => _buildDeckCard(decks[index]),
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.style_outlined,
            size: 64,
            color: Theme.of(context).colorScheme.onSurfaceVariant.withOpacity(0.6),
          ),
          const SizedBox(height: 16),
          Text(
            'Create your first Commander deck',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'Build powerful 100-card decks with our smart autofill system',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant.withOpacity(0.8),
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          FilledButton.icon(
            onPressed: _createNewDeck,
            icon: const Icon(Icons.add),
            label: const Text('Create Deck'),
          ),
        ],
      ),
    );
  }

  Widget _buildDeckCard(Deck deck) {
    return FutureBuilder<MTGCard?>(
      future: deck.commanderIds.isNotEmpty
          ? _cardRepository.getCardById(deck.commanderIds.first)
          : Future.value(null),
      builder: (context, snapshot) {
        final commander = snapshot.data;
        // TODO: Implement validation error display
        final validationErrors = <String>[];
        final isValid = true;

        return Card(
          margin: EdgeInsets.zero,
          child: InkWell(
            onTap: () => _openDeckBuilder(deck),
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              deck.name,
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                            ),
                            if (deck.format != 'Commander')
                              Text(
                                deck.format,
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall
                                    ?.copyWith(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSurfaceVariant,
                                    ),
                              ),
                          ],
                        ),
                      ),
                      if (commander != null)
                        ColorIdentityPips(
                            colors: commander.colorIdentity, size: 18),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Commander
                  if (commander != null) ...[
                    Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(6),
                          child: Image.network(
                            commander.imageUrl,
                            width: 40,
                            height: 40,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                Container(
                              width: 40,
                              height: 40,
                              color: Theme.of(context)
                                  .colorScheme
                                  .surfaceContainer,
                              child: const Icon(Icons.person, size: 20),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                commander.name,
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyMedium
                                    ?.copyWith(
                                      fontWeight: FontWeight.w500,
                                    ),
                              ),
                              ManaCostRow(manaCost: commander.manaCost, size: 14),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                  ],

                  // Progress and Stats
                  Row(
                    children: [
                      Expanded(
                        child: _buildProgressIndicator(
                          'Cards',
                          deck.totalCards,
                          100,
                          isValid
                              ? Colors.green
                              : Theme.of(context).colorScheme.error,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildProgressIndicator(
                          'Lands',
                          deck.landCount,
                          deck.landGoal,
                          deck.landCount >= deck.landGoal
                              ? Colors.green
                              : Colors.orange,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Column(
                        children: [
                          Text(
                            'Avg CMC',
                            style: Theme.of(context)
                                .textTheme
                                .bodySmall
                                ?.copyWith(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onSurfaceVariant,
                                ),
                          ),
                          Text(
                            deck.averageCmc.toStringAsFixed(1),
                            style: Theme.of(context)
                                .textTheme
                                .titleSmall
                                ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                          ),
                        ],
                      ),
                    ],
                  ),

                  // Strategy Tags
                  if (deck.strategyTags.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    TagChips(tags: deck.strategyTags, maxVisible: 3),
                  ],

                  // Validation Errors
                  if (validationErrors.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 4,
                      runSpacing: 4,
                      children: validationErrors
                          .take(3)
                          .map((error) => ValidationChip(
                                text: error,
                                severity: error.contains('banned') ||
                                        error.contains('duplicates') ||
                                        error.contains('outside color')
                                    ? ValidationSeverity.error
                                    : ValidationSeverity.warning,
                              ))
                          .toList(),
                    ),
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildProgressIndicator(
      String label, int current, int target, Color color) {
    final progress = (current / target).clamp(0.0, 1.0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
            Text(
              '$current/$target',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w500,
                    color: color,
                  ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        LinearProgressIndicator(
          value: progress,
          backgroundColor:
              Theme.of(context).colorScheme.outline.withOpacity(0.2),
          valueColor: AlwaysStoppedAnimation<Color>(color),
        ),
      ],
    );
  }

  void _createNewDeck() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => CommanderSelectionScreen(
          onCommanderSelected: (commanderId, strategy) async {
            final commander = await _cardRepository.getCardById(commanderId);
            if (commander == null) return;

            final deckId = await _deckRepository.createNewDeck(
              '${commander.name} Deck',
              [commanderId],
              strategy: strategy,
            );

            if (mounted) {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(
                  builder: (context) => DeckBuilderScreen(deckId: deckId),
                ),
              );
            }
          },
        ),
      ),
    );
  }

  void _openDeckBuilder(Deck deck) {
    Navigator.of(context)
        .push(
          MaterialPageRoute(
            builder: (context) => DeckBuilderScreen(deckId: deck.id),
          ),
        )
        .then((_) => setState(() {})); // Refresh when returning
  }
}