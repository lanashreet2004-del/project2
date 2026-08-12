import 'package:flutter/material.dart';

/// Sun illustration for the welcome card.
class SunIllustration extends StatelessWidget {
  const SunIllustration({super.key, this.size = 80});

  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          ...List.generate(8, (index) {
            return Transform.rotate(
              angle: index * 3.14159 / 4,
              child: Container(
                width: 6,
                height: size * 0.35,
                margin: EdgeInsets.only(bottom: size * 0.55),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFC107),
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
            );
          }),
          Container(
            width: size * 0.55,
            height: size * 0.55,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Color(0xFFFFD54F),
            ),
          ),
        ],
      ),
    );
  }
}
