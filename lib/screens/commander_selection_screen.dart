import 'package:flutter/material.dart';
import 'package:manaweave/models/card.dart';
import 'package:manaweave/repositories/card_repository.dart';
import 'package:manaweave/components/mana_cost_display.dart';
import 'package:manaweave/components/card_components.dart';

class CommanderSelectionScreen extends StatefulWidget {
  final Function(String commanderId, String? strategy) onCommanderSelected;

  const CommanderSelectionScreen({
    super.key,
    required this.onCommanderSelected,
  });

  @override
  State<CommanderSelectionScreen> createState() => _CommanderSelectionScreenState();
}

class _CommanderSelectionScreenState extends State<CommanderSelectionScreen> {
  final CardRepository _cardRepository = CardRepository();
  final TextEditingController _searchController = TextEditingController();
  
  List<String> _selectedColors = [];
  String _searchQuery = '';
  String? _selectedStrategy;

  final List<String> _strategies = [
    'Balanced',
    'Blink',
    'Tokens',
    'Control',
    'Voltron',
    'Spellslinger',
    'Ramp',
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Choose Your Commander'),
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
        foregroundColor: Theme.of(context).colorScheme.onPrimaryContainer,
      ),
      body: Column(
        children: [
          _buildStrategySelection(),
          _buildSearchAndFilters(),
          Expanded(child: _buildCommanderList()),
        ],
      ),
    );
  }

  Widget _buildStrategySelection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainer,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '🎯 Choose a Strategy (Optional)',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Select a strategy to get autofill suggestions later',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 4,
            children: _strategies.map((strategy) => ChoiceChip(
              label: Text(strategy),
              selected: _selectedStrategy == strategy,
              onSelected: (selected) {
                setState(() => _selectedStrategy = selected ? strategy : null);
              },
            )).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchAndFilters() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          SearchBar(
            controller: _searchController,
            hintText: 'Search commanders...',
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
          const SizedBox(height: 12),
          _buildColorFilter(),
        ],
      ),
    );
  }

  Widget _buildColorFilter() {
    final colors = ['W', 'U', 'B', 'R', 'G'];
    
    return Row(
      children: [
        Text(
          'Colors:',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Wrap(
            spacing: 8,
            children: colors.map((color) => FilterChip(
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
        ),
        if (_selectedColors.isNotEmpty)
          TextButton(
            onPressed: () => setState(() => _selectedColors.clear()),
            child: const Text('Clear'),
          ),
      ],
    );
  }

  Widget _buildCommanderList() {
    var commanders = _cardRepository.getCommanderCards();
    
    // Apply filters
    commanders = commanders.where((commander) {
      // Search filter
      if (_searchQuery.isNotEmpty) {
        if (!commander.name.toLowerCase().contains(_searchQuery.toLowerCase()) &&
            !commander.oracleText.toLowerCase().contains(_searchQuery.toLowerCase())) {
          return false;
        }
      }
      
      // Color filter
      if (_selectedColors.isNotEmpty) {
        if (!_selectedColors.every((color) => commander.colorIdentity.contains(color))) {
          return false;
        }
      }
      
      return true;
    }).toList();

    if (commanders.isEmpty) {
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
              'No commanders found',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Try adjusting your filters',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant.withValues(alpha: 0.8),
              ),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: commanders.length,
      separatorBuilder: (context, index) => const SizedBox(height: 8),
      itemBuilder: (context, index) => _buildCommanderCard(commanders[index]),
    );
  }

  Widget _buildCommanderCard(MTGCard commander) {
    return Card(
      margin: EdgeInsets.zero,
      child: InkWell(
        onTap: () => _selectCommander(commander),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // Commander Image
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  commander.imageUrl,
                  width: 60,
                  height: 60,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    width: 60,
                    height: 60,
                    color: Theme.of(context).colorScheme.surfaceContainer,
                    child: const Icon(Icons.person),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              
              // Commander Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      commander.name,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        ManaCostRow(manaCost: commander.manaCost, size: 16),
                        const Spacer(),
                        ColorIdentityPips(colors: commander.colorIdentity),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      commander.typeLine,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                    if (commander.tags.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      TagChips(tags: commander.tags, maxVisible: 3),
                    ],
                  ],
                ),
              ),
              
              // Selection Icon
              Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _selectCommander(MTGCard commander) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Confirm Commander'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CommanderTile(commander: commander),
            if (_selectedStrategy != null) ...[
              const SizedBox(height: 16),
              Text(
                'Strategy: $_selectedStrategy',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
            const SizedBox(height: 8),
            Text(
              'This will create a new deck with ${commander.name} as your commander.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.of(context).pop();
              widget.onCommanderSelected(commander.id, _selectedStrategy);
            },
            child: const Text('Create Deck'),
          ),
        ],
      ),
    );
  }
}