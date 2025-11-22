// lib/screens/admin/kamar/kamar_form_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../config/theme.dart';
import '../../../models/kamar_model.dart';
import '../../../providers/kamar_provider.dart';
import '../../../providers/user_provider.dart';
import '../../../utils/helpers.dart';
import '../../../widgets/custom_button.dart';
import '../../../widgets/custom_textfield.dart';

class KamarFormScreen extends StatefulWidget {
  final Kamar? kamar;

  const KamarFormScreen({super.key, this.kamar});

  @override
  State<KamarFormScreen> createState() => _KamarFormScreenState();
}

class _KamarFormScreenState extends State<KamarFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nomorKamarController = TextEditingController();
  final _hargaController = TextEditingController();
  final _fasilitasController = TextEditingController();

  String _selectedTipe = 'single';
  String _selectedStatus = 'tersedia';
  int? _selectedUserId;

  bool get isEdit => widget.kamar != null;

  @override
  void initState() {
    super.initState();
    if (isEdit) {
      _nomorKamarController.text = widget.kamar!.nomorKamar;
      _hargaController.text = widget.kamar!.hargaBulanan.toString();
      _fasilitasController.text = widget.kamar!.fasilitas ?? '';
      _selectedTipe = widget.kamar!.tipe;
      _selectedStatus = widget.kamar!.status;
      _selectedUserId = widget.kamar!.userId;
    }
    _loadUsers();
  }

  Future<void> _loadUsers() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    await userProvider.fetchUsers();
  }

  @override
  void dispose() {
    _nomorKamarController.dispose();
    _hargaController.dispose();
    _fasilitasController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    final kamarProvider = Provider.of<KamarProvider>(context, listen: false);

    bool success;
    if (isEdit) {
      success = await kamarProvider.updateKamar(
        id: widget.kamar!.id,
        nomorKamar: _nomorKamarController.text,
        tipe: _selectedTipe,
        hargaBulanan: double.parse(_hargaController.text),
        status: _selectedStatus,
        fasilitas: _fasilitasController.text.isEmpty
            ? null
            : _fasilitasController.text,
        userId: _selectedStatus == 'terisi' ? _selectedUserId : null,
      );
    } else {
      success = await kamarProvider.createKamar(
        nomorKamar: _nomorKamarController.text,
        tipe: _selectedTipe,
        hargaBulanan: double.parse(_hargaController.text),
        status: _selectedStatus,
        fasilitas: _fasilitasController.text.isEmpty
            ? null
            : _fasilitasController.text,
        userId: _selectedStatus == 'terisi' ? _selectedUserId : null,
      );
    }

    if (!mounted) return;

    if (success) {
      Helpers.showSnackBar(
        context,
        isEdit ? 'Kamar berhasil diupdate' : 'Kamar berhasil ditambahkan',
      );
      Navigator.of(context).pop(true);
    } else {
      Helpers.showSnackBar(
        context,
        kamarProvider.errorMessage ??
            (isEdit ? 'Gagal update kamar' : 'Gagal menambah kamar'),
        isError: true,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(isEdit ? 'Edit Kamar' : 'Tambah Kamar'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(AppTheme.spaceMD),
          children: [
            CustomTextField(
              label: 'Nomor Kamar',
              hint: 'Contoh: A01, B02',
              controller: _nomorKamarController,
              prefixIcon: Icons.door_front_door,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Nomor kamar tidak boleh kosong';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Tipe Kamar',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: RadioListTile<String>(
                        title: const Text('Single'),
                        value: 'single',
                        groupValue: _selectedTipe,
                        onChanged: (value) {
                          setState(() {
                            _selectedTipe = value!;
                          });
                        },
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                    Expanded(
                      child: RadioListTile<String>(
                        title: const Text('Double'),
                        value: 'double',
                        groupValue: _selectedTipe,
                        onChanged: (value) {
                          setState(() {
                            _selectedTipe = value!;
                          });
                        },
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            CustomTextField(
              label: 'Harga Bulanan',
              hint: 'Contoh: 800000',
              controller: _hargaController,
              keyboardType: TextInputType.number,
              prefixIcon: Icons.attach_money,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Harga tidak boleh kosong';
                }
                if (double.tryParse(value) == null) {
                  return 'Harga harus berupa angka';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Status',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: RadioListTile<String>(
                        title: const Text('Tersedia'),
                        value: 'tersedia',
                        groupValue: _selectedStatus,
                        onChanged: (value) {
                          setState(() {
                            _selectedStatus = value!;
                            _selectedUserId = null;
                          });
                        },
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                    Expanded(
                      child: RadioListTile<String>(
                        title: const Text('Terisi'),
                        value: 'terisi',
                        groupValue: _selectedStatus,
                        onChanged: (value) {
                          setState(() {
                            _selectedStatus = value!;
                          });
                        },
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            if (_selectedStatus == 'terisi') ...[
              const SizedBox(height: 16),
              Consumer<UserProvider>(
                builder: (context, userProvider, _) {
                  if (userProvider.isLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Pilih Penyewa',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<int>(
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.white,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: AppTheme.spaceMD,
                            vertical: AppTheme.spaceMD,
                          ),
                          border: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.circular(AppTheme.radiusMD),
                          ),
                        ),
                        hint: const Text('Pilih penyewa'),
                        value: _selectedUserId,
                        items: userProvider.users.map((user) {
                          return DropdownMenuItem<int>(
                            value: user.id,
                            child: Text(user.nama),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedUserId = value;
                          });
                        },
                        validator: (value) {
                          if (_selectedStatus == 'terisi' && value == null) {
                            return 'Pilih penyewa untuk kamar terisi';
                          }
                          return null;
                        },
                      ),
                    ],
                  );
                },
              ),
            ],
            const SizedBox(height: 16),
            CustomTextField(
              label: 'Fasilitas (Opsional)',
              hint: 'Contoh: AC, WiFi, Kamar Mandi Dalam',
              controller: _fasilitasController,
              prefixIcon: Icons.check_circle_outline,
              maxLines: 3,
            ),
            const SizedBox(height: 32),
            Consumer<KamarProvider>(
              builder: (context, kamarProvider, _) {
                return CustomButton(
                  text: isEdit ? 'Update Kamar' : 'Simpan Kamar',
                  onPressed: _handleSubmit,
                  isLoading: kamarProvider.isLoading,
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