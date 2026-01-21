import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/l10n/app_localizations.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../core/theme/app_theme.dart';
import '../data/reports_repository.dart';

class ReportsScreen extends ConsumerStatefulWidget {
  const ReportsScreen({super.key});

  @override
  ConsumerState<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends ConsumerState<ReportsScreen> {
  final _formKey = GlobalKey<FormState>();
  final _reasonController = TextEditingController();
  final _itemIdController = TextEditingController();
  final _nameController = TextEditingController();
  final _companyController = TextEditingController();
  final _sourceController = TextEditingController();
  bool _isSubmitting = false;
  String? _submitError;

  @override
  void dispose() {
    _reasonController.dispose();
    _itemIdController.dispose();
    _nameController.dispose();
    _companyController.dispose();
    _sourceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final authState = ref.watch(authProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.reports),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (!authState.isLoggedIn)
            _LoginPrompt(l10n: l10n)
          else
            _buildForm(context),
        ],
      ),
    );
  }

  Widget _buildForm(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border, width: 0.5),
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.submitReport,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _reasonController,
              maxLines: 3,
              decoration: InputDecoration(labelText: l10n.reportReason),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return l10n.reportReasonRequired;
                }
                return null;
              },
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _itemIdController,
              decoration: InputDecoration(labelText: l10n.itemIdOptional),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _nameController,
              decoration: InputDecoration(labelText: l10n.itemNameOptional),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _companyController,
              decoration: InputDecoration(labelText: l10n.companyOptional),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _sourceController,
              textDirection: TextDirection.ltr,
              decoration: InputDecoration(labelText: l10n.sourceOptional),
            ),
            const SizedBox(height: 16),
            if (_submitError != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Text(
                  _submitError!,
                  style: const TextStyle(color: AppColors.avoid, fontSize: 13),
                ),
              ),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isSubmitting ? null : _submitReport,
                child: _isSubmitting
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : Text(l10n.submitReport),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _submitReport() async {
    final l10n = AppLocalizations.of(context)!;
    final authState = ref.read(authProvider);

    if (!authState.isLoggedIn) {
      setState(() => _submitError = l10n.loginRequired);
      return;
    }

    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isSubmitting = true;
      _submitError = null;
    });

    final payload = <String, dynamic>{
      'reason': _reasonController.text.trim(),
      if (_itemIdController.text.trim().isNotEmpty)
        'itemId': _itemIdController.text.trim(),
      if (_nameController.text.trim().isNotEmpty)
        'name': _nameController.text.trim(),
      if (_companyController.text.trim().isNotEmpty)
        'company': _companyController.text.trim(),
      if (_sourceController.text.trim().isNotEmpty)
        'sourceUrl': _sourceController.text.trim(),
    };

    try {
      final repository = ref.read(reportsRepositoryProvider);
      await repository.submitReport(payload);
      if (!mounted) return;
      _reasonController.clear();
      _itemIdController.clear();
      _nameController.clear();
      _companyController.clear();
      _sourceController.clear();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.reportSubmitted)),
      );
    } catch (error) {
      if (!mounted) return;
      setState(() => _submitError = _formatError(error, l10n));
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  String _formatError(Object error, AppLocalizations l10n) {
    if (error is DioException) {
      final response = error.response?.data;
      if (response is Map) {
        final errorMap = response['error'];
        if (errorMap is Map && errorMap['message'] != null) {
          return errorMap['message'].toString();
        }
      }
      return error.message ?? l10n.error;
    }
    return error.toString();
  }
}

class _LoginPrompt extends StatelessWidget {
  final AppLocalizations l10n;

  const _LoginPrompt({required this.l10n});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border, width: 0.5),
      ),
      child: Column(
        children: [
          Text(
            l10n.loginRequired,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: () => context.push('/login'),
                child: Text(l10n.login),
              ),
              const SizedBox(width: 12),
              OutlinedButton(
                onPressed: () => context.push('/register'),
                child: Text(l10n.register),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
