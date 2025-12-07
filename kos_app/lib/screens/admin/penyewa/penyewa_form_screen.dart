import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../config/theme.dart';
import '../../../models/user_model.dart';
import '../../../providers/user_provider.dart';
import '../../../utils/helpers.dart';
import '../../../widgets/custom_button.dart';
import '../../../widgets/custom_textfield.dart';

class PenyewaFormScreen extends StatefulWidget {
  final User? user;

  const PenyewaFormScreen({super.key, this.user});

  @override
  State<PenyewaFormScreen> createState() => _PenyewaFormScreenState();
}

class _PenyewaFormScreenState extends State<PenyewaFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _namaController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _noTeleponController = TextEditingController();
  bool _obscurePassword = true;

  bool get isEdit => widget.user != null;

  @override
  void initState() {
    super.initState();
    if (isEdit) {
      _namaController.text = widget.user!.nama;
      _emailController.text = widget.user!.email;
      _noTeleponController.text = widget.user!.noTelepon ?? '';
    }
  }

  @override
  void dispose() {
    _namaController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _noTeleponController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    final userProvider = Provider.of<UserProvider>(context, listen: false);

    bool success;
    if (isEdit) {
      success = await userProvider.updateUser(
        id: widget.user!.id,
        nama: _namaController.text,
        email: _emailController.text,
        password: _passwordController.text.isEmpty
            ? null
            : _passwordController.text,
        noTelepon: _noTeleponController.text.isEmpty
            ? null
            : _noTeleponController.text,
      );
    } else {
      success = await userProvider.createUser(
        nama: _namaController.text,
        email: _emailController.text,
        password: _passwordController.text,
        noTelepon: _noTeleponController.text.isEmpty
            ? null
            : _noTeleponController.text,
      );
    }

    if (!mounted) return;

    if (success) {
      Helpers.showSnackBar(
        context,
        isEdit ? 'Penyewa berhasil diupdate' : 'Penyewa berhasil ditambahkan',
      );
      Navigator.of(context).pop(true);
    } else {
      Helpers.showSnackBar(
        context,
        userProvider.errorMessage ??
            (isEdit ? 'Gagal update penyewa' : 'Gagal menambah penyewa'),
        isError: true,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(isEdit ? 'Edit Penyewa' : 'Tambah Penyewa'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(AppTheme.spaceMD),
          children: [
            CustomTextField(
              label: 'Nama Lengkap',
              hint: 'Masukkan nama lengkap',
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
            CustomTextField(
              label: 'Email',
              hint: 'Masukkan email',
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              prefixIcon: Icons.email,
              enabled: !isEdit, // Email tidak bisa diubah saat edit
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Email tidak boleh kosong';
                }
                if (!value.contains('@')) {
                  return 'Email tidak valid';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            CustomTextField(
              label: isEdit ? 'Password Baru (Opsional)' : 'Password',
              hint: isEdit
                  ? 'Kosongkan jika tidak ingin ubah password'
                  : 'Masukkan password',
              controller: _passwordController,
              obscureText: _obscurePassword,
              prefixIcon: Icons.lock,
              suffixIcon: IconButton(
                icon: Icon(
                  _obscurePassword
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                ),
                onPressed: () {
                  setState(() {
                    _obscurePassword = !_obscurePassword;
                  });
                },
              ),
              validator: (value) {
                if (!isEdit && (value == null || value.isEmpty)) {
                  return 'Password tidak boleh kosong';
                }
                if (value != null &&
                    value.isNotEmpty &&
                    value.length < 6) {
                  return 'Password minimal 6 karakter';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            CustomTextField(
              label: 'No Telepon (Opsional)',
              hint: 'Contoh: 081234567890',
              controller: _noTeleponController,
              keyboardType: TextInputType.phone,
              prefixIcon: Icons.phone,
            ),
            const SizedBox(height: 32),
            Consumer<UserProvider>(
              builder: (context, userProvider, _) {
                return CustomButton(
                  text: isEdit ? 'Update Penyewa' : 'Simpan Penyewa',
                  onPressed: _handleSubmit,
                  isLoading: userProvider.isLoading,
                );
              },
            ),
            const SizedBox(height: 16),
            CustomButton(
              text: 'Batal',
              onPressed: () => Navigator.of(context).pop(),
              isOutlined: true,
            ),
          ],
        ),
      ),
    );
  }
}