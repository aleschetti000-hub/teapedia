import 'package:flutter/material.dart';

class StarRow extends StatelessWidget {
  final double rating;
  final double iconSize;

  const StarRow({super.key, required this.rating, this.iconSize = 15});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (i) {
        final IconData icon;
        if (rating >= i + 1.0) {
          icon = Icons.star_rounded;
        } else if (rating >= i + 0.5) {
          icon = Icons.star_half_rounded;
        } else {
          icon = Icons.star_outline_rounded;
        }
        return Icon(
          icon,
          size: iconSize,
          color: rating >= i + 0.5 ? const Color(0xFFBA7517) : Colors.black26,
        );
      }),
    );
  }
}
