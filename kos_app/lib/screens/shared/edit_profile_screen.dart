// lib/screens/shared/edit_profile_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import '../../providers/auth_provider.dart';
import '../../utils/helpers.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_textfield.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _namaController = TextEditingController();
  final _noTeleponController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final user = authProvider.user;
    
    if (user != null) {
      _namaController.text = user.nama;
      _noTeleponController.text = user.noTelepon ?? '';
    }
  }

  @override
  void dispose() {
    _namaController.dispose();
    _noTeleponController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    // TODO: Implement update profile API
    // For now just show success message
    Helpers.showSnackBar(context, 'Fitur update profile coming soon');
    
    // Uncomment when API ready:
    // final authProvider = Provider.of<AuthProvider>(context, listen: false);
    // final success = await authProvider.updateProfile(
    //   nama: _namaController.text,
    //   noTelepon: _noTeleponController.text,
    // );
    
    // if (success) {
    //   Helpers.showSnackBar(context, 'Profile berhasil diupdate');
    //   Navigator.pop(context);
    // } else {
    //   Helpers.showSnackBar(context, 'Gagal update profile', isError: true);
    // }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(AppTheme.spaceMD),
          children: [
            // Avatar
            Center(
              child: Stack(
                children: [
                  Consumer<AuthProvider>(
                    builder: (context, authProvider, _) {
                      return CircleAvatar(
                        radius: 60,
                        backgroundColor: AppTheme.primaryLight,
                        child: Text(
                          authProvider.user?.nama.substring(0, 1).toUpperCase() ?? 'U',
                          style: const TextStyle(
                            fontSize: 48,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.primaryColor,
                          ),
                        ),
                      );
                    },
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      decoration: BoxDecoration(
                        color: AppTheme.primaryColor,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.camera_alt, color: Colors.white, size: 20),
                        onPressed: () {
                          Helpers.showSnackBar(context, 'Upload foto coming soon');
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            CustomTextField(
              label: 'Nama Lengkap',
              controller: _namaController,
              prefixIcon: Icons.person,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Nama tidak boleh kosong';
                }
                return null;
              },
            ),

            const SizedBox(height: 16),

            Consumer<AuthProvider>(
              builder: (context, authProvider, _) {
                return CustomTextField(
                  label: 'Email',
                  controller: TextEditingController(text: authProvider.user?.email),
                  prefixIcon: Icons.email,
                  enabled: false,
                );
              },
            ),

            const SizedBox(height: 16),

            CustomTextField(
              label: 'No Telepon (Opsional)',
              controller: _noTeleponController,
              keyboardType: TextInputType.phone,
              prefixIcon: Icons.phone,
            ),

            const SizedBox(height: 32),

            CustomButton(
              text: 'Simpan Perubahan',
              onPressed: _handleSubmit,
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