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
  int? _selectedUserId1; // For single or first occupant in double
  int? _selectedUserId2; // For second occupant in double room

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
      _selectedUserId1 = widget.kamar!.userId;
    }
    _loadData();
  }

  Future<void> _loadData() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final kamarProvider = Provider.of<KamarProvider>(context, listen: false);
    await userProvider.fetchUsers();
    await kamarProvider.fetchKamars();
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

    // Determine which userId to use based on room type
    int? userIdToSubmit;
    if (_selectedStatus == 'terisi') {
      userIdToSubmit = _selectedTipe == 'single'
          ? _selectedUserId1
          : _selectedUserId1;
    }

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
        userId: userIdToSubmit,
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
        userId: userIdToSubmit,
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
      appBar: AppBar(title: Text(isEdit ? 'Edit Kamar' : 'Tambah Kamar')),
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
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
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
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
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
                            _selectedUserId1 = null;
                            _selectedUserId2 = null;
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
              Consumer2<UserProvider, KamarProvider>(
                builder: (context, userProvider, kamarProvider, _) {
                  if (userProvider.isLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  // Filter: hanya tampilkan penyewa yang belum memiliki kamar
                  final occupiedUserIds = kamarProvider.kamars
                      .where((kamar) => kamar.userId != null)
                      .map((kamar) => kamar.userId)
                      .toSet();

                  // Jika sedang edit, tambahkan user saat ini ke available list
                  if (isEdit && widget.kamar!.userId != null) {
                    occupiedUserIds.remove(widget.kamar!.userId);
                  }

                  final availableUsers = userProvider.users
                      .where((user) => !occupiedUserIds.contains(user.id))
                      .toList();

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Dropdown 1 - untuk single atau occupant pertama double
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _selectedTipe == 'double'
                                ? 'Pilih Penyewa 1'
                                : 'Pilih Penyewa',
                            style: const TextStyle(
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
                                borderRadius: BorderRadius.circular(
                                  AppTheme.radiusMD,
                                ),
                              ),
                            ),
                            hint: const Text('Pilih penyewa'),
                            value: _selectedUserId1,
                            items: availableUsers.map((user) {
                              return DropdownMenuItem<int>(
                                value: user.id,
                                child: Text(user.nama),
                              );
                            }).toList(),
                            onChanged: (value) {
                              setState(() {
                                _selectedUserId1 = value;
                              });
                            },
                            validator: (value) {
                              if (_selectedStatus == 'terisi' &&
                                  value == null) {
                                return 'Pilih penyewa untuk kamar terisi';
                              }
                              return null;
                            },
                          ),
                        ],
                      ),
                      // Dropdown 2 - untuk occupant kedua double room
                      if (_selectedTipe == 'double') ...[
                        const SizedBox(height: 16),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Pilih Penyewa 2',
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
                                  borderRadius: BorderRadius.circular(
                                    AppTheme.radiusMD,
                                  ),
                                ),
                              ),
                              hint: const Text('Pilih penyewa 2'),
                              value: _selectedUserId2,
                              items: availableUsers
                                  .where(
                                    (user) => user.id != _selectedUserId1,
                                  ) // Exclude selected user 1
                                  .map((user) {
                                    return DropdownMenuItem<int>(
                                      value: user.id,
                                      child: Text(user.nama),
                                    );
                                  })
                                  .toList(),
                              onChanged: (value) {
                                setState(() {
                                  _selectedUserId2 = value;
                                });
                              },
                              validator: (value) {
                                if (_selectedStatus == 'terisi' &&
                                    _selectedTipe == 'double' &&
                                    value == null) {
                                  return 'Pilih penyewa 2 untuk kamar double';
                                }
                                return null;
                              },
                            ),
                          ],
                        ),
                      ],
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
