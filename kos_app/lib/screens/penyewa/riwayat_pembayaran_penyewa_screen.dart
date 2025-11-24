// lib/screens/penyewa/riwayat_pembayaran_penyewa_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import '../../providers/pembayaran_provider.dart';
import '../../utils/helpers.dart';

class RiwayatPembayaranPenyewaScreen extends StatefulWidget {
  const RiwayatPembayaranPenyewaScreen({super.key});

  @override
  State<RiwayatPembayaranPenyewaScreen> createState() =>
      _RiwayatPembayaranPenyewaScreenState();
}

class _RiwayatPembayaranPenyewaScreenState
    extends State<RiwayatPembayaranPenyewaScreen> {
  int? _selectedTahun;
  String? _selectedStatus;

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
      tahun: _selectedTahun,
      status: _selectedStatus,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Riwayat Pembayaran'),
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
            color: Colors.white,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Filter:',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    // Filter Tahun
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Tahun',
                            style: TextStyle(fontSize: 12),
                          ),
                          const SizedBox(height: 6),
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
                    const SizedBox(width: 12),
                    // Filter Status
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Status',
                            style: TextStyle(fontSize: 12),
                          ),
                          const SizedBox(height: 6),
                          DropdownButtonFormField<String>(
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
                            value: _selectedStatus,
                            items: const [
                              DropdownMenuItem(
                                value: null,
                                child: Text('Semua'),
                              ),
                              DropdownMenuItem(
                                value: 'lunas',
                                child: Text('Lunas'),
                              ),
                              DropdownMenuItem(
                                value: 'belum',
                                child: Text('Belum'),
                              ),
                            ],
                            onChanged: (value) {
                              setState(() {
                                _selectedStatus = value;
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

          // Summary Card
          Consumer<PembayaranProvider>(
            builder: (context, pembayaranProvider, _) {
              final totalLunas = pembayaranProvider.pembayarans
                  .where((p) => p.isLunas)
                  .length;
              final totalBelum = pembayaranProvider.pembayarans
                  .where((p) => p.isBelum)
                  .length;
              final totalJumlah = pembayaranProvider.pembayarans
                  .where((p) => p.isLunas)
                  .fold(0.0, (sum, p) => sum + p.jumlah);

              if (pembayaranProvider.pembayarans.isEmpty) {
                return const SizedBox();
              }

              return Container(
                margin: const EdgeInsets.all(AppTheme.spaceMD),
                padding: const EdgeInsets.all(AppTheme.spaceMD),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppTheme.primaryColor,
                      AppTheme.primaryColor.withOpacity(0.7),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(AppTheme.radiusMD),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.primaryColor.withOpacity(0.3),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    const Text(
                      'Total Sudah Dibayar',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      Helpers.formatCurrency(totalJumlah),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Column(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: AppTheme.successColor,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                '$totalLunas Lunas',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        Container(
                          width: 1,
                          height: 20,
                          color: Colors.white30,
                        ),
                        Column(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: AppTheme.errorColor,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                '$totalBelum Belum',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),

          // List Riwayat
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
                          Icons.history_outlined,
                          size: 80,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Belum ada riwayat pembayaran',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Tahun ${_selectedTahun ?? DateTime.now().year}',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[500],
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return RefreshIndicator(
                  onRefresh: _loadData,
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppTheme.spaceMD,
                      vertical: AppTheme.spaceSM,
                    ),
                    itemCount: pembayaranProvider.pembayarans.length,
                    itemBuilder: (context, index) {
                      final pembayaran = pembayaranProvider.pembayarans[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: Padding(
                          padding: const EdgeInsets.all(AppTheme.spaceMD),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Header
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.calendar_month,
                                        size: 18,
                                        color: AppTheme.textSecondary,
                                      ),
                                      const SizedBox(width: 6),
                                      Text(
                                        pembayaran.periode,
                                        style: const TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Helpers.getStatusColor(
                                          pembayaran.status),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      pembayaran.status.toUpperCase(),
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),

                              const Divider(height: 24),

                              // Jumlah
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        'Jumlah',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: AppTheme.textSecondary,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        Helpers.formatCurrency(
                                            pembayaran.jumlah),
                                        style: const TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                          color: AppTheme.primaryColor,
                                        ),
                                      ),
                                    ],
                                  ),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
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
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),

                              const SizedBox(height: 12),

                              // Kamar info
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: AppTheme.backgroundColor,
                                  borderRadius:
                                      BorderRadius.circular(AppTheme.radiusSM),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(
                                      Icons.bed,
                                      size: 16,
                                      color: AppTheme.textSecondary,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      'Kamar ${pembayaran.nomorKamar}',
                                      style: const TextStyle(
                                        fontSize: 13,
                                        color: AppTheme.textSecondary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
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
    );
  }
}