import 'package:flutter/material.dart';
import 'package:manaweave/models/card.dart';
import 'package:manaweave/repositories/card_repository.dart';
import 'package:manaweave/repositories/collection_repository.dart';
import 'package:manaweave/components/card_components.dart';

class ScanScreen extends StatefulWidget {
  const ScanScreen({super.key});

  @override
  State<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends State<ScanScreen> {
  final List<ScanResult> _scannedCards = [];
  final CardRepository _cardRepository = CardRepository();
  final CollectionRepository _collectionRepository = CollectionRepository();
  bool _isScanning = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('📸 Scan Cards'),
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
        foregroundColor: Theme.of(context).colorScheme.onPrimaryContainer,
      ),
      body: Column(
        children: [
          // Camera Preview Area
          Expanded(
            flex: 2,
            child: Container(
              width: double.infinity,
              margin: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainer,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.3),
                ),
              ),
              child: _scannedCards.isEmpty ? _buildEmptyState() : _buildCameraPreview(),
            ),
          ),
          
          // Action Buttons
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Expanded(
                  child: FilledButton.icon(
                    onPressed: _isScanning ? null : _simulateScan,
                    icon: _isScanning 
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.camera_alt),
                    label: Text(_isScanning ? 'Scanning...' : 'Capture Card'),
                  ),
                ),
                const SizedBox(width: 12),
                OutlinedButton(
                  onPressed: _scannedCards.isEmpty ? null : _clearTray,
                  child: const Text('Clear'),
                ),
              ],
            ),
          ),
          
          // Scanned Tray
          Expanded(
            flex: 3,
            child: _buildScannedTray(),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.camera_alt_outlined,
            size: 64,
            color: Theme.of(context).colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
          ),
          const SizedBox(height: 16),
          Text(
            'Point your camera at a card to start',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'Tap "Capture Card" to simulate scanning',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant.withValues(alpha: 0.8),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildCameraPreview() {
    return Stack(
      children: [
        // Mock camera preview
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                Theme.of(context).colorScheme.secondary.withValues(alpha: 0.1),
              ],
            ),
          ),
          child: Center(
            child: Icon(
              Icons.videocam,
              size: 48,
              color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.5),
            ),
          ),
        ),
        
        // Overlay guides
        Positioned.fill(
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.5),
                width: 2,
              ),
            ),
            child: Center(
              child: Container(
                width: 200,
                height: 140,
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Theme.of(context).colorScheme.primary,
                    width: 2,
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildScannedTray() {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHigh,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: Column(
        children: [
          // Tray Header
          Container(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(
                  Icons.inbox,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  'Scanned Tray (${_scannedCards.length})',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                if (_scannedCards.isNotEmpty) ...[
                  TextButton.icon(
                    onPressed: _addAllToCollection,
                    icon: const Icon(Icons.add_circle_outline),
                    label: const Text('Add All'),
                  ),
                ],
              ],
            ),
          ),
          
          // Scanned Cards List
          Expanded(
            child: _scannedCards.isEmpty
              ? Center(
                  child: Text(
                    'Scanned cards will appear here',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                )
              : ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: _scannedCards.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 8),
                  itemBuilder: (context, index) => _buildScannedCardTile(_scannedCards[index], index),
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildScannedCardTile(ScanResult result, int index) {
    if (result.candidates.isEmpty) return const SizedBox.shrink();
    
    final candidate = result.candidates.first;
    final card = _cardRepository.getCardById(candidate.cardId);
    if (card == null) return const SizedBox.shrink();
    
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            // Card Image
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: Image.network(
                card.imageUrl,
                width: 40,
                height: 40,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  width: 40,
                  height: 40,
                  color: Theme.of(context).colorScheme.surfaceContainer,
                  child: const Icon(Icons.image_not_supported, size: 20),
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
                      _buildConfidenceChip(candidate.confidence),
                    ],
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
                      if (candidate.confidence < 0.8)
                        Icon(
                          Icons.warning_amber,
                          size: 16,
                          color: Theme.of(context).colorScheme.tertiary,
                        ),
                    ],
                  ),
                ],
              ),
            ),
            
            // Quantity and Actions
            CountStepper(
              value: result.count,
              onChanged: (newCount) => _updateScanResultCount(index, newCount),
            ),
            const SizedBox(width: 8),
            IconButton(
              onPressed: () => _removeScanResult(index),
              icon: const Icon(Icons.close),
              iconSize: 20,
              style: IconButton.styleFrom(
                foregroundColor: Theme.of(context).colorScheme.error,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildConfidenceChip(double confidence) {
    final color = confidence >= 0.9 
      ? Colors.green 
      : confidence >= 0.7 
        ? Colors.orange 
        : Colors.red;
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        '${(confidence * 100).toInt()}%',
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  void _simulateScan() async {
    setState(() => _isScanning = true);
    
    // Simulate scanning delay
    await Future.delayed(const Duration(milliseconds: 1500));
    
    // Mock scan result with random card
    final allCards = _cardRepository.allCards;
    final randomCard = allCards[DateTime.now().millisecondsSinceEpoch % allCards.length];
    final confidence = 0.7 + (DateTime.now().millisecondsSinceEpoch % 30) / 100;
    
    final scanResult = ScanResult(
      imagePath: '/mock/path/${randomCard.id}.jpg',
      candidates: [ScanCandidate(cardId: randomCard.id, confidence: confidence)],
      count: 1,
    );
    
    setState(() {
      _scannedCards.add(scanResult);
      _isScanning = false;
    });
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Detected: ${randomCard.name}'),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  void _updateScanResultCount(int index, int newCount) {
    if (newCount <= 0) {
      _removeScanResult(index);
      return;
    }
    
    setState(() {
      final result = _scannedCards[index];
      _scannedCards[index] = ScanResult(
        imagePath: result.imagePath,
        candidates: result.candidates,
        count: newCount,
      );
    });
  }

  void _removeScanResult(int index) {
    setState(() => _scannedCards.removeAt(index));
  }

  void _clearTray() {
    setState(() => _scannedCards.clear());
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Tray cleared')),
    );
  }

  void _addAllToCollection() {
    _collectionRepository.addCardsFromScan(_scannedCards);
    final totalCards = _scannedCards.fold(0, (sum, result) => sum + result.count);
    
    setState(() => _scannedCards.clear());
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Added $totalCards cards to collection'),
          action: SnackBarAction(
            label: 'View',
            onPressed: () {
              // Navigate to collection tab
            },
          ),
        ),
      );
    }
  }
}