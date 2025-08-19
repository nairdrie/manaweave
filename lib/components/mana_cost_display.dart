import 'package:flutter/material.dart';
import 'package:manaweave/theme.dart';

class ManaCostRow extends StatelessWidget {
  final String manaCost;
  final double size;

  const ManaCostRow({super.key, required this.manaCost, this.size = 20.0});

  @override
  Widget build(BuildContext context) {
    if (manaCost.isEmpty) return const SizedBox.shrink();
    
    final symbols = _parseManaCost(manaCost);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: symbols.map((symbol) => Padding(
        padding: const EdgeInsets.only(right: 2.0),
        child: ManaPipIcon(symbol, size: size),
      )).toList(),
    );
  }

  List<String> _parseManaCost(String cost) {
    final symbols = <String>[];
    final regex = RegExp(r'\{([^}]+)\}');
    final matches = regex.allMatches(cost);
    
    for (final match in matches) {
      symbols.add(match.group(1) ?? '');
    }
    
    return symbols;
  }
}

class ManaPipIcon extends StatelessWidget {
  final String symbol;
  final double size;

  const ManaPipIcon(this.symbol, {super.key, this.size = 20.0});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: _getManaColor(symbol, isDark),
        shape: BoxShape.circle,
        border: Border.all(
          color: isDark ? Colors.white24 : Colors.black26,
          width: 1,
        ),
      ),
      child: Center(
        child: Text(
          _getSymbolText(symbol),
          style: TextStyle(
            fontSize: size * 0.6,
            fontWeight: FontWeight.bold,
            color: _getTextColor(symbol),
          ),
        ),
      ),
    );
  }

  Color _getManaColor(String symbol, bool isDark) {
    switch (symbol.toUpperCase()) {
      case 'W': return LightModeColors.manaWhite;
      case 'U': return LightModeColors.manaBlue;
      case 'B': return LightModeColors.manaBlack;
      case 'R': return LightModeColors.manaRed;
      case 'G': return LightModeColors.manaGreen;
      case 'C': return LightModeColors.manaColorless;
      default: return LightModeColors.manaColorless; // Generic mana
    }
  }

  Color _getTextColor(String symbol) {
    switch (symbol.toUpperCase()) {
      case 'W': return Colors.black;
      case 'U': return Colors.white;
      case 'B': return Colors.white;
      case 'R': return Colors.white;
      case 'G': return Colors.white;
      default: return Colors.white;
    }
  }

  String _getSymbolText(String symbol) {
    if (RegExp(r'^\d+$').hasMatch(symbol)) {
      return symbol; // Generic mana cost
    }
    return symbol.toUpperCase();
  }
}

class ColorIdentityPips extends StatelessWidget {
  final List<String> colors;
  final double size;

  const ColorIdentityPips({super.key, required this.colors, this.size = 16.0});

  @override
  Widget build(BuildContext context) {
    if (colors.isEmpty) return const SizedBox.shrink();
    
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: colors.map((color) => Padding(
        padding: const EdgeInsets.only(right: 2.0),
        child: ManaPipIcon(color, size: size),
      )).toList(),
    );
  }
}