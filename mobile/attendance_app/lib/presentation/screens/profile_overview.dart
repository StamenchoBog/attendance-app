import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter/cupertino.dart';
import 'package:attendance_app/core/theme/color_palette.dart';
import 'package:provider/provider.dart';
import 'package:attendance_app/data/providers/user_provider.dart';
import 'package:attendance_app/data/models/professor.dart';
import 'package:attendance_app/data/models/student.dart';

// Screens
import 'package:attendance_app/presentation/screens/sign_in_screen.dart';

// Widgets
import 'package:attendance_app/presentation/widgets/static/bottom_nav_bar.dart';
import 'package:attendance_app/presentation/widgets/static/helpers/navigation_helpers.dart';
import 'package:logger/logger.dart';

class ProfileOverviewScreen extends StatefulWidget {
  const ProfileOverviewScreen({super.key});

  @override
  State<ProfileOverviewScreen> createState() => _ProfileOverviewScreenState();
}

class _ProfileOverviewScreenState extends State<ProfileOverviewScreen> {
  int _selectedIndex = 3;
  final Logger _logger = Logger();

  // --- Methods ---
  // Bottom Navigation tap
  void _onItemTapped(int index) {
    if (_selectedIndex != index) {
      setState(() {
        _selectedIndex = index;
      });
      handleBottomNavigation(context, index);
    }
  }

  void _logOut() {
    showDialog(
      context: context,
      barrierDismissible: false, // User must tap button to dismiss
      builder: (BuildContext dialogContext) { // Use dialogContext to avoid shadow issues
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.r), // Rounded corners like mockup
          ),
          title: Text(
            "Log out",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 17.sp,
              color: ColorPalette.textPrimary,
            ),
          ),
          content: Text(
            "Are you sure you want to log out? You'll need to login again to use the app.",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14.sp,
              color: ColorPalette.textSecondary,
              height: 1.4, // Line height
            ),
          ),
          actionsAlignment: MainAxisAlignment.center, // Center buttons horizontally
          actionsPadding: EdgeInsets.only(left: 15.w, right: 15.w, bottom: 15.h, top: 5.h),
          actions: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.center, // Center buttons in the row
              children: [
                // Cancel Button
                Expanded( // Make buttons share space
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: ColorPalette.darkBlue, // Text color
                      side: BorderSide(color: ColorPalette.darkBlue, width: 1.5.w), // Border color/width
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.r), // Button rounding
                      ),
                       padding: EdgeInsets.symmetric(vertical: 12.h), // Button padding
                    ),
                    child: Text(
                        "Cancel",
                        style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.w600),
                      ),
                    onPressed: () {
                      // Just close the dialog
                      Navigator.of(dialogContext).pop();
                    },
                  ),
                ),
                SizedBox(width: 10.w), // Space between buttons

                // Log out Button (Actual)
                Expanded( // Make buttons share space
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: ColorPalette.darkBlue, // Background color
                      foregroundColor: Colors.white, // Text color
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.r), // Button rounding
                      ),
                      padding: EdgeInsets.symmetric(vertical: 12.h), // Button padding
                      elevation: 1, // Subtle elevation
                    ),
                    child: Text(
                      "Log out",
                      style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.w600),
                      ),
                    onPressed: () {
                      // 1. Close the dialog FIRST
                      Navigator.of(dialogContext).pop();

                      Provider.of<UserProvider>(context, listen: false).logout();

                      // 2. PERFORM ACTUAL LOG OUT ACTIONS
                      _logger.i("Performing actual log out...");
                      // --- IMPORTANT ---
                      // TODO: Implement actual log out logic:
                      // 1. Clear any stored user session/token (e.g., from SharedPreferences).
                      // 2. Reset any app state related to the user.
                      // 3. Navigate to the SignInScreen and remove all previous screens.
                      // --- Example Navigation ---
                      if (mounted) {
                        Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(
                          MaterialPageRoute(builder: (context) => const SignInScreen()),
                          (Route<dynamic> route) => false,
                        );
                      }
                      // --- End Log Out Logic ---
                    },
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      // Use a standard AppBar for this screen
      appBar: AppBar(
        title: Text(
          "Profile",
          style: TextStyle(
            color: ColorPalette.textPrimary,
            fontWeight: FontWeight.w600, // Semi-bold
            fontSize: 18.sp,
          ),
        ),
        centerTitle: true, // Center title like mockup
        backgroundColor: Colors.white,
        elevation: 0, // Flat app bar
        automaticallyImplyLeading: false, // No back button if it's a main tab
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20.w),
        child: Column(
          children: [
            SizedBox(height: 20.h),

            // --- Profile Picture Placeholder ---
            CircleAvatar(
              radius: 55.r, // Larger radius
              backgroundColor: ColorPalette.lightestBlue, // Use light blue background
              child: Icon(
                CupertinoIcons.person_fill, // User icon
                size: 60.sp,
                color: ColorPalette.darkBlue.withValues(alpha: 0.8), // Slightly transparent blue icon
              ),
            ),

            SizedBox(height: 15.h),

            // --- Name ---
            Consumer<UserProvider>(
              builder: (context, userProvider, child) {
                final user = userProvider.currentUser;
                return Column(
                  children: [
                    Text(
                      user != null 
                          ? user.name
                          : 'Not logged in',
                      style: TextStyle(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.bold,
                        color: ColorPalette.textPrimary,
                      ),
                    ),
                    
                    SizedBox(height: 5.h),
                    
                    // --- Index Number or Title based on role ---
                    Text(
                      user != null 
                          ? (user is Student 
                              ? (user).studentIndex
                              : (user is Professor 
                                  ? (user).title
                                  : 'User'))
                          : '',
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: ColorPalette.textSecondary,
                      ),
                    ),
                  ],
                );
              },
            ),

            SizedBox(height: 35.h),

            // --- Settings List ---
            // Using Column + ListTile for fixed items
            Column(
              children: [
                _buildSettingsItem(
                  'Languages',
                  onTap: () => navigateToSetting(context, 'languages'),
                ),
                _buildSettingsItem(
                  'Devices',
                  onTap: () => navigateToSetting(context, 'devices'),
                ),
                _buildSettingsItem(
                  'Report a problem',
                  onTap: () => navigateToSetting(context, 'report_a_problem'),
                  showDivider: false,
                ),
              ],
            ),

            const Spacer(), // Pushes Log out button to the bottom

            // --- Log out Button ---
            Padding(
              // Add padding to prevent button touching edges/bottom nav
              padding: EdgeInsets.only(bottom: 20.h, top: 15.h),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: ColorPalette.darkBlue,
                  foregroundColor: Colors.white,
                  minimumSize: Size(double.infinity, 50.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  textStyle: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                onPressed: _logOut,
                child: Text("Log out"),
              ),
            ),
          ],
        ),
      ),

       // --- Bottom Navigation Bar ---
      bottomNavigationBar: CustomBottomNavBar(
        selectedIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }

  // Helper widget for settings list items
  Widget _buildSettingsItem(String title, {required VoidCallback onTap, bool showDivider = true}) {
    return InkWell( // Use InkWell for tap feedback
      onTap: onTap,
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.symmetric(vertical: 12.h), // Adjust vertical padding
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: 15.sp,
                      color: ColorPalette.textPrimary,
                    ),
                  ),
                ),
                Icon(
                  CupertinoIcons.chevron_forward,
                  size: 20.sp,
                  color: ColorPalette.iconGrey.withValues(alpha: 0.8),
                ),
              ],
            ),
          ),
          if (showDivider)
            Divider(height: 1.h, thickness: 1.h, color: Colors.grey[200]), // Subtle divider
        ],
      ),
    );
  }

}
