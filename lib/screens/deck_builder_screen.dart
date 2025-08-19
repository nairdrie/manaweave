import 'package:flutter/material.dart';
import 'package:manaweave/models/card.dart';
import 'package:manaweave/repositories/deck_repository.dart';
import 'package:manaweave/repositories/card_repository.dart';
import 'package:manaweave/components/mana_cost_display.dart';
import 'package:manaweave/components/card_components.dart';

class DeckBuilderScreen extends StatefulWidget {
  final String deckId;

  const DeckBuilderScreen({super.key, required this.deckId});

  @override
  State<DeckBuilderScreen> createState() => _DeckBuilderScreenState();
}

class _DeckBuilderScreenState extends State<DeckBuilderScreen> {
  final DeckRepository _deckRepository = DeckRepository();
  final CardRepository _cardRepository = CardRepository();

  @override
  Widget build(BuildContext context) {
    final deck = _deckRepository.getDeckById(widget.deckId);
    if (deck == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Deck Not Found')),
        body: const Center(child: Text('Deck not found')),
      );
    }

    final commander = deck.commanderIds.isNotEmpty 
      ? _cardRepository.getCardById(deck.commanderIds.first)
      : null;
    final validationErrors = _deckRepository.getValidationErrors(deck);

    return Scaffold(
      appBar: AppBar(
        title: Text(deck.name),
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
        foregroundColor: Theme.of(context).colorScheme.onPrimaryContainer,
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) => _handleMenuAction(value, deck),
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'autofill', child: Text('Autofill...')),
              const PopupMenuItem(value: 'suggest_lands', child: Text('Suggest Lands...')),
              const PopupMenuItem(value: 'export', child: Text('Export')),
              const PopupMenuItem(value: 'delete', child: Text('Delete Deck')),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          _buildDeckHeader(deck, commander),
          if (validationErrors.isNotEmpty) _buildValidationPanel(validationErrors),
          Expanded(child: _buildDeckList(deck)),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showComingSoonSnackBar('Add Cards'),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildDeckHeader(Deck deck, MTGCard? commander) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainer,
      ),
      child: Column(
        children: [
          // Commander
          if (commander != null) ...[
            CommanderTile(commander: commander),
            const SizedBox(height: 12),
          ],
          
          // Stats Row
          Row(
            children: [
              Expanded(child: _buildStatCard('Cards', '${deck.totalCards}/100')),
              const SizedBox(width: 8),
              Expanded(child: _buildStatCard('Lands', '${deck.landCount}/${deck.landGoal}')),
              const SizedBox(width: 8),
              Expanded(child: _buildStatCard('Avg CMC', deck.averageCmc.toStringAsFixed(1))),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String label, String value) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildValidationPanel(List<String> errors) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.errorContainer.withValues(alpha: 0.3),
        border: Border(
          bottom: BorderSide(
            color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.warning_amber,
                color: Theme.of(context).colorScheme.error,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Deck Issues',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: Theme.of(context).colorScheme.error,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 4,
            children: errors.map((error) => ValidationChip(
              text: error,
              severity: error.contains('banned') || error.contains('duplicates') || error.contains('outside color')
                ? ValidationSeverity.error
                : ValidationSeverity.warning,
            )).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildDeckList(Deck deck) {
    // Group cards by section
    final sections = <String, List<DeckEntry>>{};
    for (final entry in deck.mainboard) {
      sections[entry.section] = sections[entry.section] ?? [];
      sections[entry.section]!.add(entry);
    }

    if (sections.isEmpty) {
      return _buildEmptyDeckState();
    }

    final sectionNames = sections.keys.toList()..sort();

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: sectionNames.length,
      itemBuilder: (context, index) {
        final sectionName = sectionNames[index];
        final sectionEntries = sections[sectionName]!;
        return _buildSection(sectionName, sectionEntries);
      },
    );
  }

  Widget _buildEmptyDeckState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.auto_fix_high,
            size: 64,
            color: Theme.of(context).colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
          ),
          const SizedBox(height: 16),
          Text(
            'Your deck is empty',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Use Autofill to get started quickly',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant.withValues(alpha: 0.8),
            ),
          ),
          const SizedBox(height: 24),
          FilledButton.icon(
            onPressed: () => _showAutofillDialog(),
            icon: const Icon(Icons.auto_fix_high),
            label: const Text('Autofill Deck'),
          ),
        ],
      ),
    );
  }

  Widget _buildSection(String sectionName, List<DeckEntry> entries) {
    final totalCards = entries.fold(0, (sum, entry) => sum + entry.qty);
    
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ExpansionTile(
        title: Text(
          sectionName,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Text('$totalCards cards'),
        children: entries.map((entry) => _buildCardEntry(entry)).toList(),
      ),
    );
  }

  Widget _buildCardEntry(DeckEntry entry) {
    final card = _cardRepository.getCardById(entry.cardId);
    if (card == null) return const SizedBox.shrink();

    return ListTile(
      leading: ClipRRect(
        borderRadius: BorderRadius.circular(4),
        child: Image.network(
          card.imageUrl,
          width: 32,
          height: 32,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => Container(
            width: 32,
            height: 32,
            color: Theme.of(context).colorScheme.surfaceContainer,
            child: const Icon(Icons.image_not_supported, size: 16),
          ),
        ),
      ),
      title: Text(card.name),
      subtitle: Row(
        children: [
          ManaCostRow(manaCost: card.manaCost, size: 14),
          const SizedBox(width: 8),
          Text(card.typeLine),
        ],
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('${entry.qty}x'),
          const SizedBox(width: 8),
          PopupMenuButton<String>(
            onSelected: (value) => _handleCardAction(entry, value),
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'increase', child: Text('Add Copy')),
              const PopupMenuItem(value: 'decrease', child: Text('Remove Copy')),
              const PopupMenuItem(value: 'remove', child: Text('Remove All')),
            ],
          ),
        ],
      ),
      onTap: () {
        // Show card detail or quick actions
        _showComingSoonSnackBar('Card Details');
      },
    );
  }

  void _handleMenuAction(String action, Deck deck) {
    switch (action) {
      case 'autofill':
        _showAutofillDialog();
        break;
      case 'suggest_lands':
        _showComingSoonSnackBar('Suggest Lands');
        break;
      case 'export':
        _showComingSoonSnackBar('Export');
        break;
      case 'delete':
        _showDeleteConfirmation(deck);
        break;
    }
  }

  void _handleCardAction(DeckEntry entry, String action) {
    switch (action) {
      case 'increase':
        _deckRepository.addCardToDeck(widget.deckId, entry.cardId, section: entry.section);
        setState(() {});
        break;
      case 'decrease':
        _deckRepository.removeCardFromDeck(widget.deckId, entry.cardId);
        setState(() {});
        break;
      case 'remove':
        _deckRepository.removeCardFromDeck(widget.deckId, entry.cardId, qty: entry.qty);
        setState(() {});
        break;
    }
  }

  void _showAutofillDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Autofill Deck'),
        content: const Text('This will add cards to your deck based on your commander and strategy. Continue?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.of(context).pop();
              _performAutofill();
            },
            child: const Text('Autofill'),
          ),
        ],
      ),
    );
  }

  void _performAutofill() {
    final deck = _deckRepository.getDeckById(widget.deckId);
    if (deck == null) return;

    final config = AutofillConfig(
      strategy: deck.strategyTags.isNotEmpty ? deck.strategyTags.first : 'Balanced',
      landGoal: deck.landGoal,
    );

    _deckRepository.autofillDeck(widget.deckId, config);
    setState(() {});

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Deck autofilled!')),
    );
  }

  void _showDeleteConfirmation(Deck deck) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Deck'),
        content: Text('Are you sure you want to delete "${deck.name}"? This cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.of(context).pop();
              _deckRepository.deleteDeck(widget.deckId);
              Navigator.of(context).pop();
            },
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _showComingSoonSnackBar(String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$feature feature coming soon!')),
    );
  }
}