import 'package:flutter/material.dart';
import 'package:manaweave/models/card.dart';
import 'package:manaweave/repositories/firebase_collection_repository.dart';
import 'package:manaweave/components/mana_cost_display.dart';
import 'package:manaweave/components/card_components.dart';
import 'package:provider/provider.dart';

class CardDetailScreen extends StatefulWidget {
  final MTGCard card;

  const CardDetailScreen({super.key, required this.card});

  @override
  State<CardDetailScreen> createState() => _CardDetailScreenState();
}

class _CardDetailScreenState extends State<CardDetailScreen> {
  late final FirebaseCollectionRepository _collectionRepository;

  @override
  void initState() {
    super.initState();
    _collectionRepository = context.read<FirebaseCollectionRepository>();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.card.name),
        backgroundColor: Theme.of(context).colorScheme.surface,
        scrolledUnderElevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildCardImage(),
            _buildCardInfo(),
            _buildOracleText(),
            _buildPriceInfo(),
            _buildLegalityInfo(),
            _buildCollectionControls(),
          ],
        ),
      ),
    );
  }

  Widget _buildCardImage() {
    return Container(
      height: 300,
      width: double.infinity,
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Image.network(
          widget.card.imageUrl,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => Container(
            color: Theme.of(context).colorScheme.surfaceContainer,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.image_not_supported,
                  size: 48,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
                const SizedBox(height: 8),
                Text(
                  'Image not available',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCardInfo() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Name and Mana Cost
          Row(
            children: [
              Expanded(
                child: Text(
                  widget.card.name,
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              ManaCostRow(manaCost: widget.card.manaCost, size: 24),
            ],
          ),
          const SizedBox(height: 8),
          
          // Type Line
          Text(
            widget.card.typeLine,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 8),
          
          // Set and Rarity
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${widget.card.set} #${widget.card.collectorNumber}',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onPrimaryContainer,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _getRarityColor(widget.card.rarity).withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: _getRarityColor(widget.card.rarity).withValues(alpha: 0.5)),
                ),
                child: Text(
                  widget.card.rarity,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: _getRarityColor(widget.card.rarity),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const Spacer(),
              ColorIdentityPips(colors: widget.card.colorIdentity, size: 20),
            ],
          ),
          const SizedBox(height: 8),
          
          // Badges
          CardBadges(card: widget.card),
          const SizedBox(height: 8),
          
          // Tags
          TagChips(tags: widget.card.tags, maxVisible: 5),
        ],
      ),
    );
  }

  Widget _buildOracleText() {
    if (widget.card.oracleText.isEmpty) return const SizedBox.shrink();
    
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Rules Text',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            widget.card.oracleText,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPriceInfo() {
    if (widget.card.price.usd == null && widget.card.price.usdFoil == null) {
      return const SizedBox.shrink();
    }
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Pricing',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              if (widget.card.price.usd != null) ...[
                Expanded(
                  child: _buildPriceItem('Regular', widget.card.price.usd!),
                ),
                if (widget.card.price.usdFoil != null) const SizedBox(width: 16),
              ],
              if (widget.card.price.usdFoil != null) ...[
                Expanded(
                  child: _buildPriceItem('Foil', widget.card.price.usdFoil!),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPriceItem(String label, double price) {
    return Column(
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '\$${price.toStringAsFixed(2)}',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
      ],
    );
  }

  Widget _buildLegalityInfo() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Format Legality',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 4,
            children: widget.card.legalities.entries.map((entry) {
              final isLegal = entry.value == 'legal';
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: isLegal 
                    ? Colors.green.withValues(alpha: 0.2)
                    : Theme.of(context).colorScheme.errorContainer,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: isLegal 
                      ? Colors.green.withValues(alpha: 0.5)
                      : Theme.of(context).colorScheme.error.withValues(alpha: 0.5),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      isLegal ? Icons.check_circle : Icons.cancel,
                      size: 14,
                      color: isLegal ? Colors.green : Theme.of(context).colorScheme.error,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      entry.key.toUpperCase(),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: isLegal ? Colors.green : Theme.of(context).colorScheme.error,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildCollectionControls() {
    return StreamBuilder<List<CollectionEntry>>(
      stream: _collectionRepository.getCollection(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        final collectionEntries = snapshot.data!;
        final entry = collectionEntries.firstWhere((e) => e.cardId == widget.card.id, orElse: () => CollectionEntry(cardId: widget.card.id, count: 0));

        return Container(
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primaryContainer.withOpacity(0.3),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Collection',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
              const SizedBox(height: 16),
              if (entry.totalCount > 0) ...[
                Row(
                  children: [
                    Text(
                      'Regular Copies:',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const Spacer(),
                    CountStepper(
                      value: entry.count,
                      onChanged: (newCount) =>
                          _updateCount(newCount, entry.foilCount),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Text(
                      'Foil Copies:',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const Spacer(),
                    CountStepper(
                      value: entry.foilCount,
                      onChanged: (newCount) =>
                          _updateCount(entry.count, newCount),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Text(
                      'Total Owned:',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                    const Spacer(),
                    Text(
                      '${entry.totalCount}',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                    ),
                  ],
                ),
              ] else ...[
                Text(
                  'Not in your collection',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: _addToCollection,
                    icon: const Icon(Icons.add_circle_outline),
                    label: const Text('Add to Collection'),
                  ),
                ),
              ],
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: _showComingSoonSnackBar,
                  icon: const Icon(Icons.style_outlined),
                  label: const Text('Add to Deck'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Color _getRarityColor(String rarity) {
    switch (rarity.toLowerCase()) {
      case 'common':
        return Colors.grey;
      case 'uncommon':
        return Colors.green;
      case 'rare':
        return Colors.amber;
      case 'mythic':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  void _updateCount(int regularCount, int foilCount) {
    final currentEntry = _collectionRepository.getEntry(widget.card.id);
    if (currentEntry == null) return;
    
    // Remove all current copies
    _collectionRepository.removeCard(
      widget.card.id,
      count: currentEntry.count,
      foilCount: currentEntry.foilCount,
    );
    
    // Add new counts
    if (regularCount > 0 || foilCount > 0) {
      _collectionRepository.addCard(
        widget.card.id,
        count: regularCount,
        foilCount: foilCount,
      );
    }
    
    setState(() {});
  }

  void _addToCollection() {
    _collectionRepository.addCard(widget.card.id);
    setState(() {});
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Added ${widget.card.name} to collection')),
    );
  }

  void _showComingSoonSnackBar() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Add to Deck feature coming soon!')),
    );
  }
}