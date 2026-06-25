import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:community_survey/features/context/context_provider.dart';
import 'package:community_survey/core/theme/theme_controller.dart';
import 'package:google_fonts/google_fonts.dart';

class ContextSwitcher extends ConsumerWidget {
  const ContextSwitcher({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final contextState = ref.watch(contextProvider);

    final hasGroups = contextState.availableContexts.any((c) => c.contextType == 'GROUP');

    if (contextState.isLoading || !hasGroups) {
      return const SizedBox.shrink();
    }

    final active = contextState.activeContext;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: ListTile(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          leading: CircleAvatar(
            backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.2),
            child: Icon(
              active?.contextType == 'PROFILE' ? Icons.person : Icons.group,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          title: Text(
            active?.displayName ?? 'Select Profile',
            style: GoogleFonts.plusJakartaSans(
              fontWeight: FontWeight.bold,
            ),
          ),
          subtitle: Text(
            active?.contextType == 'PROFILE' ? 'Personal Profile' : 'Group Context',
            style: GoogleFonts.inter(fontSize: 12, color: Colors.white54),
          ),
          trailing: const Icon(Icons.swap_vert),
          onTap: () {
            _showContextSheet(context, ref, contextState);
          },
        ),
      ),
    );
  }

  void _showContextSheet(BuildContext context, WidgetRef ref, ContextState state) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (BuildContext sheetContext) {
        return Container(
          decoration: BoxDecoration(
            color: Theme.of(sheetContext).colorScheme.background,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 12),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Switch Context',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Flexible(
                child: ListView.builder(
                  shrinkWrap: true,
                  padding: const EdgeInsets.only(left: 16, right: 16, bottom: 32),
                  itemCount: state.availableContexts.length,
                  itemBuilder: (context, index) {
                    final ctx = state.availableContexts[index];
                    final isActive = state.activeContext?.contextId == ctx.contextId;

                    return ListTile(
                      leading: Icon(
                        ctx.contextType == 'PROFILE' ? Icons.person : Icons.group,
                        color: isActive ? Theme.of(context).colorScheme.primary : Colors.white54,
                      ),
                      title: Text(
                        ctx.displayName,
                        style: TextStyle(
                          fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                          color: isActive ? Colors.white : Colors.white70,
                        ),
                      ),
                      subtitle: Text(
                        ctx.contextType == 'PROFILE' ? 'Personal' : (ctx.role ?? 'Member'),
                        style: const TextStyle(fontSize: 12, color: Colors.white54),
                      ),
                      trailing: isActive ? Icon(Icons.check_circle, color: Theme.of(context).colorScheme.primary) : null,
                      onTap: () {
                        Navigator.pop(sheetContext);
                        if (!isActive) {
                          ref.read(contextProvider.notifier).switchContext(ctx);
                          ref.read(themeProvider.notifier).updateContextBranding(ctx);
                        }
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
