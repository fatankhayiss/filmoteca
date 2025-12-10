// lib/pages/register_page.dart
import 'package:flutter/material.dart';
import '../services/auth_service.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final nameCtrl = TextEditingController();
  final emailCtrl = TextEditingController();
  final passCtrl = TextEditingController();
  bool _obscure = true;
  bool loading = false;

  Future<void> register() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => loading = true);

    try {
      final result = await AuthService.register(
        name: nameCtrl.text.trim(),
        email: emailCtrl.text.trim(),
        password: passCtrl.text.trim(),
      );

      if (result['statusCode'] == 200 || result['statusCode'] == 201) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Register berhasil')),
        );
        if (!context.mounted) return;
        Navigator.pop(context);
      } else {
        final msg = result['body']?['message']?.toString() ?? 'Register gagal';
        if (mounted) {
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text(msg)));
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('Network error')));
      }
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FB),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Card(
            elevation: 0,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 32),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: SingleChildScrollView(
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: SizedBox(
                          height: 140,
                          child: Image.asset('assets/icon.png'),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text('Create Account',
                          style: theme.textTheme.headlineSmall
                              ?.copyWith(fontWeight: FontWeight.w700)),
                      const SizedBox(height: 4),
                      Text('Sign up to get started',
                          style: theme.textTheme.bodyMedium
                              ?.copyWith(color: Colors.black54)),
                      const SizedBox(height: 20),

                      // NAME
                      _LabeledField(
                        label: 'Full Name',
                        child: TextFormField(
                          controller: nameCtrl,
                          validator: (v) => v!.isEmpty ? 'Name required' : null,
                          decoration: const InputDecoration(
                            prefixIcon: Icon(Icons.person_outline),
                            hintText: 'Enter your full name',
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),

                      // EMAIL
                      _LabeledField(
                        label: 'Email Address',
                        child: TextFormField(
                          controller: emailCtrl,
                          validator: (v) =>
                              v!.isEmpty ? 'Email required' : null,
                          decoration: const InputDecoration(
                            prefixIcon: Icon(Icons.email_outlined),
                            hintText: 'Enter your email address',
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),

                      // PASSWORD
                      _LabeledField(
                        label: 'Password',
                        child: TextFormField(
                          controller: passCtrl,
                          obscureText: _obscure,
                          validator: (v) =>
                              v!.length < 6 ? 'Minimum 6 characters' : null,
                          decoration: InputDecoration(
                            prefixIcon: const Icon(Icons.lock_outline),
                            suffixIcon: IconButton(
                              icon: Icon(_obscure
                                  ? Icons.visibility_off
                                  : Icons.visibility),
                              onPressed: () =>
                                  setState(() => _obscure = !_obscure),
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton(
                          onPressed: loading ? null : register,
                          child:
                              Text(loading ? 'Loading...' : 'Create Account'),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text('Already have an account?'),
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('Sign in'),
                          ),
                        ],
                      )
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _LabeledField extends StatelessWidget {
  final String label;
  final Widget child;
  const _LabeledField({required this.label, required this.child});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: Theme.of(context).textTheme.labelLarge),
        const SizedBox(height: 8),
        child,
      ],
    );
  }
}
