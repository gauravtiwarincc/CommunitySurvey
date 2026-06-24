import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:community_survey/services/admin_service.dart';
import 'package:community_survey/core/theme/theme_controller.dart';
import 'package:community_survey/models/admin_models.dart';
import 'package:community_survey/core/theme/premium_theme.dart';
import 'package:community_survey/core/widgets/glass_card.dart';
import 'package:google_fonts/google_fonts.dart';

class AdminThemeCustomizationPage extends ConsumerStatefulWidget {
  const AdminThemeCustomizationPage({super.key});

  @override
  ConsumerState<AdminThemeCustomizationPage> createState() => _AdminThemeCustomizationPageState();
}

class _AdminThemeCustomizationPageState extends ConsumerState<AdminThemeCustomizationPage> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _welcomeController = TextEditingController();
  final _emailController = TextEditingController();
  final _logoController = TextEditingController();

  final _primaryController = TextEditingController();
  final _secondaryController = TextEditingController();
  final _accentController = TextEditingController();

  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadCurrentTheme();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _welcomeController.dispose();
    _emailController.dispose();
    _logoController.dispose();
    _primaryController.dispose();
    _secondaryController.dispose();
    _accentController.dispose();
    super.dispose();
  }

  void _loadCurrentTheme() {
    final currentConfig = ref.read(themeProvider).config;
    if (currentConfig != null) {
      _nameController.text = currentConfig.organizationName;
      _welcomeController.text = currentConfig.welcomeMessage ?? '';
      _emailController.text = currentConfig.supportEmail ?? '';
      _logoController.text = currentConfig.logoUrl ?? '';
      _primaryController.text = currentConfig.primaryColor;
      _secondaryController.text = currentConfig.secondaryColor;
      _accentController.text = currentConfig.accentColor;
    } else {
      _primaryController.text = '#2C0977';
      _secondaryController.text = '#E6005E';
      _accentController.text = '#00B300';
    }
  }

  void _saveTheme() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final updatedConfig = await ref.read(adminServiceProvider).updateTheme(
        organizationName: _nameController.text.trim(),
        primaryColor: _primaryController.text.trim(),
        secondaryColor: _secondaryController.text.trim(),
        accentColor: _accentController.text.trim(),
        welcomeMessage: _welcomeController.text.trim(),
        supportEmail: _emailController.text.trim(),
        logoUrl: _logoController.text.trim(),
      );

      // Apply branding changes instantly
      ref.read(themeProvider.notifier).updateBranding(updatedConfig);

      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Success'),
            content: const Text('Branding and theme saved successfully! All users in your organization will see the updated configuration.'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(); // pop dialog
                  Navigator.of(context).pop(); // pop customization page
                },
                child: const Text('OK'),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      setState(() {
        _errorMessage = e.toString().replaceAll('Exception: ', '');
      });
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Color _parseColor(String hexString, Color fallback) {
    if (hexString.isEmpty) return fallback;
    try {
      final buffer = StringBuffer();
      if (hexString.length == 6 || hexString.length == 7) buffer.write('ff');
      buffer.write(hexString.replaceFirst('#', ''));
      return Color(int.parse(buffer.toString(), radix: 16));
    } catch (_) {
      return fallback;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Watch dynamic states for preview
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text('Theme & Customization', style: GoogleFonts.plusJakartaSans( fontWeight: FontWeight.bold)),
      ),
      body: PremiumMeshBackground(
        child: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(20.0, kToolbarHeight + 20, 20.0, 20.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildLivePreviewCard(theme),
                const SizedBox(height: 24),
                if (_errorMessage != null) ...[
                  Text(
                    _errorMessage!,
                    style: const TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                ],
                Text(
                  'Organization Branding',
                  style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                _buildWhiteTextField(
                  controller: _nameController,
                  label: 'Organization Name',
                  icon: Icons.business,
                  validator: (val) => val == null || val.isEmpty ? 'Please enter organization name' : null,
                ),
                const SizedBox(height: 16),
                _buildWhiteTextField(
                  controller: _welcomeController,
                  label: 'Welcome Message',
                  icon: Icons.waving_hand,
                ),
                const SizedBox(height: 16),
                _buildWhiteTextField(
                  controller: _emailController,
                  label: 'Support Email Address',
                  icon: Icons.email,
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 16),
                _buildWhiteTextField(
                  controller: _logoController,
                  label: 'Logo URL (HTTPS)',
                  icon: Icons.link,
                  keyboardType: TextInputType.url,
                ),
                const Divider(height: 32),
                Text(
                  'Color Configurations (HEX)',
                  style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                _buildColorField(
                  controller: _primaryController,
                  label: 'Primary Base Color',
                  fallback: const Color(0xFF2C0977),
                ),
                const SizedBox(height: 16),
                _buildColorField(
                  controller: _secondaryController,
                  label: 'Secondary Accentuations',
                  fallback: const Color(0xFFE6005E),
                ),
                const SizedBox(height: 16),
                _buildColorField(
                  controller: _accentController,
                  label: 'Success Indicator Color',
                  fallback: const Color(0xFF00B300),
                ),
                const SizedBox(height: 32),
                ElevatedButton(
                  onPressed: _isLoading ? null : _saveTheme,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(color: Colors.black, strokeWidth: 2),
                        )
                      : const Text('Save & Apply Branding', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildWhiteTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      style: const TextStyle(color: Colors.white),
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white60),
        prefixIcon: Icon(icon),
        enabledBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Colors.white24),
          borderRadius: BorderRadius.circular(16),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Colors.white),
          borderRadius: BorderRadius.circular(16),
        ),
        errorBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Colors.redAccent),
          borderRadius: BorderRadius.circular(16),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Colors.redAccent),
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      validator: validator,
      onChanged: (_) => setState(() {}),
    );
  }

  Widget _buildLivePreviewCard(ThemeData theme) {
    final name = _nameController.text.isEmpty ? 'Supper Market' : _nameController.text;
    final welcome = _welcomeController.text.isEmpty ? 'Welcome to Supper Market\'s Group' : _welcomeController.text;
    
    final primaryColor = _parseColor(_primaryController.text, const Color(0xFF2C0977));
    final secondaryColor = _parseColor(_secondaryController.text, const Color(0xFFE6005E));

    return GlassCard(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          const Text(
            'LIVE PREVIEW',
            style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1),
          ),
          const SizedBox(height: 12),
          Container(
            decoration: BoxDecoration(
              
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: primaryColor.withOpacity(0.5)),
              boxShadow: [
                BoxShadow(
                  color: primaryColor.withOpacity(0.15),
                  blurRadius: 16,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  if (_logoController.text.isNotEmpty)
                    Image.network(_logoController.text, height: 40, errorBuilder: (_, __, ___) => Icon(Icons.business, color: primaryColor, size: 40))
                  else
                    Icon(Icons.business, color: primaryColor, size: 40),
                  const SizedBox(height: 10),
                  Text(
                    name,
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: primaryColor),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    welcome,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 12),
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: secondaryColor,
                      foregroundColor: secondaryColor.contrastTextColor,
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text('Verify Code', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildColorField({
    required TextEditingController controller,
    required String label,
    required Color fallback,
  }) {
    final parsedColor = _parseColor(controller.text, fallback);

    return InkWell(
      onTap: () {
        Color tempColor = parsedColor;
        showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: const Text('Pick a color'),
              content: SingleChildScrollView(
                child: ColorPicker(
                  pickerColor: tempColor,
                  onColorChanged: (color) {
                    tempColor = color;
                  },
                  colorPickerWidth: 300.0,
                  pickerAreaHeightPercent: 0.7,
                  enableAlpha: false,
                  displayThumbColor: true,
                  paletteType: PaletteType.hsv,
                  pickerAreaBorderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(2.0),
                    topRight: Radius.circular(2.0),
                  ),
                ),
              ),
              actions: [
                TextButton(
                  child: const Text('Done'),
                  onPressed: () {
                    setState(() {
                      controller.text = '#${tempColor.value.toRadixString(16).substring(2).toUpperCase()}';
                    });
                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          },
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white24),
        ),
        child: Row(
          children: [
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: parsedColor,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white70),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                label,
                style: const TextStyle(color: Colors.white, fontSize: 16),
              ),
            ),
            Text(
              controller.text.toUpperCase(),
              style: const TextStyle(color: Colors.white60),
            ),
            const SizedBox(width: 8),
            const Icon(Icons.colorize, color: Colors.white60, size: 20),
          ],
        ),
      ),
    );
  }
}
