import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import '../widgets/drawer_item.dart';
import 'package:get/get.dart';
import '../features/home/controllers/home_Controller.dart';



class CustomDrawer extends StatefulWidget {
  const CustomDrawer({super.key});

  @override
  State<CustomDrawer> createState() => _CustomDrawerState();
}

class _CustomDrawerState extends State<CustomDrawer> {
  String _selectedItem = "";

  void _onItemTap(String label, VoidCallback? callback) {
    setState(() {
      _selectedItem = label;
    });
    if (callback != null) callback();
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double screenHeight = MediaQuery.of(context).size.height;
    final HomeController _homeController = Get.find<HomeController>();


    return Drawer(
      child: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(
            vertical: screenHeight * 0.02,
            horizontal: screenWidth * 0.04,
          ),
          child: Column(
            children: [
              // Scroll area
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      buildDrawerItem(
                        Iconsax.teacher,
                        "Course",
                        screenWidth,
                        isActive: _selectedItem == "Course",
                        onTap: () => _onItemTap("Course", null),
                      ),
                       buildDrawerItem(
                        Iconsax.document,
                        "Matricula",
                        screenWidth,
                        isActive: _selectedItem == "Matricula",
                        onTap: () => _onItemTap("Matricula", () {
                          Navigator.pop(context);
                          _homeController.gotoHomeWithIndex(5, transitionType: 'offAll');
                        }),
                      ),
                      buildDrawerItem(
                        Iconsax.book,
                        "Homework",
                        screenWidth,
                        isActive: _selectedItem == "Homework",
                        onTap: () => _onItemTap("Homework", null),
                      ),
                      buildDrawerItem(
                        Iconsax.book_1,
                        "Lesson",
                        screenWidth,
                        isActive: _selectedItem == "Lesson",
                        onTap: () => _onItemTap("Lesson", null),
                      ),
                      buildDrawerItem(
                        Iconsax.document_text,
                        "Vocabulary",
                        screenWidth,
                        isActive: _selectedItem == "Vocabulary",
                        onTap: () => _onItemTap("Vocabulary", null),
                      ),
                      buildDrawerItem(
                        Iconsax.volume_high,
                        "Listen",
                        screenWidth,
                        isActive: _selectedItem == "Listen",
                        onTap: () => _onItemTap("Listen", null),
                      ),
                      buildDrawerItem(
                        Iconsax.microphone,
                        "Speak",
                        screenWidth,
                        isActive: _selectedItem == "Speak",
                        onTap: () => _onItemTap("Speak", null),
                      ),
                      buildDrawerItem(
                        Iconsax.star,
                        "Game",
                        screenWidth,
                        isActive: _selectedItem == "Game",
                        onTap: () => _onItemTap("Game", null),
                      ),
                      buildDrawerItem(
                        Iconsax.video,
                        "Zoom",
                        screenWidth,
                        isActive: _selectedItem == "Zoom",
                        onTap: () => _onItemTap("Zoom", null),
                      ),
                      buildDrawerItem(
                        Iconsax.calendar,
                        "Calendar",
                        screenWidth,
                        isActive: _selectedItem == "Calendar",
                        onTap: () => _onItemTap("Calendar", null),
                      ),
                      buildDrawerItem(
                        Iconsax.document,
                        "Notes",
                        screenWidth,
                        isActive: _selectedItem == "Notes",
                        onTap: () => _onItemTap("Notes", () {
                          Navigator.pop(context);
                          _homeController.gotoHomeWithIndex(4, transitionType: 'offAll');
                        }),
                      ),
                    ],
                  ),
                ),
              ),
              // Botón de cerrar fuera del scroll
              Align(
                alignment: Alignment.centerRight,
                child: IconButton(
                  icon: Icon(Iconsax.close_circle, size: screenWidth * 0.065),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
