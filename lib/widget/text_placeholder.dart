import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class TextPlaceholder extends StatelessWidget {
  const TextPlaceholder({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          // mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(
              radius: 30,
              backgroundColor:
                  Colors.grey[200], // Placeholder color for the profile image
            ),
            const SizedBox(
              width: 20,
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 150,
                  height: 20,
                  color: Colors.grey[200],
                ),
                const SizedBox(height: 8),
                Container(
                  width: 250,
                  height: 15,
                  color: Colors.grey[200],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
