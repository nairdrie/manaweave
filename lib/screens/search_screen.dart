import 'package:flutter/material.dart';
import 'package:manaweave/models/card.dart';
import 'package:manaweave/repositories/card_repository.dart';
import 'package:manaweave/repositories/collection_repository.dart';
import 'package:manaweave/components/mana_cost_display.dart';
import 'package:manaweave/components/card_components.dart';
import 'package:manaweave/screens/card_detail_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final CardRepository _cardRepository = CardRepository();
  final CollectionRepository _collectionRepository = CollectionRepository();
  final TextEditingController _searchController = TextEditingController();
  
  List<MTGCard> _searchResults = [];
  String _searchQuery = '';
  bool _isSearching = false;
  ViewMode _viewMode = ViewMode.list;

  @override
  void initState() {
    super.initState();
    // Show all cards initially
    _searchResults = _cardRepository.allCards;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('🔍 Search Cards'),
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
        foregroundColor: Theme.of(context).colorScheme.onPrimaryContainer,
        actions: [
          IconButton(
            onPressed: () => setState(() {
              _viewMode = _viewMode == ViewMode.list ? ViewMode.grid : ViewMode.list;
            }),
            icon: Icon(_viewMode == ViewMode.list ? Icons.grid_view : Icons.view_list),
          ),
        ],
      ),
      body: Column(
        children: [
          _buildSearchBar(),
          _buildResultsHeader(),
          Expanded(child: _buildSearchResults()),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: SearchBar(
        controller: _searchController,
        hintText: 'Search all Magic cards...',
        leading: const Icon(Icons.search),
        onChanged: _performSearch,
        trailing: [
          if (_searchQuery.isNotEmpty)
            IconButton(
              onPressed: () {
                _searchController.clear();
                _performSearch('');
              },
              icon: const Icon(Icons.clear),
            ),
          if (_isSearching)
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildResultsHeader() {
    if (_searchResults.isEmpty) return const SizedBox.shrink();
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainer,
        border: Border(
          bottom: BorderSide(
            color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
          ),
        ),
      ),
      child: Row(
        children: [
          Text(
            '${_searchResults.length} cards found',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          const Spacer(),
          SegmentedButton<ViewMode>(
            segments: const [
              ButtonSegment(
                value: ViewMode.list,
                icon: Icon(Icons.view_list, size: 18),
              ),
              ButtonSegment(
                value: ViewMode.grid,
                icon: Icon(Icons.grid_view, size: 18),
              ),
            ],
            selected: {_viewMode},
            onSelectionChanged: (selection) {
              setState(() => _viewMode = selection.first);
            },
            style: SegmentedButton.styleFrom(
              visualDensity: VisualDensity.compact,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchResults() {
    if (_searchResults.isEmpty) {
      return _buildEmptyState();
    }
    
    return _viewMode == ViewMode.list 
      ? _buildListView() 
      : _buildGridView();
  }

  Widget _buildEmptyState() {
    if (_searchQuery.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search,
              size: 64,
              color: Theme.of(context).colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
            ),
            const SizedBox(height: 16),
            Text(
              'Search the multiverse',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Find any Magic: The Gathering card',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant.withValues(alpha: 0.8),
              ),
            ),
          ],
        ),
      );
    }
    
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off,
            size: 64,
            color: Theme.of(context).colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
          ),
          const SizedBox(height: 16),
          Text(
            'No cards found',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Try a different search term',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant.withValues(alpha: 0.8),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildListView() {
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: _searchResults.length,
      separatorBuilder: (context, index) => const SizedBox(height: 8),
      itemBuilder: (context, index) => _buildListCard(_searchResults[index]),
    );
  }

  Widget _buildGridView() {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.7,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
      ),
      itemCount: _searchResults.length,
      itemBuilder: (context, index) => _buildGridCard(_searchResults[index]),
    );
  }

  Widget _buildListCard(MTGCard card) {
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
                  width: 50,
                  height: 50,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    width: 50,
                    height: 50,
                    color: Theme.of(context).colorScheme.surfaceContainer,
                    child: const Icon(Icons.image_not_supported, size: 24),
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
                        ManaCostRow(manaCost: card.manaCost, size: 14),
                      ],
                    ),
                    const SizedBox(height: 2),
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
                          card.set,
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
              
              // Collection Status and Actions
              const SizedBox(width: 8),
              Column(
                children: [
                  if (isOwned) ...[
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '${collectionEntry!.totalCount}',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                  ],
                  PopupMenuButton<String>(
                    icon: const Icon(Icons.more_vert, size: 20),
                    onSelected: (value) => _handleCardAction(card, value),
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'add_collection',
                        child: Row(
                          children: [
                            Icon(Icons.add_circle_outline),
                            SizedBox(width: 8),
                            Text('Add to Collection'),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'add_deck',
                        child: Row(
                          children: [
                            Icon(Icons.style_outlined),
                            SizedBox(width: 8),
                            Text('Add to Deck'),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'view_details',
                        child: Row(
                          children: [
                            Icon(Icons.info_outline),
                            SizedBox(width: 8),
                            Text('View Details'),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGridCard(MTGCard card) {
    final collectionEntry = _collectionRepository.getEntry(card.id);
    final isOwned = collectionEntry != null;
    
    return Card(
      margin: EdgeInsets.zero,
      child: InkWell(
        onTap: () => _showCardDetail(card),
        borderRadius: BorderRadius.circular(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Card Image
            Expanded(
              flex: 3,
              child: Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
                ),
                child: ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      Image.network(
                        card.imageUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Container(
                          color: Theme.of(context).colorScheme.surfaceContainer,
                          child: const Icon(Icons.image_not_supported, size: 32),
                        ),
                      ),
                      if (isOwned)
                        Positioned(
                          top: 8,
                          right: 8,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.primary,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              '${collectionEntry!.totalCount}',
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: Theme.of(context).colorScheme.onPrimary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
            
            // Card Info
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      card.name,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            card.set,
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Theme.of(context).colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ),
                        ManaCostRow(manaCost: card.manaCost, size: 12),
                      ],
                    ),
                    const Spacer(),
                    Row(
                      children: [
                        Expanded(child: PricePill(usd: card.price.usd)),
                        IconButton(
                          onPressed: () => _addToCollection(card),
                          icon: const Icon(Icons.add, size: 16),
                          style: IconButton.styleFrom(
                            foregroundColor: Theme.of(context).colorScheme.primary,
                            minimumSize: const Size(24, 24),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _performSearch(String query) {
    setState(() {
      _searchQuery = query;
      _isSearching = true;
    });
    
    // Simulate search delay
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        final results = query.isEmpty 
          ? _cardRepository.allCards
          : _cardRepository.searchCards(query);
        
        setState(() {
          _searchResults = results;
          _isSearching = false;
        });
      }
    });
  }

  void _showCardDetail(MTGCard card) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => CardDetailScreen(card: card),
      ),
    );
  }

  void _addToCollection(MTGCard card) {
    _collectionRepository.addCard(card.id);
    setState(() {});
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Added ${card.name} to collection')),
    );
  }

  void _handleCardAction(MTGCard card, String action) {
    switch (action) {
      case 'add_collection':
        _addToCollection(card);
        break;
      case 'add_deck':
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Add to Deck feature coming soon!')),
        );
        break;
      case 'view_details':
        _showCardDetail(card);
        break;
    }
  }
}

enum ViewMode { list, grid }