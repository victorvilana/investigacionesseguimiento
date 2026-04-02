import 'package:flutter/material.dart';

class ActionCard extends StatelessWidget {
  final String title;
  final String desc;
  final IconData icon;
  final bool isPrimary;
  final String buttonText;

  const ActionCard({
    super.key,
    required this.title,
    required this.desc,
    required this.icon,
    this.isPrimary = false,
    required this.buttonText,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 20,
            offset: const Offset(0, 10),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isPrimary ? const Color(0xFF1046C4) : const Color(0xFFE8EAF6),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: isPrimary ? Colors.white : const Color(0xFF1046C4), size: 24),
          ),
          const SizedBox(height: 20),
          Text(title, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF1A1A1A))),
          const SizedBox(height: 8),
          Text(desc, style: const TextStyle(color: Colors.black54, fontSize: 14, height: 1.4)),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: isPrimary ? const Color(0xFF1046C4) : const Color(0xFFF1F3F9),
              foregroundColor: isPrimary ? Colors.white : const Color(0xFF1046C4),
              elevation: 0,
              minimumSize: const Size(double.infinity, 54),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            ),
            child: Text(buttonText, style: const TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}