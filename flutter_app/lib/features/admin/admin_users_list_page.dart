import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:community_survey/services/admin_service.dart';
import 'package:community_survey/models/admin_models.dart';
import 'package:community_survey/features/admin/admin_user_detail_page.dart';
import 'package:community_survey/core/theme/premium_theme.dart';
import 'package:community_survey/core/widgets/glass_card.dart';
import 'package:google_fonts/google_fonts.dart';

class AdminUsersListPage extends ConsumerStatefulWidget {
  const AdminUsersListPage({super.key});

  @override
  ConsumerState<AdminUsersListPage> createState() => _AdminUsersListPageState();
}

class _AdminUsersListPageState extends ConsumerState<AdminUsersListPage> {
  final _searchController = TextEditingController();
  final _scrollController = ScrollController();

  List<AdminUserItem> _users = [];
  bool _isLoading = false;
  int _currentPage = 1;
  int _totalPages = 1;
  String _searchQuery = '';
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadUsers();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
      if (!_isLoading && _currentPage < _totalPages) {
        _loadMoreUsers();
      }
    }
  }

  Future<void> _loadUsers() async {
    setState(() {
      _isLoading = true;
      _currentPage = 1;
      _errorMessage = null;
    });

    try {
      final response = await ref.read(adminServiceProvider).fetchUsers(_searchQuery, 1);
      if (mounted) {
        setState(() {
          _users = response.users;
          _totalPages = response.pagination.totalPages;
        });
      }
    } catch (e) {
      setState(() => _errorMessage = e.toString().replaceAll('Exception: ', ''));
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _loadMoreUsers() async {
    setState(() {
      _isLoading = true;
    });

    final nextPage = _currentPage + 1;
    try {
      final response = await ref.read(adminServiceProvider).fetchUsers(_searchQuery, nextPage);
      if (mounted) {
        setState(() {
          _currentPage = nextPage;
          _users.addAll(response.users);
          _totalPages = response.pagination.totalPages;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load next page: ${e.toString()}')),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _onSearchChanged(String val) {
    setState(() {
      _searchQuery = val.trim();
    });
    _loadUsers();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(
          'Manage Members',
          style: GoogleFonts.plusJakartaSans(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: PremiumMeshBackground(
        child: Column(
          children: [
            const SizedBox(height: kToolbarHeight + 16.0),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  labelText: 'Search Members',
                  hintText: 'Enter name or mobile number...',
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                  suffixIcon: _searchQuery.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            _searchController.clear();
                            _onSearchChanged('');
                          },
                        )
                      : null,
                ),
                onChanged: _onSearchChanged,
              ),
            ),
            Expanded(
            child: _isLoading && _users.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : _errorMessage != null && _users.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(_errorMessage!, style: const TextStyle(color: Colors.red)),
                            const SizedBox(height: 16),
                            ElevatedButton(onPressed: _loadUsers, child: const Text('Retry')),
                          ],
                        ),
                      )
                    : _users.isEmpty
                        ? const Center(child: Text('No members found.'))
                        : RefreshIndicator(
                            onRefresh: _loadUsers,
                            child: ListView.builder(
                              controller: _scrollController,
                              padding: const EdgeInsets.symmetric(horizontal: 12),
                              itemCount: _users.length + (_isLoading ? 1 : 0),
                              itemBuilder: (context, index) {
                                if (index == _users.length) {
                                  return const Padding(
                                    padding: EdgeInsets.all(16.0),
                                    child: Center(child: CircularProgressIndicator()),
                                  );
                                }

                                final user = _users[index];
                                return Container(
                                  margin: const EdgeInsets.only(bottom: 12),
                                  child: GlassCard(
                                    padding: EdgeInsets.zero,
                                    child: ListTile(
                                      contentPadding: const EdgeInsets.all(16),
                                      title: Text(
                                        user.fullName,
                                        style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold),
                                      ),
                                      subtitle: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          const SizedBox(height: 6),
                                          Text('Mobile: ${user.mobile}', style: const TextStyle( fontSize: 13)),
                                          Text('Completed: ${user.completedSurveysCount} surveys', style: const TextStyle( fontSize: 13)),
                                        ],
                                      ),
                                      trailing: Column(
                                        crossAxisAlignment: CrossAxisAlignment.end,
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            '₹${user.walletBalance}',
                                            style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            '${user.rewardPoints} pts',
                                            style: const TextStyle(color: Colors.orange, fontSize: 12),
                                          ),
                                        ],
                                      ),
                                      onTap: () {
                                        Navigator.of(context).push(
                                          MaterialPageRoute(
                                            builder: (context) => AdminUserDetailPage(userId: user.id),
                                          ),
                                        ).then((_) => _loadUsers());
                                      },
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
          ),
        ],
      )),
    );
  }
}
