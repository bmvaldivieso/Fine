import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

class CustomBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const CustomBottomNavBar({
    Key? key,
    required this.currentIndex,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final safeIndex = currentIndex > 3 ? 0 : currentIndex;

    return BottomNavigationBar(
      selectedItemColor: const Color(0xFFFF5177),
      unselectedItemColor: Colors.black,
      currentIndex: safeIndex,
      onTap: onTap,
      items: const [
        BottomNavigationBarItem(icon: Icon(Iconsax.home), label: ''),
        BottomNavigationBarItem(icon: Icon(Icons.school), label: ''),
        BottomNavigationBarItem(icon: Icon(Iconsax.message), label: ''),
        BottomNavigationBarItem(icon: Icon(Iconsax.clock), label: ''),
      ],
    );
  }
}

