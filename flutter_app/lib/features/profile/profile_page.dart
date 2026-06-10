import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:community_survey/features/auth/auth_provider.dart';
import 'package:community_survey/models/user.dart';
import 'package:community_survey/services/auth_service.dart';
import 'package:community_survey/core/theme/premium_theme.dart';
import 'package:community_survey/core/widgets/glass_card.dart';
import 'package:community_survey/core/widgets/glowing_button.dart';
import 'package:google_fonts/google_fonts.dart';

class ProfilePage extends ConsumerWidget {
  const ProfilePage({super.key});

  void _showEditProfileSheet(BuildContext context, User user) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => EditProfileSheet(user: user),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final user = authState.profile;
    final theme = Theme.of(context);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(
          'Profile',
          style: GoogleFonts.plusJakartaSans(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        actions: [
          if (user != null)
            IconButton(
              icon: const Icon(Icons.edit, color: Colors.white),
              tooltip: 'Edit Profile',
              onPressed: () => _showEditProfileSheet(context, user),
            ),
        ],
      ),
      body: PremiumMeshBackground(
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (user != null) ...[
                  // Hero avatar card
                  GlassCard(
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: theme.colorScheme.primary.withOpacity(0.3), width: 2),
                          ),
                          child: CircleAvatar(
                            radius: 36,
                            backgroundColor: theme.colorScheme.primary.withOpacity(0.1),
                            child: Icon(Icons.person, size: 42, color: theme.colorScheme.primary),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          user.fullName,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primary.withOpacity(0.08),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: theme.colorScheme.primary.withOpacity(0.15)),
                          ),
                          child: Text(
                            'ROLE: ${user.role.name.toUpperCase()}',
                            style: GoogleFonts.plusJakartaSans(
                              color: theme.colorScheme.primary,
                              fontWeight: FontWeight.bold,
                              fontSize: 10,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Details list card
                  GlassCard(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    child: Column(
                      children: [
                        _buildDetailRow('Mobile', user.mobile ?? '-'),
                        _buildDivider(),
                        _buildDetailRow('Aadhaar', user.aadhaar ?? '-'),
                        _buildDivider(),
                        _buildDetailRow("Father's Name", user.fathersName ?? '-'),
                        _buildDivider(),
                        _buildDetailRow('Gender', user.gender ?? '-'),
                        _buildDivider(),
                        _buildDetailRow('State', user.state ?? '-'),
                        _buildDivider(),
                        _buildDetailRow('District', user.district ?? '-'),
                        _buildDivider(),
                        _buildDetailRow('City/Village', user.city ?? '-'),
                        _buildDivider(),
                        _buildDetailRow('Address', user.address ?? '-'),
                        _buildDivider(),
                        _buildDetailRow('Pincode', user.pincode ?? '-'),
                        _buildDivider(),
                        _buildDetailRow('Education', user.education ?? '-'),
                        _buildDivider(),
                        _buildDetailRow('Occupation', user.occupation ?? '-'),
                        _buildDivider(),
                        _buildDetailRow('Social Category', user.socialCategory ?? '-'),
                        if (user.organization != null) ...[
                          _buildDivider(),
                          _buildDetailRow('Organization', user.organization!.organizationName),
                        ],
                      ],
                    ),
                  ),
                ] else
                  const Center(child: Text('User profile not loaded.', style: TextStyle(color: Colors.white38))),
                const SizedBox(height: 24),
                
                // Logout Button
                GlowingButton(
                  onPressed: () {
                    ref.read(authProvider.notifier).logout();
                  },
                  glowColor: Colors.red.shade900,
                  gradient: LinearGradient(
                    colors: [Colors.red.shade900, Colors.red.shade800],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  child: const Text('Log Out'),
                ),
                const SizedBox(height: 100), // Bottom bar margin
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: GoogleFonts.inter(color: Colors.white38, fontSize: 13),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: GoogleFonts.inter(
                fontWeight: FontWeight.bold,
                fontSize: 13,
                color: Colors.white.withOpacity(0.9),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Divider(
      height: 1,
      color: Colors.white.withOpacity(0.04),
    );
  }
}

class EditProfileSheet extends StatefulWidget {
  final User user;
  const EditProfileSheet({super.key, required this.user});

  @override
  State<EditProfileSheet> createState() => _EditProfileSheetState();
}

class _EditProfileSheetState extends State<EditProfileSheet> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _fullNameController;
  late TextEditingController _addressController;
  late TextEditingController _cityController;
  late TextEditingController _pincodeController;
  late TextEditingController _stateController;
  late TextEditingController _districtController;
  
  String? _gender;
  String? _education;
  String? _occupation;
  String? _socialCategory;
  
  bool _isSaving = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    final u = widget.user;
    _fullNameController = TextEditingController(text: u.fullName);
    _addressController = TextEditingController(text: u.address ?? '');
    _cityController = TextEditingController(text: u.city ?? '');
    _pincodeController = TextEditingController(text: u.pincode ?? '');
    _stateController = TextEditingController(text: u.state ?? '');
    _districtController = TextEditingController(text: u.district ?? '');
    
    final genders = ['Male', 'Female', 'Other'];
    _gender = genders.contains(u.gender) ? u.gender : genders.first;
    
    final educations = ['Under Matric', 'Matric', 'Intermediate', 'Graduate', 'Post Graduate'];
    _education = educations.contains(u.education) ? u.education : educations.first;
    
    final occupations = ['Farmer', 'Salaried', 'Self Employed', 'Student', 'Unemployed'];
    _occupation = occupations.contains(u.occupation) ? u.occupation : occupations.first;
    
    final socialCategories = ['General', 'OBC', 'SC', 'ST'];
    _socialCategory = socialCategories.contains(u.socialCategory) ? u.socialCategory : socialCategories.first;
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _pincodeController.dispose();
    _stateController.dispose();
    _districtController.dispose();
    super.dispose();
  }

  void _save(WidgetRef ref) async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() {
      _isSaving = true;
      _errorMessage = null;
    });

    try {
      final updatedUser = await ref.read(authServiceProvider).updateProfile(
        fullName: _fullNameController.text.trim(),
        gender: _gender,
        address: _addressController.text.trim(),
        state: _stateController.text.trim(),
        district: _districtController.text.trim(),
        city: _cityController.text.trim(),
        pincode: _pincodeController.text.trim(),
        education: _education,
        occupation: _occupation,
        socialCategory: _socialCategory,
      );

      if (mounted) {
        ref.read(authProvider.notifier).setProfile(updatedUser);
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            backgroundColor: Color(0xFF161823),
            content: Text('Profile updated successfully!', style: TextStyle(color: Colors.greenAccent, fontWeight: FontWeight.bold)),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString().replaceAll('Exception: ', '');
          _isSaving = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final mediaQuery = MediaQuery.of(context);

    return Container(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: mediaQuery.viewInsets.bottom + 20,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFF131520),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
        border: Border(
          top: BorderSide(color: Colors.white.withOpacity(0.08), width: 1),
        ),
      ),
      child: Consumer(
        builder: (context, ref, child) {
          return Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Edit Profile',
                        style: GoogleFonts.plusJakartaSans(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          color: Colors.white,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, color: Colors.white70),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ],
                  ),
                  const Divider(color: Colors.white10),
                  const SizedBox(height: 12),
                  if (_errorMessage != null) ...[
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.red.shade900.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.red.shade900.withOpacity(0.3)),
                      ),
                      child: Text(
                        _errorMessage!,
                        style: const TextStyle(color: Colors.redAccent, fontSize: 12),
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],
                  TextFormField(
                    controller: _fullNameController,
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(
                      labelText: 'Full Name',
                      prefixIcon: Icon(Icons.person, color: Colors.white54),
                    ),
                    validator: (val) => val == null || val.isEmpty ? 'Please enter full name' : null,
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: _gender,
                    style: const TextStyle(color: Colors.white),
                    dropdownColor: const Color(0xFF161823),
                    decoration: const InputDecoration(
                      labelText: 'Gender',
                      prefixIcon: Icon(Icons.people, color: Colors.white54),
                    ),
                    items: ['Male', 'Female', 'Other']
                        .map((g) => DropdownMenuItem(value: g, child: Text(g)))
                        .toList(),
                    onChanged: (val) => setState(() => _gender = val!),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _addressController,
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(
                      labelText: 'Address',
                      prefixIcon: Icon(Icons.home, color: Colors.white54),
                    ),
                    validator: (val) => val == null || val.isEmpty ? 'Please enter address' : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _cityController,
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(
                      labelText: 'City/Village',
                      prefixIcon: Icon(Icons.location_city, color: Colors.white54),
                    ),
                    validator: (val) => val == null || val.isEmpty ? 'Please enter city' : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _stateController,
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(
                      labelText: 'State',
                      prefixIcon: Icon(Icons.map_outlined, color: Colors.white54),
                    ),
                    validator: (val) => val == null || val.isEmpty ? 'Please enter state' : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _districtController,
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(
                      labelText: 'District',
                      prefixIcon: Icon(Icons.pin_drop_outlined, color: Colors.white54),
                    ),
                    validator: (val) => val == null || val.isEmpty ? 'Please enter district' : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _pincodeController,
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(
                      labelText: 'Pincode',
                      prefixIcon: Icon(Icons.map, color: Colors.white54),
                    ),
                    keyboardType: TextInputType.number,
                    validator: (val) => val == null || val.length != 6 ? 'Please enter valid pincode' : null,
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: _education,
                    style: const TextStyle(color: Colors.white),
                    dropdownColor: const Color(0xFF161823),
                    decoration: const InputDecoration(
                      labelText: 'Education',
                      prefixIcon: Icon(Icons.school, color: Colors.white54),
                    ),
                    items: ['Under Matric', 'Matric', 'Intermediate', 'Graduate', 'Post Graduate']
                        .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                        .toList(),
                    onChanged: (val) => setState(() => _education = val!),
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: _occupation,
                    style: const TextStyle(color: Colors.white),
                    dropdownColor: const Color(0xFF161823),
                    decoration: const InputDecoration(
                      labelText: 'Occupation',
                      prefixIcon: Icon(Icons.work, color: Colors.white54),
                    ),
                    items: ['Farmer', 'Salaried', 'Self Employed', 'Student', 'Unemployed']
                        .map((o) => DropdownMenuItem(value: o, child: Text(o)))
                        .toList(),
                    onChanged: (val) => setState(() => _occupation = val!),
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: _socialCategory,
                    style: const TextStyle(color: Colors.white),
                    dropdownColor: const Color(0xFF161823),
                    decoration: const InputDecoration(
                      labelText: 'Social Category',
                      prefixIcon: Icon(Icons.layers, color: Colors.white54),
                    ),
                    items: ['General', 'OBC', 'SC', 'ST']
                        .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                        .toList(),
                    onChanged: (val) => setState(() => _socialCategory = val!),
                  ),
                  const SizedBox(height: 24),
                  GlowingButton(
                    onPressed: _isSaving ? null : () => _save(ref),
                    child: _isSaving
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                          )
                        : const Text('Save Changes'),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
