import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class WebFooter extends StatelessWidget {
  const WebFooter({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 24),
      decoration: BoxDecoration(
        color: const Color(0xFF111111),
        border: Border(
          top: BorderSide(
            color: Colors.white.withOpacity(0.05),
          ),
        ),
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: Column(
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 2,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.how_to_vote, color: theme.colorScheme.primary, size: 24),
                            const SizedBox(width: 8),
                            Text(
                              'Community Survey',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Empowering organizations to gather insights, verify opinions, and engage their communities with beautifully designed surveys.',
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            color: Colors.white60,
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 48),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Platform',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 16),
                        _buildFooterLink('Dashboard'),
                        _buildFooterLink('Surveys'),
                        _buildFooterLink('Rewards'),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Support',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 16),
                        _buildFooterLink('Help Center'),
                        _buildFooterLink('Privacy Policy'),
                        _buildFooterLink('Terms of Service'),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 48),
              Divider(color: Colors.white.withOpacity(0.1)),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '© ${DateTime.now().year} Community Survey. All rights reserved.',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: Colors.white54,
                    ),
                  ),
                  Row(
                    children: [
                      Icon(Icons.language, size: 18, color: Colors.white54),
                      const SizedBox(width: 8),
                      Text(
                        'English (US)',
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          color: Colors.white54,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFooterLink(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Text(
        text,
        style: GoogleFonts.inter(
          fontSize: 14,
          color: Colors.white60,
        ),
      ),
    );
  }
}
