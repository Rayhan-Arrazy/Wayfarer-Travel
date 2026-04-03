import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class WayfarerAppBar extends StatelessWidget implements PreferredSizeWidget {
  final bool showMenu;
  final bool showProfile;
  final VoidCallback? onBack;
  final List<Widget>? extraActions;

  WayfarerAppBar({
    super.key,
    this.showMenu = true,
    this.showProfile = true,
    this.onBack,
    this.extraActions,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.white,
      elevation: 0,
      centerTitle: true,
      leading: showMenu
          ? IconButton(
              onPressed: () => Scaffold.of(context).openDrawer(),
              icon: const Icon(Icons.menu, color: Color(0xFF132F5C)),
            )
          : IconButton(
              onPressed: onBack ?? () => Navigator.pop(context),
              icon: const Icon(Icons.arrow_back, color: Color(0xFF132F5C)),
            ),
      title: Text(
        'Wayfarer',
        style: GoogleFonts.outfit(
          fontSize: 22,
          fontWeight: FontWeight.w800,
          color: const Color(0xFF132F5C),
          letterSpacing: -0.5,
        ),
      ),
      actions: [
        if (extraActions != null) ...extraActions!,
        if (showProfile)
          const Padding(
            padding: EdgeInsets.only(right: 16),
            child: CircleAvatar(
              radius: 18,
              backgroundColor: Color(0xFFF1F5F9),
              child: Icon(Icons.person, color: Color(0xFF132F5C), size: 20),
            ),
          ),
        if (!showProfile && extraActions == null)
          const SizedBox(width: 48), // Spacer to balance leading
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
