import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:attendance_app/core/theme/color_palette.dart';

class CustomBottomNavBar extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onTap;

  const CustomBottomNavBar({
    super.key,
    required this.selectedIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      showSelectedLabels: false,
      showUnselectedLabels: false,
      elevation: 0.0, // Flat look
      backgroundColor: Colors.white, // Bar background
      type: BottomNavigationBarType.fixed, // Ensure items are evenly spaced
      selectedItemColor: ColorPalette.darkBlue, // Selected icon color
      unselectedItemColor: ColorPalette.iconGrey, // Unselected icon color
      currentIndex: selectedIndex,
      onTap: onTap,
      items: <BottomNavigationBarItem>[
        BottomNavigationBarItem(
          icon: Icon(selectedIndex == 0 ? CupertinoIcons.house_fill : CupertinoIcons.house),
          label: '',
        ),
        BottomNavigationBarItem(
          icon: Icon(selectedIndex == 1 ? CupertinoIcons.calendar_today : CupertinoIcons.calendar),
          label: '',
        ),
        BottomNavigationBarItem(
          icon: Icon(selectedIndex == 2 ? CupertinoIcons.qrcode_viewfinder : CupertinoIcons.qrcode),
          label: '',
        ),
        BottomNavigationBarItem(
          icon: Icon(selectedIndex == 3 ? CupertinoIcons.person_fill : CupertinoIcons.person),
          label: '',
        ),
      ],
    );
  }
}