import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../config/theme.dart';
import '../../../providers/pembayaran_provider.dart';
import '../../../utils/helpers.dart';
import 'pembayaran_form_screen.dart';
import 'pembayaran_detail_screen.dart';

class PembayaranListScreen extends StatefulWidget {
  const PembayaranListScreen({super.key});

  @override
  State<PembayaranListScreen> createState() => _PembayaranListScreenState();
}

class _PembayaranListScreenState extends State<PembayaranListScreen> {
  String? _selectedStatus;
  int? _selectedBulan;
  int? _selectedTahun;

  @override
  void initState() {
    super.initState();
    _selectedTahun = DateTime.now().year;
    _loadData();
  }

  Future<void> _loadData() async {
    final pembayaranProvider =
        Provider.of<PembayaranProvider>(context, listen: false);
    await pembayaranProvider.fetchPembayarans(
      status: _selectedStatus,
      bulan: _selectedBulan,
      tahun: _selectedTahun,
    );
  }

  Future<void> _handleDelete(int id) async {
    final confirm = await Helpers.showConfirmDialog(
      context,
      title: 'Hapus Pembayaran',
      message: 'Yakin ingin menghapus pembayaran ini?',
      confirmText: 'Hapus',
    );

    if (!confirm) return;

    final pembayaranProvider =
        Provider.of<PembayaranProvider>(context, listen: false);
    final success = await pembayaranProvider.deletePembayaran(id);

    if (!mounted) return;

    if (success) {
      Helpers.showSnackBar(context, 'Pembayaran berhasil dihapus');
      _loadData();
    } else {
      Helpers.showSnackBar(
        context,
        pembayaranProvider.errorMessage ?? 'Gagal menghapus pembayaran',
        isError: true,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Daftar Pembayaran'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadData,
          ),
        ],
      ),
      body: Column(
        children: [
          // Filter Section
          Container(
            padding: const EdgeInsets.all(AppTheme.spaceMD),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Filter Status:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: [
                    ChoiceChip(
                      label: const Text('Semua'),
                      selected: _selectedStatus == null,
                      onSelected: (selected) {
                        setState(() {
                          _selectedStatus = null;
                        });
                        _loadData();
                      },
                    ),
                    ChoiceChip(
                      label: const Text('Lunas'),
                      selected: _selectedStatus == 'lunas',
                      selectedColor: AppTheme.successColor.withOpacity(0.3),
                      onSelected: (selected) {
                        setState(() {
                          _selectedStatus = selected ? 'lunas' : null;
                        });
                        _loadData();
                      },
                    ),
                    ChoiceChip(
                      label: const Text('Belum Lunas'),
                      selected: _selectedStatus == 'belum',
                      selectedColor: AppTheme.errorColor.withOpacity(0.3),
                      onSelected: (selected) {
                        setState(() {
                          _selectedStatus = selected ? 'belum' : null;
                        });
                        _loadData();
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Bulan:',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8),
                          DropdownButtonFormField<int>(
                            decoration: InputDecoration(
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                              border: OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.circular(AppTheme.radiusMD),
                              ),
                            ),
                            hint: const Text('Semua'),
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
                                _selectedBulan = value;
                              });
                              _loadData();
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
                            'Tahun:',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8),
                          DropdownButtonFormField<int>(
                            decoration: InputDecoration(
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                              border: OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.circular(AppTheme.radiusMD),
                              ),
                            ),
                            value: _selectedTahun,
                            items: List.generate(5, (index) {
                              final year = DateTime.now().year - index;
                              return DropdownMenuItem(
                                value: year,
                                child: Text(year.toString()),
                              );
                            }),
                            onChanged: (value) {
                              setState(() {
                                _selectedTahun = value;
                              });
                              _loadData();
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const Divider(height: 1),

          // List Pembayaran
          Expanded(
            child: Consumer<PembayaranProvider>(
              builder: (context, pembayaranProvider, _) {
                if (pembayaranProvider.isLoading &&
                    pembayaranProvider.pembayarans.isEmpty) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (pembayaranProvider.pembayarans.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.payment_outlined,
                          size: 80,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Belum ada pembayaran',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return RefreshIndicator(
                  onRefresh: _loadData,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(AppTheme.spaceMD),
                    itemCount: pembayaranProvider.pembayarans.length,
                    itemBuilder: (context, index) {
                      final pembayaran = pembayaranProvider.pembayarans[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: InkWell(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => PembayaranDetailScreen(
                                  pembayaranId: pembayaran.id,
                                ),
                              ),
                            ).then((_) => _loadData());
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(AppTheme.spaceMD),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            pembayaran.namaPenyewa,
                                            style: const TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            'Kamar ${pembayaran.nomorKamar}',
                                            style: const TextStyle(
                                              fontSize: 14,
                                              color: AppTheme.textSecondary,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 6,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Helpers.getStatusColor(
                                            pembayaran.status),
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: Text(
                                        pembayaran.status.toUpperCase(),
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 11,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const Divider(height: 24),
                                Row(
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            pembayaran.periode,
                                            style: const TextStyle(
                                              fontSize: 13,
                                              color: AppTheme.textSecondary,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            Helpers.formatCurrency(
                                                pembayaran.jumlah),
                                            style: const TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                              color: AppTheme.primaryColor,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.end,
                                      children: [
                                        const Text(
                                          'Tanggal Bayar',
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: AppTheme.textSecondary,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          Helpers.formatDate(
                                              pembayaran.tanggalBayar),
                                          style: const TextStyle(
                                            fontSize: 13,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    TextButton.icon(
                                      onPressed: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (_) =>
                                                PembayaranFormScreen(
                                              pembayaran: pembayaran,
                                            ),
                                          ),
                                        ).then((_) => _loadData());
                                      },
                                      icon: const Icon(Icons.edit, size: 18),
                                      label: const Text('Edit'),
                                    ),
                                    const SizedBox(width: 8),
                                    TextButton.icon(
                                      onPressed: () =>
                                          _handleDelete(pembayaran.id),
                                      icon: const Icon(Icons.delete, size: 18),
                                      label: const Text('Hapus'),
                                      style: TextButton.styleFrom(
                                        foregroundColor: AppTheme.errorColor,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const PembayaranFormScreen()),
          ).then((_) => _loadData());
        },
        icon: const Icon(Icons.add),
        label: const Text('Catat Pembayaran'),
      ),
    );
  }
}