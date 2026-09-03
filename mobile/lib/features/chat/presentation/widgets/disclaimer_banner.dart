import 'package:flutter/material.dart';

class DisclaimerBanner extends StatelessWidget {
  const DisclaimerBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 10.0),
      decoration: BoxDecoration(
        color: const Color(0xFFE5F2EC), // Soft sage green tint matching design
        borderRadius: BorderRadius.circular(20),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.only(top: 2.0, right: 10.0),
            child: Icon(
              Icons.info_outline_rounded,
              size: 17,
              color: Color(0xFF435852),
            ),
          ),
          Expanded(
            child: Text(
              'AI provides general health information and does not replace professional medical advice.',
              style: TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w500,
                height: 1.35,
                color: Color(0xFF435852),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
