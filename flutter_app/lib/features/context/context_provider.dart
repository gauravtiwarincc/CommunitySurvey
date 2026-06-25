import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:community_survey/models/user_context.dart';
import 'package:community_survey/services/context_service.dart';
import 'package:community_survey/core/storage/token_store.dart';
import 'package:community_survey/features/auth/auth_provider.dart';
import 'package:community_survey/core/theme/theme_controller.dart';

class ContextState {
  final List<UserContext> availableContexts;
  final UserContext? activeContext;
  final bool isLoading;
  final String? error;

  ContextState({
    this.availableContexts = const [],
    this.activeContext,
    this.isLoading = false,
    this.error,
  });

  ContextState copyWith({
    List<UserContext>? availableContexts,
    UserContext? activeContext,
    bool? isLoading,
    String? error,
  }) {
    return ContextState(
      availableContexts: availableContexts ?? this.availableContexts,
      activeContext: activeContext ?? this.activeContext,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class ContextNotifier extends StateNotifier<ContextState> {
  final ContextService _contextService;
  final TokenStoreProtocol _tokenStore;
  final Ref _ref;

  ContextNotifier(this._contextService, this._tokenStore, this._ref) : super(ContextState());

  Future<void> fetchContexts() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final contexts = await _contextService.getAvailableContexts();
      
      UserContext? active;
      if (_tokenStore is TokenStore) {
        final saved = await (_tokenStore as TokenStore).getActiveContext();
        if (saved != null) {
          try {
            active = contexts.firstWhere((c) => c.contextId == saved['contextId'] && c.contextType == saved['contextType']);
          } catch (_) {
            active = null;
          }
        }
      }

      if (active == null && contexts.isNotEmpty) {
        // Fallback to PROFILE context
        try {
          active = contexts.firstWhere((c) => c.contextType == 'PROFILE');
        } catch (_) {
          active = contexts.first;
        }
      }

      state = state.copyWith(
        availableContexts: contexts,
        activeContext: active,
        isLoading: false,
      );

      if (active != null) {
        _ref.read(themeProvider.notifier).updateContextBranding(active);
        if (_tokenStore is TokenStore) {
          await (_tokenStore as TokenStore).saveActiveContext(active.contextType, active.contextId);
        }
      }
      
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> switchContext(UserContext context) async {
    state = state.copyWith(activeContext: context);
    _ref.read(themeProvider.notifier).updateContextBranding(context);
    if (_tokenStore is TokenStore) {
      await (_tokenStore as TokenStore).saveActiveContext(context.contextType, context.contextId);
    }
  }
}

final contextProvider = StateNotifierProvider<ContextNotifier, ContextState>((ref) {
  final contextService = ref.watch(contextServiceProvider);
  final tokenStore = ref.watch(tokenStoreProvider);
  return ContextNotifier(contextService, tokenStore, ref);
});
