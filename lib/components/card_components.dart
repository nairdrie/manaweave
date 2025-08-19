import 'package:flutter/material.dart';
import 'package:manaweave/models/card.dart';
import 'package:manaweave/components/mana_cost_display.dart';

class PricePill extends StatelessWidget {
  final double? usd;
  final bool foil;

  const PricePill({super.key, this.usd, this.foil = false});

  @override
  Widget build(BuildContext context) {
    if (usd == null) return const SizedBox.shrink();
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: foil 
          ? Theme.of(context).colorScheme.tertiary.withValues(alpha: 0.2)
          : Theme.of(context).colorScheme.secondary.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        '\$${usd!.toStringAsFixed(2)}${foil ? ' (F)' : ''}',
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
          color: foil 
            ? Theme.of(context).colorScheme.tertiary
            : Theme.of(context).colorScheme.secondary,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}

class ValidationChip extends StatelessWidget {
  final String text;
  final ValidationSeverity severity;
  final VoidCallback? onTap;

  const ValidationChip({
    super.key,
    required this.text,
    required this.severity,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: _getBackgroundColor(context),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: _getBorderColor(context)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              _getIcon(),
              size: 14,
              color: _getTextColor(context),
            ),
            const SizedBox(width: 4),
            Text(
              text,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: _getTextColor(context),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getBackgroundColor(BuildContext context) {
    switch (severity) {
      case ValidationSeverity.error:
        return Theme.of(context).colorScheme.errorContainer;
      case ValidationSeverity.warning:
        return Theme.of(context).colorScheme.tertiary.withValues(alpha: 0.2);
      case ValidationSeverity.info:
        return Theme.of(context).colorScheme.secondary.withValues(alpha: 0.2);
    }
  }

  Color _getBorderColor(BuildContext context) {
    switch (severity) {
      case ValidationSeverity.error:
        return Theme.of(context).colorScheme.error.withValues(alpha: 0.5);
      case ValidationSeverity.warning:
        return Theme.of(context).colorScheme.tertiary.withValues(alpha: 0.5);
      case ValidationSeverity.info:
        return Theme.of(context).colorScheme.secondary.withValues(alpha: 0.5);
    }
  }

  Color _getTextColor(BuildContext context) {
    switch (severity) {
      case ValidationSeverity.error:
        return Theme.of(context).colorScheme.onErrorContainer;
      case ValidationSeverity.warning:
        return Theme.of(context).colorScheme.tertiary;
      case ValidationSeverity.info:
        return Theme.of(context).colorScheme.secondary;
    }
  }

  IconData _getIcon() {
    switch (severity) {
      case ValidationSeverity.error:
        return Icons.error_outline;
      case ValidationSeverity.warning:
        return Icons.warning_amber_outlined;
      case ValidationSeverity.info:
        return Icons.info_outline;
    }
  }
}

enum ValidationSeverity { error, warning, info }

class CountStepper extends StatelessWidget {
  final int value;
  final ValueChanged<int> onChanged;
  final int min;
  final int max;

  const CountStepper({
    super.key,
    required this.value,
    required this.onChanged,
    this.min = 0,
    this.max = 999,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildButton(
          context,
          icon: Icons.remove,
          onPressed: value > min ? () => onChanged(value - 1) : null,
        ),
        Container(
          constraints: const BoxConstraints(minWidth: 40),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Text(
            value.toString(),
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ),
        _buildButton(
          context,
          icon: Icons.add,
          onPressed: value < max ? () => onChanged(value + 1) : null,
        ),
      ],
    );
  }

  Widget _buildButton(BuildContext context, {required IconData icon, VoidCallback? onPressed}) {
    return SizedBox(
      width: 36,
      height: 36,
      child: IconButton(
        onPressed: onPressed,
        icon: Icon(icon, size: 18),
        style: IconButton.styleFrom(
          backgroundColor: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
          foregroundColor: Theme.of(context).colorScheme.primary,
          shape: const CircleBorder(),
        ),
      ),
    );
  }
}

class CommanderTile extends StatelessWidget {
  final MTGCard commander;
  final VoidCallback? onTap;

  const CommanderTile({super.key, required this.commander, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  commander.imageUrl,
                  width: 48,
                  height: 48,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    width: 48,
                    height: 48,
                    color: Theme.of(context).colorScheme.surfaceContainer,
                    child: Icon(
                      Icons.image_not_supported,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
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
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        ManaCostRow(manaCost: commander.manaCost, size: 16),
                        const SizedBox(width: 8),
                        ColorIdentityPips(colors: commander.colorIdentity),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class TagChips extends StatelessWidget {
  final List<String> tags;
  final int? maxVisible;

  const TagChips({super.key, required this.tags, this.maxVisible});

  @override
  Widget build(BuildContext context) {
    if (tags.isEmpty) return const SizedBox.shrink();
    
    final visibleTags = maxVisible != null && tags.length > maxVisible!
        ? tags.take(maxVisible!).toList()
        : tags;
    
    return Wrap(
      spacing: 4,
      runSpacing: 4,
      children: [
        ...visibleTags.map((tag) => Chip(
          label: Text(tag),
          labelStyle: Theme.of(context).textTheme.bodySmall,
          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          visualDensity: VisualDensity.compact,
        )),
        if (maxVisible != null && tags.length > maxVisible!)
          Chip(
            label: Text('+${tags.length - maxVisible!} more'),
            labelStyle: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.secondary,
            ),
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            visualDensity: VisualDensity.compact,
          ),
      ],
    );
  }
}

class CardBadges extends StatelessWidget {
  final MTGCard card;

  const CardBadges({super.key, required this.card});

  @override
  Widget build(BuildContext context) {
    final badges = <Widget>[];
    
    if (card.isLegendary) {
      badges.add(_buildBadge(context, 'Legendary', Colors.amber));
    }
    
    if (card.isBanned) {
      badges.add(_buildBadge(context, 'Banned', Theme.of(context).colorScheme.error));
    }
    
    if (badges.isEmpty) return const SizedBox.shrink();
    
    return Wrap(
      spacing: 4,
      children: badges,
    );
  }

  Widget _buildBadge(BuildContext context, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color.withValues(alpha: 0.5)),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
          color: color,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}