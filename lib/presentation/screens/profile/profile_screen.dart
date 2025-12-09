import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/helpers.dart';
import '../../../core/localization/app_localizations.dart';
import '../../providers/auth_provider.dart';
import '../../providers/locale_provider.dart';
import '../../widgets/app_bottom_nav.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);
    final user = authState.user;
    final locale = ref.watch(localeProvider);
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.profile),
      ),
      body: user == null
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: AppTheme.paddingL,
              child: Column(
                children: [
                  // Profile Avatar
                  CircleAvatar(
                    radius: 50,
                    backgroundColor: AppTheme.primaryOrange,
                    child: Text(
                      user.name.isNotEmpty ? user.name[0].toUpperCase() : 'U',
                      style: const TextStyle(fontSize: 40, color: Colors.white),
                    ),
                  ),
                  const SizedBox(height: AppTheme.spacingM),
                  
                  // User Name
                  Text(
                    user.name,
                    style: AppTheme.headingMedium,
                  ),
                  const SizedBox(height: AppTheme.spacingS),
                  
                  // User Email
                  Text(
                    user.email,
                    style: AppTheme.bodyMedium,
                  ),
                  const SizedBox(height: AppTheme.spacingXL),
                  
                  // Profile Info Card
                  Card(
                    child: Padding(
                      padding: AppTheme.paddingM,
                      child: Column(
                        children: [
                          _ProfileInfoRow(
                            icon: Icons.badge,
                            label: l10n.role,
                            value: user.role,
                          ),
                          const Divider(),
                          _ProfileInfoRow(
                            icon: Icons.phone,
                            label: l10n.phone,
                            value: user.phone1 ?? l10n.phoneNotSet,
                          ),
                          const Divider(),
                          _ProfileInfoRow(
                            icon: Icons.access_time,
                            label: l10n.memberSince,
                            value: user.createdAt.toString().split(' ')[0],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: AppTheme.spacingL),
                  
                  // Language Settings Card
                  Card(
                    child: Padding(
                      padding: AppTheme.paddingM,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.language,
                                color: AppTheme.primaryOrange,
                              ),
                              const SizedBox(width: 12),
                              Text(
                                l10n.languageSettings,
                                style: AppTheme.headingSmall,
                              ),
                            ],
                          ),
                          const SizedBox(height: AppTheme.spacingM),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                l10n.selectLanguage,
                                style: AppTheme.bodyMedium,
                              ),
                              SegmentedButton<String>(
                                segments: [
                                  ButtonSegment<String>(
                                    value: 'en',
                                    label: Text(l10n.english),
                                    icon: const Icon(Icons.language),
                                  ),
                                  ButtonSegment<String>(
                                    value: 'ar',
                                    label: Text(l10n.arabic),
                                    icon: const Icon(Icons.language),
                                  ),
                                ],
                                selected: {locale.languageCode},
                                onSelectionChanged: (Set<String> newSelection) {
                                  ref.read(localeProvider.notifier).setLocale(
                                        Locale(newSelection.first),
                                      );
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: AppTheme.spacingL),
                  
                  // Actions
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () async {
                        final confirmed = await UIHelper.showConfirmDialog(
                          context,
                          title: l10n.logoutConfirmTitle,
                          message: l10n.logoutConfirmMessage,
                          confirmText: l10n.logout,
                        );
                        
                        if (confirmed) {
                          ref.read(authStateProvider.notifier).logout();
                        }
                      },
                      icon: const Icon(Icons.logout),
                      label: Text(l10n.logout),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.errorRed,
                      ),
                    ),
                  ),
                ],
              ),
            ),
      bottomNavigationBar: const AppBottomNav(currentIndex: 4),
    );
  }
}

class _ProfileInfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _ProfileInfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: AppTheme.primaryOrange),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: AppTheme.bodySmall,
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: AppTheme.bodyLarge,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
