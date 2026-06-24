import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:community_survey/services/admin_service.dart';
import 'package:community_survey/services/survey_service.dart';
import 'package:community_survey/features/auth/auth_provider.dart';
import 'package:community_survey/models/admin_models.dart';
import 'package:community_survey/models/user.dart';
import 'package:community_survey/core/theme/premium_theme.dart';
import 'package:community_survey/core/widgets/glass_card.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class AdminUserDetailPage extends ConsumerStatefulWidget {
  final String userId;

  const AdminUserDetailPage({super.key, required this.userId});

  @override
  ConsumerState<AdminUserDetailPage> createState() => _AdminUserDetailPageState();
}

class _AdminUserDetailPageState extends ConsumerState<AdminUserDetailPage> {
  bool _isLoading = false;
  AdminUserDetailResponse? _userDetail;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadUserDetail();
  }

  Future<void> _loadUserDetail() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final currentUserId = ref.read(authProvider).profile?.id;
    final isSelf = currentUserId != null && currentUserId == widget.userId;

    try {
      if (isSelf) {
        final profile = ref.read(authProvider).profile;
        if (profile == null) {
          throw Exception('Profile not loaded');
        }
        final dashboardData = await ref.read(surveyServiceProvider).fetchSurveysDashboard();

        final userProfileInfo = UserProfileInfo(
          id: profile.id,
          fullName: profile.fullName,
          mobile: profile.mobile ?? '',
          aadhaar: profile.aadhaar ?? '',
          role: profile.role.name,
          walletBalance: profile.walletBalance ?? 0,
          rewardPoints: profile.rewardPoints ?? 0,
          state: profile.state,
          district: profile.district,
          city: profile.city,
          createdAt: '',
          isActive: profile.isActive,
        );

        final pending = [
          ...(dashboardData.organizationSurveys ?? []),
          ...dashboardData.availableSurveys,
        ].map((s) => PendingSurveyItem(
          surveyId: s.id,
          title: s.title,
          rewardPoints: s.rewardPoints,
        )).toList();

        final completed = [
          ...(dashboardData.completedOrganizationSurveys ?? []),
          ...dashboardData.completedSurveys,
        ].map((s) => CompletedSurveyItem(
          surveyId: s.id,
          title: s.title,
          rewardPoints: s.rewardPoints,
          completedAt: DateTime.now().toIso8601String(),
        )).toList();

        if (mounted) {
          setState(() {
            _userDetail = AdminUserDetailResponse(
              success: true,
              user: userProfileInfo,
              completedSurveys: completed,
              pendingSurveys: pending,
            );
          });
        }
      } else {
        final data = await ref.read(adminServiceProvider).fetchUserDetail(widget.userId);
        if (mounted) {
          setState(() => _userDetail = data);
        }
      }
    } catch (e) {
      setState(() => _errorMessage = e.toString().replaceAll('Exception: ', ''));
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _toggleUserStatus(bool targetStatus) async {
    setState(() {
      _isLoading = true;
    });

    try {
      final updatedProfile = await ref.read(adminServiceProvider).updateUserStatus(widget.userId, targetStatus);
      if (mounted) {
        setState(() {
          _userDetail = AdminUserDetailResponse(
            success: true,
            user: updatedProfile,
            completedSurveys: _userDetail!.completedSurveys,
            pendingSurveys: _userDetail!.pendingSurveys,
          );
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(targetStatus ? 'User activated successfully.' : 'User deactivated successfully.'),
            backgroundColor: targetStatus ? Colors.green : Colors.red,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Error'),
            content: Text(e.toString().replaceAll('Exception: ', '')),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('OK'),
              ),
            ],
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _toggleUserRole(String newRole) async {
    setState(() {
      _isLoading = true;
    });

    try {
      final success = await ref.read(adminServiceProvider).updateUserRole(widget.userId, newRole);
      if (success && mounted) {
        await _loadUserDetail();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('User role updated to $newRole.'),
              backgroundColor: Colors.green,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Error'),
            content: Text(e.toString().replaceAll('Exception: ', '')),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('OK'),
              ),
            ],
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final currentAdmin = ref.watch(authProvider).session?.user;
    final isSelf = currentAdmin != null && currentAdmin.id == widget.userId;

    final user = _userDetail?.user;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(
          'Member Details',
          style: GoogleFonts.plusJakartaSans(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: PremiumMeshBackground(
        child: _isLoading && _userDetail == null
            ? const Center(child: CircularProgressIndicator())
            : _errorMessage != null && _userDetail == null
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(_errorMessage!, style: const TextStyle(color: Colors.redAccent)),
                        const SizedBox(height: 16),
                        ElevatedButton(onPressed: _loadUserDetail, child: const Text('Retry')),
                      ],
                    ),
                  )
                : _userDetail == null
                    ? const Center(child: Text('User profile not found.'))
                    : SingleChildScrollView(
                        padding: const EdgeInsets.fromLTRB(20.0, kToolbarHeight + 20, 20.0, 20.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            _buildProfileCard(user!, isSelf, theme),
                            const SizedBox(height: 20),
                            _buildStatsGrid(user, theme),
                            const SizedBox(height: 24),
                            _buildSurveyProgressList('Completed Surveys', _userDetail!.completedSurveys, Colors.greenAccent),
                            const SizedBox(height: 16),
                            _buildSurveyProgressList('Pending Surveys', _userDetail!.pendingSurveys, Colors.orangeAccent),
                          ],
                        ),
                      ),
      ),
    );
  }

  Widget _buildProfileCard(UserProfileInfo user, bool isSelf, ThemeData theme) {
    String formattedDate = '-';
    try {
      final parsed = DateTime.parse(user.createdAt);
      formattedDate = DateFormat.yMMMMd().format(parsed);
    } catch (_) {}

    final currentUserProfile = ref.watch(authProvider).profile;
    final currentRole = currentUserProfile?.role ?? UserRole.user;
    final targetRole = UserRole.fromString(user.role);

    bool canToggleStatus = false;
    if (!isSelf && currentUserProfile != null) {
      if (currentRole == UserRole.superAdmin) {
        canToggleStatus = true;
      } else if (currentRole == UserRole.admin) {
        if (targetRole == UserRole.user) {
          canToggleStatus = true;
        }
      }
    }

    return GlassCard(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            user.fullName,
            style: GoogleFonts.plusJakartaSans(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          _buildDetailItem('Mobile', user.mobile),
          _buildDetailItem('Registration Date', formattedDate),
          if (user.state != null) _buildDetailItem('State', user.state!),
          if (user.district != null) _buildDetailItem('District', user.district!),
          if (user.city != null) _buildDetailItem('City/Village', user.city!),
          const Divider(height: 24),
          if (!isSelf && currentRole == UserRole.superAdmin)
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        targetRole == UserRole.admin || targetRole == UserRole.superAdmin ? 'Admin Privileges' : 'Standard User',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: targetRole == UserRole.admin || targetRole == UserRole.superAdmin ? Colors.purpleAccent : Colors.white70,
                        ),
                      ),
                      const Text(
                        'Toggle to grant or revoke Admin role',
                        style: TextStyle(fontSize: 11),
                      ),
                    ],
                  ),
                ),
                Switch.adaptive(
                  value: targetRole == UserRole.admin || targetRole == UserRole.superAdmin,
                  activeColor: Colors.purpleAccent,
                  onChanged: (!_isLoading && targetRole != UserRole.superAdmin)
                      ? (val) {
                          _toggleUserRole(val ? 'admin' : 'user');
                        }
                      : null,
                ),
              ],
            ),
          if (!isSelf && currentRole == UserRole.superAdmin)
            const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user.isActive ? 'Account Active' : 'Account Deactivated',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: user.isActive ? Colors.greenAccent : Colors.redAccent,
                      ),
                    ),
                    Text(
                      isSelf
                          ? 'You cannot deactivate your own account'
                          : (!canToggleStatus && (targetRole == UserRole.admin || targetRole == UserRole.superAdmin))
                              ? 'Only Super Admins can toggle Admin accounts'
                              : 'Toggle to change participant activation status',
                      style: const TextStyle(fontSize: 11),
                    ),
                  ],
                ),
              ),
              Switch.adaptive(
                value: user.isActive,
                activeColor: Colors.greenAccent,
                onChanged: (canToggleStatus && !_isLoading)
                    ? (val) {
                        _toggleUserStatus(val);
                      }
                    : null,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDetailItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle( fontSize: 13)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
        ],
      ),
    );
  }

  Widget _buildStatsGrid(UserProfileInfo user, ThemeData theme) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 10,
      mainAxisSpacing: 10,
      childAspectRatio: 1.5,
      children: [
        _buildStatBox('Completed', '${_userDetail?.completedSurveys.length ?? 0}', Colors.green),
        _buildStatBox('Pending', '${_userDetail?.pendingSurveys.length ?? 0}', Colors.orange),
        _buildStatBox('Points Balance', '${user.rewardPoints}', Colors.deepOrange),
        _buildStatBox('Wallet', '₹${user.walletBalance}', Colors.teal),
      ],
    );
  }

  Widget _buildStatBox(String label, String value, Color color) {
    return GlassCard(
      padding: const EdgeInsets.all(12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(value, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color)),
          const SizedBox(height: 4),
          Text(label, style: const TextStyle(fontSize: 11)),
        ],
      ),
    );
  }

  Widget _buildSurveyProgressList(String title, List<dynamic> list, Color color) {
    return GlassCard(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.assignment_turned_in_outlined, color: color, size: 20),
              const SizedBox(width: 8),
              Text(title, style: GoogleFonts.plusJakartaSans(fontSize: 15, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 12),
          if (list.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 8.0),
              child: Text('No surveys in this category', style: TextStyle( fontSize: 13)),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: list.length,
              separatorBuilder: (_, __) => const Divider(color: Colors.white12),
              itemBuilder: (context, index) {
                final item = list[index];
                final isCompleted = item is CompletedSurveyItem;

                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          item.title,
                          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            '${item.rewardPoints} pts',
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                          ),
                          if (isCompleted)
                            Text(
                              DateFormat.yMMMd().format(DateTime.parse(item.completedAt)),
                              style: const TextStyle( fontSize: 10),
                            ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
        ],
      ),
    );
  }
}
