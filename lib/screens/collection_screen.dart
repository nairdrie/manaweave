import 'package:flutter/material.dart';
import 'package:manaweave/models/card.dart';
import 'package:manaweave/repositories/card_repository.dart';
import 'package:manaweave/repositories/collection_repository.dart';
import 'package:manaweave/components/mana_cost_display.dart';
import 'package:manaweave/components/card_components.dart';
import 'package:manaweave/screens/card_detail_screen.dart';

class CollectionScreen extends StatefulWidget {
  const CollectionScreen({super.key});

  @override
  State<CollectionScreen> createState() => _CollectionScreenState();
}

class _CollectionScreenState extends State<CollectionScreen> {
  final CardRepository _cardRepository = CardRepository();
  final CollectionRepository _collectionRepository = CollectionRepository();
  final TextEditingController _searchController = TextEditingController();
  
  List<String> _selectedColors = [];
  String _selectedRarity = '';
  String _searchQuery = '';
  bool _ownedOnly = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('📚 Collection'),
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
        foregroundColor: Theme.of(context).colorScheme.onPrimaryContainer,
        actions: [
          IconButton(
            onPressed: _showFiltersDialog,
            icon: const Icon(Icons.filter_list),
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert),
            onSelected: (value) {
              switch (value) {
                case 'export':
                  _showComingSoonSnackBar('Export');
                  break;
                case 'import':
                  _showComingSoonSnackBar('Import');
                  break;
                case 'bulk_edit':
                  _showComingSoonSnackBar('Bulk Edit');
                  break;
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'export', child: Text('Export Collection')),
              const PopupMenuItem(value: 'import', child: Text('Import Cards')),
              const PopupMenuItem(value: 'bulk_edit', child: Text('Bulk Edit')),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          _buildKPIHeader(),
          _buildSearchBar(),
          _buildFilterChips(),
          Expanded(child: _buildCollectionList()),
        ],
      ),
    );
  }

  Widget _buildKPIHeader() {
    final totalCards = _collectionRepository.getTotalCards();
    final uniqueCards = _collectionRepository.getUniqueCards();
    final foilCount = _collectionRepository.getFoilCount();
    final estimatedValue = _collectionRepository.getEstimatedValue();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainer,
      ),
      child: Row(
        children: [
          Expanded(child: _buildKPICard('Total Cards', totalCards.toString(), Icons.collections)),
          const SizedBox(width: 12),
          Expanded(child: _buildKPICard('Unique', uniqueCards.toString(), Icons.auto_awesome)),
          const SizedBox(width: 12),
          Expanded(child: _buildKPICard('Foils', foilCount.toString(), Icons.star_outline)),
          const SizedBox(width: 12),
          Expanded(child: _buildKPICard('Value', '\$${estimatedValue.toStringAsFixed(0)}', Icons.monetization_on_outlined)),
        ],
      ),
    );
  }

  Widget _buildKPICard(String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        children: [
          Icon(icon, size: 20, color: Theme.of(context).colorScheme.primary),
          const SizedBox(height: 4),
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
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: SearchBar(
        controller: _searchController,
        hintText: 'Search your collection...',
        leading: const Icon(Icons.search),
        onChanged: (value) => setState(() => _searchQuery = value),
        trailing: _searchQuery.isNotEmpty
          ? [
              IconButton(
                onPressed: () {
                  _searchController.clear();
                  setState(() => _searchQuery = '');
                },
                icon: const Icon(Icons.clear),
              ),
            ]
          : null,
      ),
    );
  }

  Widget _buildFilterChips() {
    final activeFilters = <Widget>[];
    
    if (_selectedColors.isNotEmpty) {
      activeFilters.add(
        FilterChip(
          label: Text('Colors: ${_selectedColors.join(', ')}'),
          onSelected: (value) => _showFiltersDialog(),
          selected: true,
        ),
      );
    }
    
    if (_selectedRarity.isNotEmpty) {
      activeFilters.add(
        FilterChip(
          label: Text('Rarity: $_selectedRarity'),
          onSelected: (value) => _showFiltersDialog(),
          selected: true,
        ),
      );
    }
    
    if (_ownedOnly) {
      activeFilters.add(
        FilterChip(
          label: const Text('Owned Only'),
          onSelected: (value) => setState(() => _ownedOnly = !_ownedOnly),
          selected: true,
        ),
      );
    }
    
    if (activeFilters.isEmpty) return const SizedBox.shrink();
    
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Wrap(
        spacing: 8,
        children: [
          ...activeFilters,
          ActionChip(
            label: const Text('Clear Filters'),
            onPressed: () => setState(() {
              _selectedColors.clear();
              _selectedRarity = '';
              _ownedOnly = false;
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildCollectionList() {
    final ownedCardIds = _collectionRepository.getOwnedCardIds();
    final allCards = _ownedOnly 
      ? _cardRepository.allCards.where((card) => ownedCardIds.contains(card.id)).toList()
      : _cardRepository.allCards;
    
    var filteredCards = allCards.where((card) {
      // Search filter
      if (_searchQuery.isNotEmpty) {
        if (!card.name.toLowerCase().contains(_searchQuery.toLowerCase()) &&
            !card.oracleText.toLowerCase().contains(_searchQuery.toLowerCase())) {
          return false;
        }
      }
      
      // Color filter
      if (_selectedColors.isNotEmpty) {
        if (!_selectedColors.every((color) => card.colorIdentity.contains(color))) {
          return false;
        }
      }
      
      // Rarity filter
      if (_selectedRarity.isNotEmpty && card.rarity != _selectedRarity) {
        return false;
      }
      
      return true;
    }).toList();

    if (filteredCards.isEmpty) {
      return _buildEmptyState();
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: filteredCards.length,
      separatorBuilder: (context, index) => const SizedBox(height: 8),
      itemBuilder: (context, index) => _buildCardTile(filteredCards[index]),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            _ownedOnly ? Icons.inventory_2_outlined : Icons.search_off,
            size: 64,
            color: Theme.of(context).colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
          ),
          const SizedBox(height: 16),
          Text(
            _ownedOnly ? 'No cards yet — try Scan or Import' : 'No cards found',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          if (_ownedOnly) ...[
            const SizedBox(height: 8),
            OutlinedButton.icon(
              onPressed: () {
                // Switch to scan tab (would need navigation context)
                setState(() => _ownedOnly = false);
              },
              icon: const Icon(Icons.camera_alt),
              label: const Text('Start Scanning'),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildCardTile(MTGCard card) {
    final collectionEntry = _collectionRepository.getEntry(card.id);
    final isOwned = collectionEntry != null;
    
    return Card(
      margin: EdgeInsets.zero,
      child: InkWell(
        onTap: () => _showCardDetail(card),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // Card Image
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  card.imageUrl,
                  width: 60,
                  height: 60,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    width: 60,
                    height: 60,
                    color: Theme.of(context).colorScheme.surfaceContainer,
                    child: const Icon(Icons.image_not_supported),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              
              // Card Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            card.name,
                            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        ManaCostRow(manaCost: card.manaCost, size: 16),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      card.typeLine,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Text(
                          '${card.set} #${card.collectorNumber}',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(width: 8),
                        CardBadges(card: card),
                        const Spacer(),
                        PricePill(usd: card.price.usd),
                      ],
                    ),
                  ],
                ),
              ),
              
              // Collection Controls
              const SizedBox(width: 8),
              if (isOwned) ...[
                Column(
                  children: [
                    Text(
                      '${collectionEntry!.totalCount}',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                    CountStepper(
                      value: collectionEntry.count,
                      onChanged: (newCount) => _updateCardCount(card.id, newCount, collectionEntry.foilCount),
                    ),
                  ],
                ),
              ] else ...[
                IconButton(
                  onPressed: () => _addCard(card.id),
                  icon: const Icon(Icons.add_circle_outline),
                  style: IconButton.styleFrom(
                    foregroundColor: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  void _updateCardCount(String cardId, int newCount, int foilCount) {
    final currentEntry = _collectionRepository.getEntry(cardId);
    if (currentEntry == null) return;
    
    if (newCount == 0 && foilCount == 0) {
      _collectionRepository.removeCard(cardId, count: currentEntry.count);
    } else {
      final countDiff = newCount - currentEntry.count;
      if (countDiff > 0) {
        _collectionRepository.addCard(cardId, count: countDiff);
      } else if (countDiff < 0) {
        _collectionRepository.removeCard(cardId, count: -countDiff);
      }
    }
    setState(() {});
  }

  void _addCard(String cardId) {
    _collectionRepository.addCard(cardId);
    setState(() {});
    
    final card = _cardRepository.getCardById(cardId);
    if (mounted && card != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Added ${card.name} to collection')),
      );
    }
  }

  void _showCardDetail(MTGCard card) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => CardDetailScreen(card: card),
      ),
    );
  }

  void _showFiltersDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => _FiltersBottomSheet(
        selectedColors: _selectedColors,
        selectedRarity: _selectedRarity,
        ownedOnly: _ownedOnly,
        onApply: (colors, rarity, ownedOnly) {
          setState(() {
            _selectedColors = colors;
            _selectedRarity = rarity;
            _ownedOnly = ownedOnly;
          });
        },
      ),
    );
  }

  void _showComingSoonSnackBar(String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$feature feature coming soon!')),
    );
  }
}

class _FiltersBottomSheet extends StatefulWidget {
  final List<String> selectedColors;
  final String selectedRarity;
  final bool ownedOnly;
  final Function(List<String>, String, bool) onApply;

  const _FiltersBottomSheet({
    required this.selectedColors,
    required this.selectedRarity,
    required this.ownedOnly,
    required this.onApply,
  });

  @override
  State<_FiltersBottomSheet> createState() => _FiltersBottomSheetState();
}

class _FiltersBottomSheetState extends State<_FiltersBottomSheet> {
  late List<String> _selectedColors;
  late String _selectedRarity;
  late bool _ownedOnly;

  final List<String> _colors = ['W', 'U', 'B', 'R', 'G'];
  final List<String> _rarities = ['Common', 'Uncommon', 'Rare', 'Mythic'];

  @override
  void initState() {
    super.initState();
    _selectedColors = List.from(widget.selectedColors);
    _selectedRarity = widget.selectedRarity;
    _ownedOnly = widget.ownedOnly;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Filter Collection',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              TextButton(
                onPressed: () {
                  setState(() {
                    _selectedColors.clear();
                    _selectedRarity = '';
                    _ownedOnly = false;
                  });
                },
                child: const Text('Clear All'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          Text(
            'Color Identity',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: _colors.map((color) => FilterChip(
              label: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ManaPipIcon(color, size: 16),
                  const SizedBox(width: 4),
                  Text(color),
                ],
              ),
              selected: _selectedColors.contains(color),
              onSelected: (selected) {
                setState(() {
                  if (selected) {
                    _selectedColors.add(color);
                  } else {
                    _selectedColors.remove(color);
                  }
                });
              },
            )).toList(),
          ),
          
          const SizedBox(height: 16),
          Text(
            'Rarity',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: _rarities.map((rarity) => ChoiceChip(
              label: Text(rarity),
              selected: _selectedRarity == rarity,
              onSelected: (selected) {
                setState(() => _selectedRarity = selected ? rarity : '');
              },
            )).toList(),
          ),
          
          const SizedBox(height: 16),
          SwitchListTile(
            title: const Text('Show owned cards only'),
            value: _ownedOnly,
            onChanged: (value) => setState(() => _ownedOnly = value),
          ),
          
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: () {
                widget.onApply(_selectedColors, _selectedRarity, _ownedOnly);
                Navigator.of(context).pop();
              },
              child: const Text('Apply Filters'),
            ),
          ),
          SizedBox(height: MediaQuery.of(context).padding.bottom),
        ],
      ),
    );
  }
}