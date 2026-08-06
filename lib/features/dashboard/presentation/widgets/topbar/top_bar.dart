import 'package:flutter/material.dart';

class TopBar extends StatelessWidget {
  final String sectionTitle;

  const TopBar({
    super.key,
    this.sectionTitle = "Dashboard",
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 90,
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                "Добро пожаловать 👋",
                style: TextStyle(
                  color: Colors.white54,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                sectionTitle,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 34,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),

          const Spacer(),

          SizedBox(
            width: 320,
            child: TextField(
              decoration: InputDecoration(
                hintText: "Поиск...",
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: const Color(0xff1D232C),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),

          const SizedBox(width: 20),

          IconButton(
            onPressed: () {},
            icon: const Icon(
              Icons.notifications_none_rounded,
              color: Colors.white,
            ),
          ),

          const SizedBox(width: 12),

          const CircleAvatar(
            radius: 22,
            child: Icon(Icons.person),
          ),
        ],
      ),
    );
  }
}
