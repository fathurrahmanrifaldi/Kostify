// lib/screens/admin/pembayaran/pembayaran_detail_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../config/theme.dart';
import '../../../providers/pembayaran_provider.dart';
import '../../../utils/helpers.dart';
import 'pembayaran_form_screen.dart';

class PembayaranDetailScreen extends StatefulWidget {
  final int pembayaranId;

  const PembayaranDetailScreen({super.key, required this.pembayaranId});

  @override
  State<PembayaranDetailScreen> createState() => _PembayaranDetailScreenState();
}

class _PembayaranDetailScreenState extends State<PembayaranDetailScreen> {
  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final pembayaranProvider =
        Provider.of<PembayaranProvider>(context, listen: false);
    await pembayaranProvider.fetchPembayaranById(widget.pembayaranId);
  }

  Future<void> _handleDelete() async {
    final confirm = await Helpers.showConfirmDialog(
      context,
      title: 'Hapus Pembayaran',
      message: 'Yakin ingin menghapus pembayaran ini?',
      confirmText: 'Hapus',
    );

    if (!confirm) return;

    final pembayaranProvider =
        Provider.of<PembayaranProvider>(context, listen: false);
    final success =
        await pembayaranProvider.deletePembayaran(widget.pembayaranId);

    if (!mounted) return;

    if (success) {
      Helpers.showSnackBar(context, 'Pembayaran berhasil dihapus');
      Navigator.of(context).pop(true);
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
        title: const Text('Detail Pembayaran'),
        actions: [
          Consumer<PembayaranProvider>(
            builder: (context, pembayaranProvider, _) {
              final pembayaran = pembayaranProvider.selectedPembayaran;
              if (pembayaran == null) return const SizedBox();

              return Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              PembayaranFormScreen(pembayaran: pembayaran),
                        ),
                      ).then((_) => _loadData());
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: _handleDelete,
                  ),
                ],
              );
            },
          ),
        ],
      ),
      body: Consumer<PembayaranProvider>(
        builder: (context, pembayaranProvider, _) {
          if (pembayaranProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          final pembayaran = pembayaranProvider.selectedPembayaran;
          if (pembayaran == null) {
            return const Center(child: Text('Pembayaran tidak ditemukan'));
          }

          return RefreshIndicator(
            onRefresh: _loadData,
            child: ListView(
              padding: const EdgeInsets.all(AppTheme.spaceMD),
              children: [
                // Status & Jumlah Card
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(AppTheme.spaceLG),
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 10,
                          ),
                          decoration: BoxDecoration(
                            color: Helpers.getStatusColor(pembayaran.status),
                            borderRadius: BorderRadius.circular(30),
                          ),
                          child: Text(
                            pembayaran.status.toUpperCase(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        Text(
                          Helpers.formatCurrency(pembayaran.jumlah),
                          style: const TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.primaryColor,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          pembayaran.periode,
                          style: const TextStyle(
                            fontSize: 16,
                            color: AppTheme.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Dibayar: ${Helpers.formatDate(pembayaran.tanggalBayar)}',
                          style: const TextStyle(
                            fontSize: 14,
                            color: AppTheme.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Info Kamar Card
                if (pembayaran.kamar != null) ...[
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(AppTheme.spaceMD),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Informasi Kamar',
                            style: Theme.of(context).textTheme.displaySmall,
                          ),
                          const Divider(height: 24),
                          _InfoRow(
                            icon: Icons.bed,
                            label: 'Nomor Kamar',
                            value: 'Kamar ${pembayaran.kamar!.nomorKamar}',
                          ),
                          const SizedBox(height: 16),
                          _InfoRow(
                            icon: Icons.category,
                            label: 'Tipe',
                            value: Helpers.capitalize(pembayaran.kamar!.tipe),
                          ),
                          const SizedBox(height: 16),
                          _InfoRow(
                            icon: Icons.attach_money,
                            label: 'Harga Sewa',
                            value: Helpers.formatCurrency(
                                pembayaran.kamar!.hargaBulanan),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],

                // Info Penyewa Card
                if (pembayaran.user != null) ...[
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(AppTheme.spaceMD),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Informasi Penyewa',
                            style: Theme.of(context).textTheme.displaySmall,
                          ),
                          const Divider(height: 24),
                          Row(
                            children: [
                              CircleAvatar(
                                radius: 30,
                                backgroundColor: AppTheme.primaryLight,
                                child: Text(
                                  pembayaran.user!.nama
                                      .substring(0, 1)
                                      .toUpperCase(),
                                  style: const TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: AppTheme.primaryColor,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      pembayaran.user!.nama,
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      pembayaran.user!.email,
                                      style: const TextStyle(
                                        fontSize: 14,
                                        color: AppTheme.textSecondary,
                                      ),
                                    ),
                                    if (pembayaran.user!.noTelepon != null) ...[
                                      const SizedBox(height: 4),
                                      Text(
                                        pembayaran.user!.noTelepon!,
                                        style: const TextStyle(
                                          fontSize: 14,
                                          color: AppTheme.textSecondary,
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 24, color: AppTheme.textSecondary),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 13,
                  color: AppTheme.textSecondary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}