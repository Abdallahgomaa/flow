import 'package:flow/core/result/failure.dart';
import 'package:flow/core/result/result.dart';
import 'package:flow/features/auth/data/auth_providers.dart';
import 'package:flow/features/auth/data/session_notifier.dart';
import 'package:flow/features/auth/domain/use_cases/initialize_owner.dart';
import 'package:flow/features/auth/domain/user.dart';
import 'package:flow/shared/design/design.dart';
import 'package:flow/shared/l10n/l10n.dart';
import 'package:flow/shared/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Failure code used when the two secret fields disagree.
///
/// It belongs to the screen, not to `InitializeOwner`: confirming a secret is a
/// safeguard against a typo, not a rule of the domain.
const String _secretMismatchCode = 'ownerSetup.secretMismatch';

/// Asks for the first account — the owner — on a brand-new installation.
///
/// A fresh database holds no accounts, so nobody could sign in and there would
/// be no way to add one. This screen closes that gap: it collects the owner's
/// login name and secret, seeds the built-in roles the account needs, creates
/// the owner, opens the session with it and hands the operator on to the point
/// of sale. The secret itself is never stored — only its Argon2id hash.
///
/// It owns its own [Scaffold] because it sits outside the adaptive shell.
class OwnerSetupScreen extends ConsumerStatefulWidget {
  /// Creates the screen.
  ///
  /// [onInitialised] is injected by the router, so the screen can hand the
  /// operator on without importing the routing layer itself.
  const OwnerSetupScreen({this.onInitialised, super.key});

  /// Called after the owner was created and the session was opened.
  final VoidCallback? onInitialised;

  @override
  ConsumerState<OwnerSetupScreen> createState() => _OwnerSetupScreenState();
}

class _OwnerSetupScreenState extends ConsumerState<OwnerSetupScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _secretController = TextEditingController();
  final TextEditingController _confirmController = TextEditingController();
  final FocusNode _secretFocus = FocusNode();
  final FocusNode _confirmFocus = FocusNode();

  /// Whether a submission is in flight, so the button blocks a double tap.
  bool _submitting = false;

  /// The reason the last attempt failed, if any.
  Failure? _failure;

  @override
  void dispose() {
    _usernameController.dispose();
    _secretController.dispose();
    _confirmController.dispose();
    _secretFocus.dispose();
    _confirmFocus.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_submitting) {
      return;
    }

    // Confirming the secret is a screen-level check: the owner's password has no
    // recovery path yet, so a typo here would lock the business out for good.
    if (_secretController.text != _confirmController.text) {
      setState(() {
        _failure = const ValidationFailure(
          message: 'The two secrets do not match.',
          code: _secretMismatchCode,
        );
      });
      return;
    }

    setState(() {
      _submitting = true;
      _failure = null;
    });

    // The owner cannot be created before its role exists, so the built-in roles
    // are seeded first. The call is idempotent, so retrying after a failure
    // writes nothing twice.
    final Result<void> seeded = await ref.read(seedBuiltInRolesProvider)();
    if (!mounted) {
      return;
    }
    if (!seeded.isOk) {
      _failWith(seeded.failureOrNull);
      return;
    }

    final Result<User> created = await ref.read(initializeOwnerProvider)(
      username: _usernameController.text,
      secret: _secretController.text,
    );
    if (!mounted) {
      return;
    }

    final User? owner = created.valueOrNull;
    if (owner == null) {
      _failWith(created.failureOrNull);
      return;
    }

    // The operator is the owner now: open the session and refresh the account
    // list, so the router stops asking for a setup and lets the app be entered.
    ref.read(sessionProvider.notifier).signIn(owner);
    ref.invalidate(allUsersProvider);

    setState(() => _submitting = false);
    widget.onInitialised?.call();
  }

  /// Shows [failure] and wipes the secrets.
  ///
  /// The secrets are cleared because this screen may be handed to the next
  /// person; leaving a typed password on a shared terminal is the worse option.
  void _failWith(Failure? failure) {
    setState(() {
      _submitting = false;
      _failure = failure;
    });
    _secretController.clear();
    _confirmController.clear();
    _secretFocus.requestFocus();
  }

  /// The already-localised explanation for [failure].
  String _messageFor(Failure? failure, AppLocalizations l10n) =>
      switch (failure?.code) {
        InitializeOwner.usernameRequiredCode => l10n.ownerSetupUsernameRequired,
        InitializeOwner.usernameInvalidCode => l10n.ownerSetupUsernameInvalid,
        InitializeOwner.secretRequiredCode => l10n.ownerSetupSecretRequired,
        InitializeOwner.secretTooShortCode => l10n.ownerSetupSecretTooShort,
        InitializeOwner.alreadyInitialisedCode =>
          l10n.ownerSetupAlreadyInitialised,
        _secretMismatchCode => l10n.ownerSetupSecretMismatch,
        _ => l10n.ownerSetupFailed,
      };

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = context.l10n;
    final ThemeData theme = Theme.of(context);
    final ColorScheme scheme = theme.colorScheme;
    final bool isCompact =
        windowSizeFor(MediaQuery.sizeOf(context).width) == WindowSize.compact;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(isCompact ? AppSpacing.lg : AppSpacing.xxl),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: CustomCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Icon(
                      Icons.person_add_alt_1_outlined,
                      size: AppSizes.iconXl,
                      color: scheme.primary,
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    Text(
                      l10n.ownerSetupTitle,
                      textAlign: TextAlign.center,
                      style: theme.textTheme.headlineSmall,
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      l10n.ownerSetupSubtitle,
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    CustomTextField(
                      controller: _usernameController,
                      label: l10n.ownerSetupUsernameLabel,
                      helperText: l10n.ownerSetupUsernameHelper,
                      prefixIcon: Icons.person_outline,
                      textInputAction: TextInputAction.next,
                      autofocus: true,
                      enabled: !_submitting,
                      onSubmitted: (_) => _secretFocus.requestFocus(),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    CustomTextField(
                      controller: _secretController,
                      focusNode: _secretFocus,
                      label: l10n.ownerSetupSecretLabel,
                      helperText: l10n.ownerSetupSecretHelper,
                      prefixIcon: Icons.password_outlined,
                      obscureText: true,
                      obscureToggleTooltip: l10n.loginSecretToggleTooltip,
                      textInputAction: TextInputAction.next,
                      enabled: !_submitting,
                      onSubmitted: (_) => _confirmFocus.requestFocus(),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    CustomTextField(
                      controller: _confirmController,
                      focusNode: _confirmFocus,
                      label: l10n.ownerSetupConfirmLabel,
                      prefixIcon: Icons.lock_outline,
                      obscureText: true,
                      obscureToggleTooltip: l10n.loginSecretToggleTooltip,
                      textInputAction: TextInputAction.done,
                      enabled: !_submitting,
                      onSubmitted: (_) => _submit(),
                    ),
                    if (_failure != null) ...<Widget>[
                      const SizedBox(height: AppSpacing.lg),
                      ErrorBanner(message: _messageFor(_failure, l10n)),
                    ],
                    const SizedBox(height: AppSpacing.xl),
                    CustomButton(
                      label: l10n.ownerSetupSubmit,
                      icon: Icons.arrow_forward,
                      isLoading: _submitting,
                      isExpanded: true,
                      onPressed: _submit,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
