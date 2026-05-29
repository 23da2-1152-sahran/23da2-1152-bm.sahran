import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart' hide AuthProvider;
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../providers/auth_provider.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirm = true;
  bool _isLoading = false;

  String _nameError = '';
  String _emailError = '';
  String _passwordError = '';
  String _confirmError = '';

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _passCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  bool _isValidEmail(String email) {
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    return emailRegex.hasMatch(email);
  }

  bool _validate() {
    setState(() {
      _nameError = '';
      _emailError = '';
      _passwordError = '';
      _confirmError = '';

      final name = _nameCtrl.text.trim();
      final email = _emailCtrl.text.trim();
      final password = _passCtrl.text;
      final confirm = _confirmCtrl.text;

      if (name.isEmpty) _nameError = 'Full name is required';

      if (email.isEmpty) {
        _emailError = 'Email is required';
      } else if (!_isValidEmail(email)) {
        _emailError = 'Invalid email format';
      }

      if (password.isEmpty) {
        _passwordError = 'Password is required';
      } else if (password.length < 6) {
        _passwordError = 'Password must be at least 6 characters';
      }

      if (confirm.isEmpty) {
        _confirmError = 'Please confirm your password';
      } else if (password != confirm) {
        _confirmError = 'Passwords do not match';
      }
    });

    return _nameError.isEmpty &&
        _emailError.isEmpty &&
        _passwordError.isEmpty &&
        _confirmError.isEmpty;
  }

  void _handleRegister() async {
    if (!_validate()) return;

    setState(() => _isLoading = true);

    try {
      final ok = await context.read<AuthProvider>().register(
            _emailCtrl.text.trim(),
            _passCtrl.text,
            _nameCtrl.text.trim(),
          );

      if (ok && mounted) {
        Navigator.pushReplacementNamed(context, '/login');
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(context.read<AuthProvider>().error ??
                'Registration failed. Please try again.'),
          ),
        );
      }
    } on FirebaseAuthException catch (e) {
      if (mounted) {
        String message;
        switch (e.code) {
          case 'email-already-in-use':
            message = 'An account already exists for this email.';
            setState(() => _emailError = message);
            break;
          case 'invalid-email':
            message = 'The email address is not valid.';
            setState(() => _emailError = message);
            break;
          case 'weak-password':
            message = 'Password is too weak. Use at least 6 characters.';
            setState(() => _passwordError = message);
            break;
          case 'operation-not-allowed':
            message = 'Email/password sign-up is not enabled. Contact support.';
            ScaffoldMessenger.of(context)
                .showSnackBar(SnackBar(content: Text(message)));
            break;
          default:
            message = e.message ?? 'Registration failed. Please try again.';
            ScaffoldMessenger.of(context)
                .showSnackBar(SnackBar(content: Text(message)));
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Network or unknown error. Please try again.')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              const SizedBox(height: 48),
              const Text(
                'SENIOR',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 4,
                  color: AppTheme.textPrimary,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Create Account',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Join the editorial collective.',
                style: TextStyle(
                  fontSize: 13,
                  color: AppTheme.textSecondary,
                ),
              ),
              const SizedBox(height: 40),

              // Full Name
              _buildField(
                'FULL NAME',
                _nameCtrl,
                hint: 'Your full name',
                errorText: _nameError,
              ),
              const SizedBox(height: 20),

              // Email
              _buildField(
                'EMAIL ADDRESS',
                _emailCtrl,
                hint: 'your@email.com',
                type: TextInputType.emailAddress,
                errorText: _emailError,
              ),
              const SizedBox(height: 20),

              // Password
              _buildField(
                'PASSWORD',
                _passCtrl,
                hint: '••••••••',
                obscure: _obscurePassword,
                errorText: _passwordError,
                onToggleObscure: () =>
                    setState(() => _obscurePassword = !_obscurePassword),
              ),
              const SizedBox(height: 20),

              // Confirm Password
              _buildField(
                'CONFIRM PASSWORD',
                _confirmCtrl,
                hint: '••••••••',
                obscure: _obscureConfirm,
                errorText: _confirmError,
                onToggleObscure: () =>
                    setState(() => _obscureConfirm = !_obscureConfirm),
              ),
              const SizedBox(height: 32),

              // Create Account Button
              SizedBox(
                width: double.infinity,
                height: 60,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _handleRegister,
                  child: _isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text(
                          'CREATE ACCOUNT',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 2.0,
                            color: Colors.white,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 24),

              Row(
                children: [
                  Expanded(child: Container(height: 1, color: AppTheme.border)),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      'OR SIGN UP WITH',
                      style: TextStyle(
                        fontSize: 9,
                        letterSpacing: 1.5,
                        color: AppTheme.textMuted,
                      ),
                    ),
                  ),
                  Expanded(child: Container(height: 1, color: AppTheme.border)),
                ],
              ),
              const SizedBox(height: 24),

              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {},
                      icon: const Icon(Icons.g_mobiledata, size: 20),
                      label:
                          const Text('Google', style: TextStyle(fontSize: 13)),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {},
                      icon: const Icon(Icons.apple, size: 18),
                      label:
                          const Text('Apple', style: TextStyle(fontSize: 13)),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Already a member? ',
                    style:
                        TextStyle(fontSize: 13, color: AppTheme.textSecondary),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Text(
                      'Sign In',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textPrimary,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              const Text(
                'By creating an account you agree to our Terms of Service and Privacy Policy.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 10,
                  color: AppTheme.textMuted,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildField(
    String label,
    TextEditingController ctrl, {
    String? hint,
    bool obscure = false,
    TextInputType? type,
    String errorText = '',
    VoidCallback? onToggleObscure,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 9,
            fontWeight: FontWeight.w600,
            letterSpacing: 2.0,
            color: AppTheme.textSecondary,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: ctrl,
          obscureText: obscure,
          keyboardType: type,
          style: TextStyle(
            fontSize: 14,
            color: AppTheme.textPrimary,
            letterSpacing: obscure ? 4 : 0,
          ),
          decoration: InputDecoration(
            hintText: hint,
            errorText: errorText.isNotEmpty ? errorText : null,
            suffixIcon: onToggleObscure != null
                ? GestureDetector(
                    onTap: onToggleObscure,
                    child: Icon(
                      obscure
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                      size: 16,
                      color: AppTheme.textSecondary,
                    ),
                  )
                : null,
          ),
        ),
      ],
    );
  }
}
