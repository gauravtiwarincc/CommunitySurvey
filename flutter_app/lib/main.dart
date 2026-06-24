import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:community_survey/core/theme/theme_controller.dart';
import 'package:community_survey/features/auth/auth_provider.dart';
import 'package:community_survey/features/splash/splash_page.dart';
import 'package:community_survey/features/onboarding/organization_code_page.dart';
import 'package:community_survey/features/auth/login_page.dart';
import 'package:community_survey/features/dashboard/main_tab_container.dart';
import 'package:community_survey/features/web/web_main_layout.dart';
import 'package:community_survey/services/auth_service.dart';
import 'package:community_survey/models/auth_session.dart';

final onboardingCompletedProvider = StateProvider<bool>((ref) => false);
final navigatorKey = GlobalKey<NavigatorState>();

void main() {
  runApp(const ProviderScope(child: CommunitySurveyApp()));
}

class CommunitySurveyApp extends ConsumerWidget {
  const CommunitySurveyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeState = ref.watch(themeProvider);

    return MaterialApp(
      navigatorKey: navigatorKey,
      title: 'Community Survey',
      theme: themeState.lightTheme,
      darkTheme: themeState.darkTheme,
      themeMode: ThemeMode.system,
      scrollBehavior: const MaterialScrollBehavior().copyWith(
        dragDevices: {PointerDeviceKind.mouse, PointerDeviceKind.touch, PointerDeviceKind.trackpad, PointerDeviceKind.stylus},
      ),
      debugShowCheckedModeBanner: false,
      home: const AppRootRouter(),
      builder: (context, child) {
        return AppAlertListener(child: child!);
      },
    );
  }
}

class AppRootRouter extends ConsumerStatefulWidget {
  const AppRootRouter({super.key});

  @override
  ConsumerState<AppRootRouter> createState() => _AppRootRouterState();
}

class _AppRootRouterState extends ConsumerState<AppRootRouter> {
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _restoreSession();
  }

  void _restoreSession() async {
    final tokenStore = ref.read(tokenStoreProvider);
    final authService = ref.read(authServiceProvider);
    final authNotifier = ref.read(authProvider.notifier);

    final token = await tokenStore.getToken();
    if (token != null) {
      try {
        final profile = await authService.getProfile();
        await authNotifier.setSession(AuthSession(
          accessToken: token,
          refreshToken: '',
          expiresAt: DateTime.now().add(const Duration(hours: 1)),
          user: AuthenticatedUser(
            id: profile.id,
            mobileNumber: profile.mobile ?? '',
            countryCode: '+91',
            role: profile.role,
            organization: profile.organization,
          ),
        ));
        authNotifier.setProfile(profile);
        ref.read(onboardingCompletedProvider.notifier).state = true;
      } catch (_) {
        authNotifier.logout();
      }
    }
    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const SplashPage();
    }

    final authState = ref.watch(authProvider);
    final isOnboardingCompleted = ref.watch(onboardingCompletedProvider);

    if (authState.isAuthenticated) {
      return kIsWeb ? const WebMainLayout() : const MainTabContainer();
    } else if (!isOnboardingCompleted) {
      return const OrganizationCodePage();
    } else {
      return const LoginPage();
    }
  }
}

class AppAlertListener extends ConsumerWidget {
  final Widget child;

  const AppAlertListener({super.key, required this.child});

  void _showErrorDialog(WidgetRef ref, String title, String message) {
    final context = navigatorKey.currentState?.overlay?.context;
    if (context == null) return;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
                ref.read(authProvider.notifier).clearAlerts();
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen<AuthState>(authProvider, (previous, next) {
      if (next.deactivationMessage != null) {
        _showErrorDialog(ref, 'Account Deactivated', next.deactivationMessage!);
      } else if (next.sessionExpiredMessage != null) {
        _showErrorDialog(ref, 'Session Expired', next.sessionExpiredMessage!);
      }
    });

    return child;
  }
}
