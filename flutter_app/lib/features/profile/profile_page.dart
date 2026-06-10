import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:community_survey/features/auth/auth_provider.dart';
import 'package:community_survey/models/user.dart';
import 'package:community_survey/services/auth_service.dart';

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
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          if (user != null)
            IconButton(
              icon: const Icon(Icons.edit),
              tooltip: 'Edit Profile',
              onPressed: () => _showEditProfileSheet(context, user),
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (user != null) ...[
              Card(
                elevation: 0,
                color: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: BorderSide(color: Colors.grey.shade200),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    children: [
                      const CircleAvatar(
                        radius: 40,
                        child: Icon(Icons.person, size: 48),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        user.fullName,
                        style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Role: ${user.role.name.toUpperCase()}',
                        style: TextStyle(color: theme.colorScheme.primary, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Card(
                elevation: 0,
                color: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: BorderSide(color: Colors.grey.shade200),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      _buildDetailRow('Mobile', user.mobile ?? '-'),
                      const Divider(),
                      _buildDetailRow('Aadhaar', user.aadhaar ?? '-'),
                      const Divider(),
                      _buildDetailRow("Father's Name", user.fathersName ?? '-'),
                      const Divider(),
                      _buildDetailRow('Gender', user.gender ?? '-'),
                      const Divider(),
                      _buildDetailRow('State', user.state ?? '-'),
                      const Divider(),
                      _buildDetailRow('District', user.district ?? '-'),
                      const Divider(),
                      _buildDetailRow('City/Village', user.city ?? '-'),
                      const Divider(),
                      _buildDetailRow('Address', user.address ?? '-'),
                      const Divider(),
                      _buildDetailRow('Pincode', user.pincode ?? '-'),
                      const Divider(),
                      _buildDetailRow('Education', user.education ?? '-'),
                      const Divider(),
                      _buildDetailRow('Occupation', user.occupation ?? '-'),
                      const Divider(),
                      _buildDetailRow('Social Category', user.socialCategory ?? '-'),
                      if (user.organization != null) ...[
                        const Divider(),
                        _buildDetailRow('Organization', user.organization!.organizationName),
                      ],
                    ],
                  ),
                ),
              ),
            ] else
              const Center(child: Text('User profile not loaded.')),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () {
                ref.read(authProvider.notifier).logout();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red.shade600,
                foregroundColor: Colors.white,
              ),
              child: const Text('Log Out'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: const TextStyle(color: Colors.grey, fontSize: 14)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
        ],
      ),
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
          const SnackBar(content: Text('Profile updated successfully!')),
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
        color: Colors.white,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
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
                        style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ],
                  ),
                  const Divider(),
                  const SizedBox(height: 12),
                  if (_errorMessage != null) ...[
                    Text(
                      _errorMessage!,
                      style: const TextStyle(color: Colors.red, fontSize: 13),
                    ),
                    const SizedBox(height: 12),
                  ],
                  TextFormField(
                    controller: _fullNameController,
                    decoration: const InputDecoration(
                      labelText: 'Full Name',
                      prefixIcon: Icon(Icons.person),
                    ),
                    validator: (val) => val == null || val.isEmpty ? 'Please enter full name' : null,
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: _gender,
                    decoration: const InputDecoration(
                      labelText: 'Gender',
                      prefixIcon: Icon(Icons.people),
                    ),
                    items: ['Male', 'Female', 'Other']
                        .map((g) => DropdownMenuItem(value: g, child: Text(g)))
                        .toList(),
                    onChanged: (val) => setState(() => _gender = val!),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _addressController,
                    decoration: const InputDecoration(
                      labelText: 'Address',
                      prefixIcon: Icon(Icons.home),
                    ),
                    validator: (val) => val == null || val.isEmpty ? 'Please enter address' : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _cityController,
                    decoration: const InputDecoration(
                      labelText: 'City/Village',
                      prefixIcon: Icon(Icons.location_city),
                    ),
                    validator: (val) => val == null || val.isEmpty ? 'Please enter city' : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _stateController,
                    decoration: const InputDecoration(
                      labelText: 'State',
                      prefixIcon: Icon(Icons.map_outlined),
                    ),
                    validator: (val) => val == null || val.isEmpty ? 'Please enter state' : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _districtController,
                    decoration: const InputDecoration(
                      labelText: 'District',
                      prefixIcon: Icon(Icons.pin_drop_outlined),
                    ),
                    validator: (val) => val == null || val.isEmpty ? 'Please enter district' : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _pincodeController,
                    decoration: const InputDecoration(
                      labelText: 'Pincode',
                      prefixIcon: Icon(Icons.map),
                    ),
                    keyboardType: TextInputType.number,
                    validator: (val) => val == null || val.length != 6 ? 'Please enter valid pincode' : null,
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: _education,
                    decoration: const InputDecoration(
                      labelText: 'Education',
                      prefixIcon: Icon(Icons.school),
                    ),
                    items: ['Under Matric', 'Matric', 'Intermediate', 'Graduate', 'Post Graduate']
                        .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                        .toList(),
                    onChanged: (val) => setState(() => _education = val!),
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: _occupation,
                    decoration: const InputDecoration(
                      labelText: 'Occupation',
                      prefixIcon: Icon(Icons.work),
                    ),
                    items: ['Farmer', 'Salaried', 'Self Employed', 'Student', 'Unemployed']
                        .map((o) => DropdownMenuItem(value: o, child: Text(o)))
                        .toList(),
                    onChanged: (val) => setState(() => _occupation = val!),
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: _socialCategory,
                    decoration: const InputDecoration(
                      labelText: 'Social Category',
                      prefixIcon: Icon(Icons.layers),
                    ),
                    items: ['General', 'OBC', 'SC', 'ST']
                        .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                        .toList(),
                    onChanged: (val) => setState(() => _socialCategory = val!),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
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
