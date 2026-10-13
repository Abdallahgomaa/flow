import 'package:flow/core/result/failure.dart';
import 'package:flow/core/result/result.dart';
import 'package:flow/features/auth/data/auth_providers.dart';
import 'package:flow/features/auth/data/session_notifier.dart';
import 'package:flow/features/auth/domain/use_cases/sign_in.dart';
import 'package:flow/features/auth/domain/user.dart';
import 'package:flow/shared/design/design.dart';
import 'package:flow/shared/l10n/l10n.dart';
import 'package:flow/shared/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// The sign-in screen (`P1-05`).
///
/// It is the way back into the app for a returning operator: one login name and
/// one secret, verified by [SignIn] — never by comparing secrets in the widget.
///
/// The screen owns a [Scaffold] of its own because it is shown outside the
/// adaptive shell. Leaving it is the caller's job: [onSignedIn] is invoked once
/// the session has started, so the presentation layer never has to know about
/// routes. The temporary `/login` route wires that up today and `P1-09` will
/// replace it with the real redirect guard.
class LoginScreen extends ConsumerStatefulWidget {
  /// Creates the sign-in screen.
  const LoginScreen({this.onSignedIn, super.key});

  /// Called after the session has started, so the caller can navigate away.
  final VoidCallback? onSignedIn;

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _secretController = TextEditingController();
  final FocusNode _secretFocus = FocusNode();

  /// Whether a verification is in flight; blocks a second submission.
  bool _submitting = false;

  /// The last failure, or `null` while the form is clean.
  Failure? _failure;

  @override
  void dispose() {
    _usernameController.dispose();
    _secretController.dispose();
    _secretFocus.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_submitting) {
      return;
    }
    setState(() {
      _submitting = true;
      _failure = null;
    });

    final Result<User> result = await ref.read(signInProvider)(
      username: _usernameController.text,
      secret: _secretController.text,
    );
    if (!mounted) {
      return;
    }

    final User? user = result.valueOrNull;
    if (user == null) {
      _failWith(result.failureOrNull);
      return;
    }

    // The session is started exactly as `P1-04` defines it, and its answer is
    // honoured rather than assumed: it refuses a disabled account on its own, so
    // the screen stays a thin layer over the rule.
    final Result<void> signedIn = ref
        .read(sessionProvider.notifier)
        .signIn(user);
    if (!mounted) {
      return;
    }
    if (!signedIn.isOk) {
      _failWith(signedIn.failureOrNull);
      return;
    }

    setState(() => _submitting = false);
    widget.onSignedIn?.call();
  }

  /// Shows [failure] and empties the secret field.
  ///
  /// The secret is dropped on purpose: Flow runs on shared terminals, so the
  /// next operator must not find the previous one's password still in the form.
  void _failWith(Failure? failure) {
    _secretController.clear();
    setState(() {
      _submitting = false;
      _failure = failure;
    });
    _secretFocus.requestFocus();
  }

  /// Turns a [Failure] into the message the operator reads.
  String _messageFor(Failure? failure, AppLocalizations l10n) {
    if (failure == null) {
      return l10n.loginFailed;
    }

    return switch (failure.code) {
      SignIn.usernameRequiredCode => l10n.loginUsernameRequired,
      SignIn.secretRequiredCode => l10n.loginSecretRequired,
      SignIn.invalidCredentialsCode => l10n.loginInvalidCredentials,
      SignIn.accountDisabledCode ||
      Session.disabledAccountCode => l10n.loginAccountDisabled,
      _ => l10n.loginFailed,
    };
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    final TextTheme textTheme = Theme.of(context).textTheme;
    final AppLocalizations l10n = context.l10n;
    final bool isCompact =
        windowSizeFor(MediaQuery.sizeOf(context).width) == WindowSize.compact;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            // The form keeps one comfortable width and only the breathing room
            // around it changes, so the layout is identical on a phone terminal
            // and on a desktop counter.
            padding: EdgeInsets.all(isCompact ? AppSpacing.lg : AppSpacing.xxl),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: CustomCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Center(
                      child: Icon(
                        Icons.lock_outline,
                        size: AppSizes.iconXl,
                        color: scheme.primary,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Text(
                      l10n.loginTitle,
                      style: textTheme.headlineSmall,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      l10n.loginSubtitle,
                      style: textTheme.bodyMedium?.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    CustomTextField(
                      controller: _usernameController,
                      label: l10n.loginUsernameLabel,
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
                      label: l10n.loginSecretLabel,
                      helperText: l10n.loginSecretHelper,
                      prefixIcon: Icons.password_outlined,
                      obscureText: true,
                      obscureToggleTooltip: l10n.loginSecretToggleTooltip,
                      textInputAction: TextInputAction.done,
                      enabled: !_submitting,
                      onSubmitted: (_) => _submit(),
                    ),
                    if (_failure != null) ...<Widget>[
                      const SizedBox(height: AppSpacing.lg),
                      _ErrorBanner(message: _messageFor(_failure, l10n)),
                    ],
                    const SizedBox(height: AppSpacing.xl),
                    CustomButton(
                      label: l10n.loginSubmit,
                      icon: Icons.login,
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

/// The inline strip that explains why the last attempt failed.
class _ErrorBanner extends StatelessWidget {
  const _ErrorBanner({required this.message});

  /// Already-localised explanation.
  final String message;

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: scheme.errorContainer,
        borderRadius: AppRadius.input,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Icon(
            Icons.error_outline,
            size: AppSizes.iconMd,
            color: scheme.onErrorContainer,
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              message,
              style: Theme.of(context).textTheme.bodyMedium
                  ?.copyWith(color: scheme.onErrorContainer),
            ),
          ),
        ],
      ),
    );
  }
}
