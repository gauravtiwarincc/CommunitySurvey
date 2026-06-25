import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

enum SwiggyTabMode {
  surveys,
  discover,
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

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      height: 90,
      child: Row(
        children: [
          _buildTab(
            context,
            mode: SwiggyTabMode.surveys,
            label: 'Surveys',
            icon: Icons.assignment_turned_in, // Food proxy
            backgroundColor: const Color(0xFF1F4D36), // Dark green background like Swiggy Food
            activeColor: const Color(0xFF16A34A), // Vibrant green
          ),
          const SizedBox(width: 8),
          _buildTab(
            context,
            mode: SwiggyTabMode.discover,
            label: 'Discover',
            icon: Icons.bolt, // Instamart proxy
            backgroundColor: const Color(0xFF1E2B47), // Dark blue background
            activeColor: const Color(0xFF2563EB), // Vibrant blue
          ),
          const SizedBox(width: 8),
          _buildTab(
            context,
            mode: SwiggyTabMode.rewards,
            label: 'Rewards',
            icon: Icons.monetization_on, // Dineout proxy
            backgroundColor: const Color(0xFF2A2A2A), // Dark grey
            activeColor: const Color(0xFFD4AF37), // Gold
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
    required Color backgroundColor,
    required Color activeColor,
  }) {
    final isSelected = selectedMode == mode;

    return Expanded(
      child: GestureDetector(
        onTap: () => onTabChanged(mode),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          decoration: BoxDecoration(
            color: isSelected ? activeColor : backgroundColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isSelected ? Colors.white.withOpacity(0.2) : Colors.transparent,
              width: 1,
            ),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: activeColor.withOpacity(0.4),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    )
                  ]
                : [],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedScale(
                scale: isSelected ? 1.1 : 1.0,
                duration: const Duration(milliseconds: 300),
                child: Icon(
                  icon,
                  size: 32,
                  color: isSelected ? Colors.white : Colors.white70,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                label,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                  color: isSelected ? Colors.white : Colors.white70,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
