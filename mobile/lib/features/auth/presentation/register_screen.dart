import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/l10n/app_localizations.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../core/theme/app_theme.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  Future<void> _handleRegister() async {
    if (!_formKey.currentState!.validate()) return;

    await ref.read(authProvider.notifier).register(
          name: _nameController.text.trim(),
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );

    final authState = ref.read(authProvider);
    if (authState.isLoggedIn && mounted) {
      context.go('/');
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final authState = ref.watch(authProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.register)),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('🇵🇸', style: TextStyle(fontSize: 42)),
                  const SizedBox(width: 12),
                  Text(
                    l10n.appName,
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                l10n.createAccount,
                style: Theme.of(context).textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              if (authState.errorMessage != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Text(
                    authState.errorMessage!,
                    style: const TextStyle(color: AppColors.avoid),
                    textAlign: TextAlign.center,
                  ),
                ),
              Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      l10n.name,
                      style: Theme.of(context).textTheme.labelLarge,
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _nameController,
                      decoration: InputDecoration(
                        hintText: l10n.name,
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return l10n.validationNameRequired;
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    Text(
                      l10n.email,
                      style: Theme.of(context).textTheme.labelLarge,
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      textDirection: TextDirection.ltr,
                      decoration: const InputDecoration(
                        hintText: 'example@email.com',
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return l10n.validationEmailRequired;
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    Text(
                      l10n.password,
                      style: Theme.of(context).textTheme.labelLarge,
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _passwordController,
                      obscureText: true,
                      textDirection: TextDirection.ltr,
                      decoration: InputDecoration(
                        hintText: l10n.password,
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return l10n.validationPasswordRequired;
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    Text(
                      l10n.confirmPassword,
                      style: Theme.of(context).textTheme.labelLarge,
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _confirmController,
                      obscureText: true,
                      textDirection: TextDirection.ltr,
                      decoration: InputDecoration(
                        hintText: l10n.confirmPassword,
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return l10n.validationConfirmPasswordRequired;
                        }
                        if (value != _passwordController.text) {
                          return l10n.validationPasswordMismatch;
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: authState.isLoading ? null : _handleRegister,
                      child: authState.isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : Text(l10n.register),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(l10n.haveAccount),
                  TextButton(
                    onPressed: () => context.pop(),
                    child: Text(l10n.login),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
