import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

enum SwiggyTabMode {
  discover,
  surveys,
  rewards,
}

class SwiggyTabBar extends StatelessWidget {
  final SwiggyTabMode selectedMode;
  final ValueChanged<SwiggyTabMode> onTabChanged;

  const SwiggyTabBar({
    super.key,
    required this.selectedMode,
    required this.onTabChanged,
  });

  Color _getInactiveBackgroundColor(SwiggyTabMode mode) {
    switch (mode) {
      case SwiggyTabMode.surveys:
        return Colors.black.withOpacity(0.5);
      case SwiggyTabMode.discover:
        return Colors.black.withOpacity(0.55);
      case SwiggyTabMode.rewards:
        return Colors.black.withOpacity(0.6);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Premium Black & Gold Palette
    final activeColors = {
      SwiggyTabMode.surveys: Colors.black.withOpacity(0.5), // Translucent to reveal background
      SwiggyTabMode.discover: Colors.black.withOpacity(0.55),
      SwiggyTabMode.rewards: Colors.black.withOpacity(0.6),
    };

    final activeColor = activeColors[selectedMode]!;
    final goldColor = const Color(0xFFD4AF37);

    return Container(
      height: 90,
      margin: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          _buildTab(
            context,
            mode: SwiggyTabMode.surveys,
            label: 'Surveys',
            icon: Icons.assignment_turned_in,
            isActive: selectedMode == SwiggyTabMode.surveys,
            activeBackgroundColor: activeColor,
            inactiveBackgroundColor: Colors.black.withOpacity(0.5),
            textColor: selectedMode == SwiggyTabMode.surveys ? goldColor : Colors.white54,
          ),
          _buildTab(
            context,
            mode: SwiggyTabMode.discover,
            label: 'Discover',
            icon: Icons.explore,
            isActive: selectedMode == SwiggyTabMode.discover,
            activeBackgroundColor: activeColor,
            inactiveBackgroundColor: Colors.black.withOpacity(0.4),
            textColor: selectedMode == SwiggyTabMode.discover ? goldColor : Colors.white54,
          ),
          _buildTab(
            context,
            mode: SwiggyTabMode.rewards,
            label: 'Rewards',
            icon: Icons.workspace_premium,
            isActive: selectedMode == SwiggyTabMode.rewards,
            activeBackgroundColor: activeColor,
            inactiveBackgroundColor: Colors.black.withOpacity(0.3),
            textColor: selectedMode == SwiggyTabMode.rewards ? goldColor : Colors.white54,
          ),
        ],
      ),
    );
  }

  Widget _buildTab(
    BuildContext context, {
    required SwiggyTabMode mode,
    required String label,
    required IconData icon,
    required bool isActive,
    required Color activeBackgroundColor,
    required Color inactiveBackgroundColor,
    required Color textColor,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: () => onTabChanged(mode),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          height: isActive ? 90 : 75,
          decoration: BoxDecoration(
            color: isActive ? activeBackgroundColor : inactiveBackgroundColor,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(24),
              topRight: Radius.circular(24),
            ),
            boxShadow: isActive
                ? [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, -2),
                    )
                  ]
                : [],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedScale(
                scale: isActive ? 1.1 : 0.9,
                duration: const Duration(milliseconds: 200),
                child: Icon(
                  icon,
                  size: 32,
                  color: textColor,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 13,
                  fontWeight: isActive ? FontWeight.bold : FontWeight.w600,
                  color: textColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
