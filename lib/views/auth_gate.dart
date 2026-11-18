import 'package:flutter/material.dart';

import '../services/auth_api.dart';
import '../viewmodels/auth_view_model.dart';
import 'dashboard_view.dart';

class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  late final AuthViewModel _viewModel;
  bool _createAccount = false;

  @override
  void initState() {
    super.initState();
    _viewModel = AuthViewModel(AuthApi());
  }

  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _viewModel,
      builder: (context, _) {
        if (_viewModel.isAuthenticated) {
          return DashboardShell(
            userName: _viewModel.user?.name ?? '',
            accessToken: _viewModel.token!,
            onLogout: _viewModel.signOut,
          );
        }

        return AuthPage(
          createAccount: _createAccount,
          isLoading: _viewModel.isLoading,
          errorMessage: _viewModel.errorMessage,
          onModeChanged: () {
            setState(() => _createAccount = !_createAccount);
            _viewModel.clearError();
          },
          onSubmit: (name, email, password) => _viewModel.submit(
            createAccount: _createAccount,
            name: name,
            email: email,
            password: password,
          ),
        );
      },
    );
  }
}

class AuthPage extends StatefulWidget {
  const AuthPage({
    required this.createAccount,
    required this.isLoading,
    required this.errorMessage,
    required this.onModeChanged,
    required this.onSubmit,
    super.key,
  });

  final bool createAccount;
  final bool isLoading;
  final String? errorMessage;
  final VoidCallback onModeChanged;
  final Future<void> Function(String name, String email, String password) onSubmit;

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
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

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (widget.createAccount &&
        _passwordController.text != _confirmController.text) {
      return;
    }
    await widget.onSubmit(
      _nameController.text,
      _emailController.text,
      _passwordController.text,
    );
  }

  @override
  Widget build(BuildContext context) {
    final createAccount = widget.createAccount;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 440),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const CircleAvatar(
                      radius: 34,
                      backgroundColor: Color(0xFFE1EEE5),
                      child: Icon(
                        Icons.recycling,
                        color: Color(0xFF216A4B),
                        size: 34,
                      ),
                    ),
                    const SizedBox(height: 22),
                    Text(
                      createAccount ? 'Join Smart Waste' : 'Welcome back',
                      style: textTheme.headlineMedium?.copyWith(
                        color: const Color(0xFF173B2B),
                        fontWeight: FontWeight.w800,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      createAccount
                          ? 'Create an account to report issues and track your activity.'
                          : 'Sign in to find local recycling help and manage your reports.',
                      style: textTheme.bodyLarge?.copyWith(
                        color: const Color(0xFF627168),
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 28),
                    if (createAccount) ...[
                      TextFormField(
                        controller: _nameController,
                        textCapitalization: TextCapitalization.words,
                        autofillHints: const [AutofillHints.name],
                        decoration: const InputDecoration(
                          labelText: 'Name',
                          prefixIcon: Icon(Icons.person_outline),
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          final name = value?.trim() ?? '';
                          return name.length < 2
                              ? 'Enter your name.'
                              : null;
                        },
                      ),
                      const SizedBox(height: 14),
                    ],
                    TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      autofillHints: const [AutofillHints.email],
                      decoration: const InputDecoration(
                        labelText: 'Email',
                        prefixIcon: Icon(Icons.email_outlined),
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        final email = value?.trim() ?? '';
                        return email.contains('@') && email.contains('.')
                            ? null
                            : 'Enter a valid email address.';
                      },
                    ),
                    const SizedBox(height: 14),
                    TextFormField(
                      controller: _passwordController,
                      obscureText: true,
                      autofillHints: [
                        createAccount
                            ? AutofillHints.newPassword
                            : AutofillHints.password,
                      ],
                      decoration: const InputDecoration(
                        labelText: 'Password',
                        prefixIcon: Icon(Icons.lock_outline),
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        final password = value ?? '';
                        if (password.isEmpty) return 'Enter your password.';
                        if (createAccount && password.length < 12) {
                          return 'Use at least 12 characters.';
                        }
                        return null;
                      },
                    ),
                    if (createAccount) ...[
                      const SizedBox(height: 14),
                      TextFormField(
                        controller: _confirmController,
                        obscureText: true,
                        decoration: const InputDecoration(
                          labelText: 'Confirm password',
                          prefixIcon: Icon(Icons.lock_reset_outlined),
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) => value == _passwordController.text
                            ? null
                            : 'Passwords do not match.',
                      ),
                    ],
                    if (widget.errorMessage != null) ...[
                      const SizedBox(height: 14),
                      Text(
                        widget.errorMessage!,
                        style: const TextStyle(color: Color(0xFFB3261E)),
                        textAlign: TextAlign.center,
                      ),
                    ],
                    const SizedBox(height: 20),
                    FilledButton(
                      onPressed: widget.isLoading ? null : _submit,
                      style: FilledButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 15),
                      ),
                      child: widget.isLoading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                              ),
                            )
                          : Text(createAccount ? 'Create account' : 'Sign in'),
                    ),
                    const SizedBox(height: 8),
                    TextButton(
                      onPressed: widget.isLoading ? null : widget.onModeChanged,
                      child: Text(
                        createAccount
                            ? 'Already have an account? Sign in'
                            : 'New here? Create an account',
                      ),
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
