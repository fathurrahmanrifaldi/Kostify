// lib/screens/admin/pembayaran/pembayaran_form_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../config/theme.dart';
import '../../../models/pembayaran_model.dart';
import '../../../providers/pembayaran_provider.dart';
import '../../../providers/kamar_provider.dart';
import '../../../utils/helpers.dart';
import '../../../widgets/custom_button.dart';

class PembayaranFormScreen extends StatefulWidget {
  final Pembayaran? pembayaran;

  const PembayaranFormScreen({super.key, this.pembayaran});

  @override
  State<PembayaranFormScreen> createState() => _PembayaranFormScreenState();
}

class _PembayaranFormScreenState extends State<PembayaranFormScreen> {
  final _formKey = GlobalKey<FormState>();
  
  int? _selectedKamarId;
  int? _selectedUserId;
  int _selectedBulan = DateTime.now().month;
  int _selectedTahun = DateTime.now().year;
  DateTime _selectedDate = DateTime.now();
  double? _jumlah;
  String _selectedStatus = 'lunas';

  bool get isEdit => widget.pembayaran != null;

  @override
  void initState() {
    super.initState();
    if (isEdit) {
      _selectedKamarId = widget.pembayaran!.kamarId;
      _selectedUserId = widget.pembayaran!.userId;
      _selectedBulan = widget.pembayaran!.bulanPembayaran;
      _selectedTahun = widget.pembayaran!.tahunPembayaran;
      _selectedDate = widget.pembayaran!.tanggalBayar;
      _jumlah = widget.pembayaran!.jumlah;
      _selectedStatus = widget.pembayaran!.status;
    }
    _loadKamars();
  }

  Future<void> _loadKamars() async {
    final kamarProvider = Provider.of<KamarProvider>(context, listen: false);
    await kamarProvider.fetchKamars(status: 'terisi');
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedKamarId == null) {
      Helpers.showSnackBar(context, 'Pilih kamar terlebih dahulu', isError: true);
      return;
    }

    if (_selectedUserId == null) {
      Helpers.showSnackBar(context, 'Penyewa tidak ditemukan', isError: true);
      return;
    }

    final pembayaranProvider =
        Provider.of<PembayaranProvider>(context, listen: false);

    bool success;
    if (isEdit) {
      success = await pembayaranProvider.updatePembayaran(
        id: widget.pembayaran!.id,
        kamarId: _selectedKamarId,
        userId: _selectedUserId,
        bulanPembayaran: _selectedBulan,
        tahunPembayaran: _selectedTahun,
        tanggalBayar: _selectedDate.toIso8601String().split('T')[0],
        jumlah: _jumlah,
        status: _selectedStatus,
      );
    } else {
      success = await pembayaranProvider.createPembayaran(
        kamarId: _selectedKamarId!,
        userId: _selectedUserId!,
        bulanPembayaran: _selectedBulan,
        tahunPembayaran: _selectedTahun,
        tanggalBayar: _selectedDate.toIso8601String().split('T')[0],
        jumlah: _jumlah!,
        status: _selectedStatus,
      );
    }

    if (!mounted) return;

    if (success) {
      Helpers.showSnackBar(
        context,
        isEdit
            ? 'Pembayaran berhasil diupdate'
            : 'Pembayaran berhasil dicatat',
      );
      Navigator.of(context).pop(true);
    } else {
      Helpers.showSnackBar(
        context,
        pembayaranProvider.errorMessage ??
            (isEdit ? 'Gagal update pembayaran' : 'Gagal mencatat pembayaran'),
        isError: true,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(isEdit ? 'Edit Pembayaran' : 'Catat Pembayaran'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(AppTheme.spaceMD),
          children: [
            // Pilih Kamar
            Consumer<KamarProvider>(
              builder: (context, kamarProvider, _) {
                if (kamarProvider.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                final kamarsTerisi =
                    kamarProvider.kamars.where((k) => k.isTerisi).toList();

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Pilih Kamar & Penyewa',
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
                        prefixIcon: const Icon(Icons.bed),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(AppTheme.radiusMD),
                        ),
                      ),
                      hint: const Text('Pilih kamar'),
                      value: _selectedKamarId,
                      items: kamarsTerisi.map((kamar) {
                        return DropdownMenuItem<int>(
                          value: kamar.id,
                          child: Text(
                            'Kamar ${kamar.nomorKamar} - ${kamar.user?.nama ?? ""}',
                          ),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedKamarId = value;
                          final kamar = kamarsTerisi.firstWhere((k) => k.id == value);
                          _selectedUserId = kamar.userId;
                          _jumlah = kamar.hargaBulanan;
                        });
                      },
                      validator: (value) {
                        if (value == null) {
                          return 'Pilih kamar terlebih dahulu';
                        }
                        return null;
                      },
                    ),
                  ],
                );
              },
            ),

            const SizedBox(height: 16),

            // Periode Pembayaran
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Bulan',
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
                          border: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.circular(AppTheme.radiusMD),
                          ),
                        ),
                        value: _selectedBulan,
                        items: List.generate(12, (index) {
                          final bulan = index + 1;
                          return DropdownMenuItem(
                            value: bulan,
                            child: Text(Helpers.getMonthName(bulan)),
                          );
                        }),
                        onChanged: (value) {
                          setState(() {
                            _selectedBulan = value!;
                          });
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Tahun',
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
                          border: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.circular(AppTheme.radiusMD),
                          ),
                        ),
                        value: _selectedTahun,
                        items: List.generate(5, (index) {
                          final year = DateTime.now().year - 2 + index;
                          return DropdownMenuItem(
                            value: year,
                            child: Text(year.toString()),
                          );
                        }),
                        onChanged: (value) {
                          setState(() {
                            _selectedTahun = value!;
                          });
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Tanggal Bayar
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Tanggal Bayar',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 8),
                InkWell(
                  onTap: _selectDate,
                  child: Container(
                    padding: const EdgeInsets.all(AppTheme.spaceMD),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(color: AppTheme.dividerColor),
                      borderRadius: BorderRadius.circular(AppTheme.radiusMD),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.calendar_today),
                        const SizedBox(width: 12),
                        Text(
                          Helpers.formatDate(_selectedDate),
                          style: const TextStyle(fontSize: 16),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Jumlah
            if (_jumlah != null)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Jumlah Pembayaran',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(AppTheme.spaceMD),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryLight.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(AppTheme.radiusMD),
                    ),
                    child: Text(
                      Helpers.formatCurrency(_jumlah!),
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryColor,
                      ),
                    ),
                  ),
                ],
              ),

            const SizedBox(height: 16),

            // Status
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Status Pembayaran',
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
                        title: const Text('Lunas'),
                        value: 'lunas',
                        groupValue: _selectedStatus,
                        onChanged: (value) {
                          setState(() {
                            _selectedStatus = value!;
                          });
                        },
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                    Expanded(
                      child: RadioListTile<String>(
                        title: const Text('Belum'),
                        value: 'belum',
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

            const SizedBox(height: 32),

            Consumer<PembayaranProvider>(
              builder: (context, pembayaranProvider, _) {
                return CustomButton(
                  text: isEdit ? 'Update Pembayaran' : 'Simpan Pembayaran',
                  onPressed: _handleSubmit,
                  isLoading: pembayaranProvider.isLoading,
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