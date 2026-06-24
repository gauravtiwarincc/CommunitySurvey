import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:community_survey/services/auth_service.dart';
import 'package:community_survey/features/auth/auth_provider.dart';
import 'package:community_survey/models/admin_models.dart';
import 'package:community_survey/main.dart';
import 'package:community_survey/core/network/api_client.dart';

class RegisterPage extends ConsumerStatefulWidget {
  final String? organizationCode;
  final OrganizationConfig? config;

  const RegisterPage({
    super.key,
    this.organizationCode,
    this.config,
  });

  @override
  ConsumerState<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends ConsumerState<RegisterPage> {
  final _formKey = GlobalKey<FormState>();

  final _fullNameController = TextEditingController();
  final _mobileController = TextEditingController();
  final _passwordController = TextEditingController();
  final _addressController = TextEditingController();
  final _cityController = TextEditingController();
  final _pincodeController = TextEditingController();

  String _gender = 'Male';
  String _state = 'Delhi';
  String _district = 'Central Delhi';
  String _education = 'Graduate';
  String _occupation = 'Self Employed';
  String _socialCategory = 'General';

  bool _isLoading = false;
  String? _errorMessage;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _fullNameController.dispose();
    _mobileController.dispose();
    _passwordController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _pincodeController.dispose();
    super.dispose();
  }

  void _register() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final authService = ref.read(authServiceProvider);
      final authNotifier = ref.read(authProvider.notifier);
      final tokenStore = ref.read(tokenStoreProvider);

      final session = await authService.register(
        fullName: _fullNameController.text.trim(),
        fathersName: '',
        gender: _gender,
        mobile: _mobileController.text.trim(),
        password: _passwordController.text.trim(),
        aadhaar: '',
        address: _addressController.text.trim(),
        organizationId: widget.config?.id,
        organizationName: widget.config?.organizationName,
        organizationType: widget.config?.organizationType,
        organizationCode: widget.organizationCode,
        state: _state,
        district: _district,
        pincode: _pincodeController.text.trim(),
        education: _education,
        occupation: _occupation,
        socialCategory: _socialCategory,
        city: _cityController.text.trim(),
      );

      // Save token first so the interceptor can use it for getProfile()
      await tokenStore.saveToken(session.accessToken);
      
      // Fetch and set profile
      final profile = await authService.getProfile();
      
      // Update state all at once (this triggers the navigation)
      authNotifier.setProfile(profile);
      await authNotifier.setSession(session);

      ref.read(onboardingCompletedProvider.notifier).state = true;
      
      if (mounted) {
        // Pop back to root router which will switch home to MainTabContainer
        Navigator.of(context).popUntil((route) => route.isFirst);
      }
    } catch (e) {
      setState(() {
        _errorMessage = getApiErrorMessage(e);
      });
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Complete Registration'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (widget.config != null) ...[
                  Card(
                    color: theme.colorScheme.primary.withOpacity(0.08),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      side: BorderSide(color: theme.colorScheme.primary.withOpacity(0.2)),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          if (widget.config?.logoUrl != null && widget.config!.logoUrl!.isNotEmpty)
                            Image.network(widget.config!.logoUrl!, height: 50, errorBuilder: (_, __, ___) => const Icon(Icons.business, size: 50)),
                          const SizedBox(height: 10),
                          Text(
                            widget.config!.organizationName,
                            style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            widget.config!.welcomeMessage ?? 'Welcome to our Group!',
                            textAlign: TextAlign.center,
                            style: theme.textTheme.bodyMedium?.copyWith(color: Colors.white54),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
                if (_errorMessage != null) ...[
                  Text(
                    _errorMessage!,
                    style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                ],
                TextFormField(
                  controller: _fullNameController,
                  decoration: const InputDecoration(labelText: 'Full Name', prefixIcon: Icon(Icons.person)),
                  validator: (val) => val == null || val.isEmpty ? 'Please enter full name' : null,
                ),

                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: _gender,
                  decoration: const InputDecoration(labelText: 'Gender', prefixIcon: Icon(Icons.people)),
                  items: ['Male', 'Female', 'Other']
                      .map((g) => DropdownMenuItem(value: g, child: Text(g)))
                      .toList(),
                  onChanged: (val) => setState(() => _gender = val!),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _mobileController,
                  decoration: const InputDecoration(labelText: 'Mobile Number', prefixIcon: Icon(Icons.phone)),
                  keyboardType: TextInputType.phone,
                  validator: (val) => val == null || val.length < 10 ? 'Please enter valid mobile' : null,
                ),

                const SizedBox(height: 16),
                TextFormField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    prefixIcon: const Icon(Icons.lock),
                    suffixIcon: IconButton(
                      icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility),
                      onPressed: () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
                    ),
                  ),
                  validator: (val) => val == null || val.length < 6 ? 'Password must be at least 6 characters' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _addressController,
                  decoration: const InputDecoration(labelText: 'Address', prefixIcon: Icon(Icons.home)),
                  validator: (val) => val == null || val.isEmpty ? 'Please enter address' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _cityController,
                  decoration: const InputDecoration(labelText: 'City/Village', prefixIcon: Icon(Icons.location_city)),
                  validator: (val) => val == null || val.isEmpty ? 'Please enter city' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _pincodeController,
                  decoration: const InputDecoration(labelText: 'Pincode', prefixIcon: Icon(Icons.map)),
                  keyboardType: TextInputType.number,
                  validator: (val) => val == null || val.length != 6 ? 'Please enter valid pincode' : null,
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: _education,
                  decoration: const InputDecoration(labelText: 'Education', prefixIcon: Icon(Icons.school)),
                  items: ['Under Matric', 'Matric', 'Intermediate', 'Graduate', 'Post Graduate']
                      .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                      .toList(),
                  onChanged: (val) => setState(() => _education = val!),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: _occupation,
                  decoration: const InputDecoration(labelText: 'Occupation', prefixIcon: Icon(Icons.work)),
                  items: ['Farmer', 'Salaried', 'Self Employed', 'Student', 'Unemployed']
                      .map((o) => DropdownMenuItem(value: o, child: Text(o)))
                      .toList(),
                  onChanged: (val) => setState(() => _occupation = val!),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: _socialCategory,
                  decoration: const InputDecoration(labelText: 'Social Category', prefixIcon: Icon(Icons.layers)),
                  items: ['General', 'OBC', 'SC', 'ST']
                      .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                      .toList(),
                  onChanged: (val) => setState(() => _socialCategory = val!),
                ),
                const SizedBox(height: 32),
                ElevatedButton(
                  onPressed: _isLoading ? null : _register,
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator( strokeWidth: 2),
                        )
                      : const Text('Submit & Register'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
