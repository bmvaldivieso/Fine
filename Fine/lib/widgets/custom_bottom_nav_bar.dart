import 'package:flutter/material.dart';

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

    return Container(
      height: 100, // Altura más delgada
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [], // Quitamos sombra
      ),
      child: BottomNavigationBar(
        backgroundColor: Colors.white,
        elevation: 0, // Sin sombra ni elevación
        selectedItemColor: const Color(0xFFFF5177),
        unselectedItemColor: Colors.black,
        currentIndex: safeIndex,
        onTap: onTap,
        showSelectedLabels: false,
        showUnselectedLabels: false,
        type: BottomNavigationBarType.fixed,
        iconSize: 36,
        items: const [
          BottomNavigationBarItem(
            icon: ImageIcon(
              AssetImage('lib/assets/icons/ho.png'),
              size: 40,
            ),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: ImageIcon(
              AssetImage('lib/assets/icons/cur.png'),
              size: 40,
            ),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: ImageIcon(
              AssetImage('lib/assets/icons/me.png'),
              size: 40,
            ),
            label: '',
          ),
        BottomNavigationBarItem(
          icon: Center(
            child: ImageIcon(
              AssetImage('lib/assets/icons/re.png'),
              size: 40,
            ),
          ),
          label: '',
        ),
        ],
      ),
    );
  }
}
