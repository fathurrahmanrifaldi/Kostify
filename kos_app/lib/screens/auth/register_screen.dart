import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_textfield.dart';
import '../../utils/helpers.dart';
import 'login_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _namaController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  final _noTelpController = TextEditingController();

  bool _obscure = true;

  @override
  void dispose() {
    _namaController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    _noTelpController.dispose();
    super.dispose();
  }

  Future<void> _handleRegister() async {
    if (!_formKey.currentState!.validate()) return;

    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    final success = await authProvider.register(
      nama: _namaController.text.trim(),
      email: _emailController.text.trim(),
      password: _passwordController.text,
      role: 'admin',
      noTelepon: _noTelpController.text.isEmpty
          ? null
          : _noTelpController.text.trim(),
    );

    if (!mounted) return;

    if (success) {
      Helpers.showSnackBar(
        context,
        'Registrasi berhasil! Silahkan login dengan akun Anda.',
      );
      // Arahkan ke Login Screen
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const LoginScreen()),
        (route) => false,
      );
    } else {
      Helpers.showSnackBar(
        context,
        authProvider.errorMessage ?? 'Registrasi gagal',
        isError: true,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Register')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppTheme.spaceMD),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                CustomTextField(
                  label: 'Nama',
                  hint: 'Nama lengkap',
                  controller: _namaController,
                  prefixIcon: Icons.person,
                  validator: (v) => (v == null || v.isEmpty)
                      ? 'Nama tidak boleh kosong'
                      : null,
                ),
                const SizedBox(height: 12),
                CustomTextField(
                  label: 'Email',
                  hint: 'email@contoh.com',
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  prefixIcon: Icons.email_outlined,
                  validator: (v) {
                    if (v == null || v.isEmpty)
                      return 'Email tidak boleh kosong';
                    if (!v.contains('@')) return 'Email tidak valid';
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                CustomTextField(
                  label: 'Password',
                  hint: 'Minimal 6 karakter',
                  controller: _passwordController,
                  obscureText: _obscure,
                  prefixIcon: Icons.lock_outlined,
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscure
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                    ),
                    onPressed: () => setState(() => _obscure = !_obscure),
                  ),
                  validator: (v) {
                    if (v == null || v.isEmpty)
                      return 'Password tidak boleh kosong';
                    if (v.length < 6) return 'Password minimal 6 karakter';
                    return null;
                  },
                ),                
                const SizedBox(height: 12),
                CustomTextField(
                  label: 'No. Telepon (opsional)',
                  hint: '0812xxxx',
                  controller: _noTelpController,
                  keyboardType: TextInputType.phone,
                  prefixIcon: Icons.phone,
                ),
                const SizedBox(height: 20),
                Consumer<AuthProvider>(
                  builder: (context, authProvider, _) {
                    return CustomButton(
                      text: 'Register',
                      onPressed: _handleRegister,
                      isLoading: authProvider.isLoading,
                    );
                  },
                ),
                const SizedBox(height: 12),
                CustomButton(
                  text: 'Batal',
                  onPressed: () => Navigator.of(context).pop(),
                  isOutlined: true,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
