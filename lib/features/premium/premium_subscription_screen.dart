import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ringo_ringtones/data/repositories/ringtone_repository.dart';
import 'package:flutter/material.dart';
import 'package:ringo_ringtones/l10n/app_localizations.dart';
import 'package:ringo_ringtones/core/services/ad_service.dart';

class PremiumSubscriptionScreen extends ConsumerWidget {
  const PremiumSubscriptionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.premiumAppBarTitle),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const Icon(Icons.workspace_premium, size: 80, color: Colors.amber),
            const SizedBox(height: 16),
            Text(
              l10n.premiumUpgradeTitle,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              l10n.premiumUnlockDesc,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 32),
            _buildPlanCard(context, ref, l10n.planMonthly, "₹49 ${l10n.periodMonth}", false),
            const SizedBox(height: 16),
            _buildPlanCard(context, ref, l10n.planLifetime, "₹149 ${l10n.periodOneTime}", true),
            const SizedBox(height: 32),
            Text(
              l10n.linkRestorePurchase,
              style: const TextStyle(decoration: TextDecoration.underline),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildPlanCard(BuildContext context, WidgetRef ref, String title, String price, bool isRecommended) {
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;
    
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isRecommended ? colorScheme.primaryContainer : colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isRecommended ? colorScheme.primary : colorScheme.outline.withAlpha(128),
          width: isRecommended ? 2 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: isRecommended ? colorScheme.onPrimaryContainer : colorScheme.onSurface,
                ),
              ),
              if (isRecommended)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: colorScheme.primary,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    l10n.labelBestValue,
                    style: TextStyle(color: colorScheme.onPrimary, fontSize: 10, fontWeight: FontWeight.bold),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            price,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w900,
              color: isRecommended ? colorScheme.onPrimaryContainer : colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: () {
                // Mock Purchase Logic
                final repo = ref.read(ringtoneRepositoryProvider);
                repo.setPremiumUser(true).then((_) {
                  if (!context.mounted) return;
                  adServiceProvider.isPremium = true;
                  ref.read(isPremiumUserProvider.notifier).state = true;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(l10n.msgPremiumWelcome)),
                  );
                  context.pop(); // Close screen
                });
              },
              style: FilledButton.styleFrom(
                backgroundColor: isRecommended ? colorScheme.primary : colorScheme.surfaceContainerHighest,
                foregroundColor: isRecommended ? colorScheme.onPrimary : colorScheme.onSurfaceVariant,
              ),
              child: Text(l10n.btnSubscribe),
            ),
          ),
        ],
      ),
    );
  }
}
