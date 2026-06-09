import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:community_survey/models/auth_session.dart';
import 'package:community_survey/models/user.dart';
import 'package:community_survey/core/storage/token_store.dart';
import 'package:community_survey/core/theme/theme_controller.dart';

class AuthState {
  final AuthSession? session;
  final User? profile;
  final bool isAuthenticated;
  final String? deactivationMessage;
  final String? sessionExpiredMessage;

  AuthState({
    this.session,
    this.profile,
    this.isAuthenticated = false,
    this.deactivationMessage,
    this.sessionExpiredMessage,
  });

  AuthState copyWith({
    AuthSession? session,
    User? profile,
    bool? isAuthenticated,
    String? deactivationMessage,
    String? sessionExpiredMessage,
  }) {
    return AuthState(
      session: session ?? this.session,
      profile: profile ?? this.profile,
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      deactivationMessage: deactivationMessage,
      sessionExpiredMessage: sessionExpiredMessage,
    );
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  final TokenStoreProtocol tokenStore;
  final Ref ref;

  AuthNotifier(this.tokenStore, this.ref) : super(AuthState());

  Future<void> setSession(AuthSession session) async {
    await tokenStore.saveToken(session.accessToken);
    state = AuthState(session: session, isAuthenticated: true);
  }

  void setProfile(User profile) {
    state = state.copyWith(profile: profile);
    // Apply dynamic organization theme when profile is loaded
    ref.read(themeProvider.notifier).updateBranding(profile.organization);
  }

  Future<void> logout() async {
    await tokenStore.clearToken();
    state = AuthState();
    ref.read(themeProvider.notifier).updateBranding(null);
  }

  Future<void> evictSession(String message) async {
    await tokenStore.clearToken();
    state = AuthState(
      sessionExpiredMessage: message,
    );
    ref.read(themeProvider.notifier).updateBranding(null);
  }

  void handleDeactivationDuringAuth(String message) {
    state = state.copyWith(
      deactivationMessage: message,
    );
  }

  void clearAlerts() {
    state = state.copyWith(
      deactivationMessage: null,
      sessionExpiredMessage: null,
    );
  }
}

final tokenStoreProvider = Provider<TokenStoreProtocol>((ref) {
  return TokenStore();
});

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final store = ref.watch(tokenStoreProvider);
  return AuthNotifier(store, ref);
});
