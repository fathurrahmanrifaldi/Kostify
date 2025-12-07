import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import '../../providers/auth_provider.dart';
import '../../utils/helpers.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_textfield.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _oldPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _obscureOldPassword = true;
  bool _obscureNewPassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void dispose() {
    _oldPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final success = await authProvider.changePassword(
      oldPassword: _oldPasswordController.text,
      newPassword: _newPasswordController.text,
    );

    if (!mounted) return;

    if (success) {
      Helpers.showSnackBar(context, 'Password berhasil diubah');
      Navigator.pop(context);
    } else {
      Helpers.showSnackBar(
        context,
        authProvider.errorMessage ?? 'Gagal ubah password',
        isError: true,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Ubah Password')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(AppTheme.spaceMD),
          children: [
            // Info Card
            Container(
              padding: const EdgeInsets.all(AppTheme.spaceMD),
              decoration: BoxDecoration(
                color: AppTheme.infoColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(AppTheme.radiusMD),
                border: Border.all(color: AppTheme.infoColor.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: AppTheme.infoColor),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Password minimal 6 karakter',
                      style: TextStyle(fontSize: 13, color: AppTheme.infoColor),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            CustomTextField(
              label: 'Password Lama',
              controller: _oldPasswordController,
              obscureText: _obscureOldPassword,
              prefixIcon: Icons.lock_outline,
              suffixIcon: IconButton(
                icon: Icon(
                  _obscureOldPassword
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                ),
                onPressed: () {
                  setState(() {
                    _obscureOldPassword = !_obscureOldPassword;
                  });
                },
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Password lama tidak boleh kosong';
                }
                return null;
              },
            ),

            const SizedBox(height: 16),

            CustomTextField(
              label: 'Password Baru',
              controller: _newPasswordController,
              obscureText: _obscureNewPassword,
              prefixIcon: Icons.lock,
              suffixIcon: IconButton(
                icon: Icon(
                  _obscureNewPassword
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                ),
                onPressed: () {
                  setState(() {
                    _obscureNewPassword = !_obscureNewPassword;
                  });
                },
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Password baru tidak boleh kosong';
                }
                if (value.length < 6) {
                  return 'Password minimal 6 karakter';
                }
                if (value == _oldPasswordController.text) {
                  return 'Password baru harus berbeda dari password lama';
                }
                return null;
              },
            ),

            const SizedBox(height: 16),

            CustomTextField(
              label: 'Konfirmasi Password Baru',
              controller: _confirmPasswordController,
              obscureText: _obscureConfirmPassword,
              prefixIcon: Icons.lock,
              suffixIcon: IconButton(
                icon: Icon(
                  _obscureConfirmPassword
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                ),
                onPressed: () {
                  setState(() {
                    _obscureConfirmPassword = !_obscureConfirmPassword;
                  });
                },
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Konfirmasi password tidak boleh kosong';
                }
                if (value != _newPasswordController.text) {
                  return 'Password tidak cocok';
                }
                return null;
              },
            ),

            const SizedBox(height: 32),

            Consumer<AuthProvider>(
              builder: (context, authProvider, _) {
                return CustomButton(
                  text: 'Ubah Password',
                  onPressed: _handleSubmit,
                  isLoading: authProvider.isLoading,
                );
              },
            ),

            const SizedBox(height: 16),

            CustomButton(
              text: 'Batal',
              onPressed: () => Navigator.pop(context),
              isOutlined: true,
            ),
          ],
        ),
      ),
    );
  }
}
