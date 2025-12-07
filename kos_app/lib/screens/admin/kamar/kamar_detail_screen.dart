import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../config/theme.dart';
import '../../../providers/kamar_provider.dart';
import '../../../utils/helpers.dart';
import 'kamar_form_screen.dart';

class KamarDetailScreen extends StatefulWidget {
  final int kamarId;

  const KamarDetailScreen({super.key, required this.kamarId});

  @override
  State<KamarDetailScreen> createState() => _KamarDetailScreenState();
}

class _KamarDetailScreenState extends State<KamarDetailScreen> {
  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final kamarProvider = Provider.of<KamarProvider>(context, listen: false);
    await kamarProvider.fetchKamarById(widget.kamarId);
  }

  Future<void> _handleDelete() async {
    final confirm = await Helpers.showConfirmDialog(
      context,
      title: 'Hapus Kamar',
      message: 'Yakin ingin menghapus kamar ini?',
      confirmText: 'Hapus',
    );

    if (!confirm) return;

    final kamarProvider = Provider.of<KamarProvider>(context, listen: false);
    final success = await kamarProvider.deleteKamar(widget.kamarId);

    if (!mounted) return;

    if (success) {
      Helpers.showSnackBar(context, 'Kamar berhasil dihapus');
      Navigator.of(context).pop(true);
    } else {
      Helpers.showSnackBar(
        context,
        kamarProvider.errorMessage ?? 'Gagal menghapus kamar',
        isError: true,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Kamar'),
        actions: [
          Consumer<KamarProvider>(
            builder: (context, kamarProvider, _) {
              final kamar = kamarProvider.selectedKamar;
              if (kamar == null) return const SizedBox();

              return Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => KamarFormScreen(kamar: kamar),
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
      body: Consumer<KamarProvider>(
        builder: (context, kamarProvider, _) {
          if (kamarProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          final kamar = kamarProvider.selectedKamar;
          if (kamar == null) {
            return const Center(child: Text('Kamar tidak ditemukan'));
          }

          return RefreshIndicator(
            onRefresh: _loadData,
            child: ListView(
              padding: const EdgeInsets.all(AppTheme.spaceMD),
              children: [
                // Kamar Info Card
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(AppTheme.spaceMD),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: AppTheme.primaryLight,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(
                                Icons.bed,
                                color: AppTheme.primaryColor,
                                size: 40,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Kamar ${kamar.nomorKamar}',
                                    style: Theme.of(context)
                                        .textTheme
                                        .displayMedium,
                                  ),
                                  const SizedBox(height: 4),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: kamar.tipe == 'single'
                                          ? Colors.blue.withOpacity(0.1)
                                          : Colors.purple.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      Helpers.capitalize(kamar.tipe),
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.bold,
                                        color: kamar.tipe == 'single'
                                            ? Colors.blue
                                            : Colors.purple,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: Helpers.getStatusColor(kamar.status),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                Helpers.capitalize(kamar.status),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const Divider(height: 32),
                        _InfoRow(
                          icon: Icons.attach_money,
                          label: 'Harga Bulanan',
                          value: Helpers.formatCurrency(kamar.hargaBulanan),
                        ),
                        if (kamar.fasilitas != null) ...[
                          const SizedBox(height: 16),
                          _InfoRow(
                            icon: Icons.check_circle_outline,
                            label: 'Fasilitas',
                            value: kamar.fasilitas!,
                          ),
                        ],
                      ],
                    ),
                  ),
                ),

                // Penyewa Info Card (jika terisi)
                if (kamar.user != null) ...[
                  const SizedBox(height: 16),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(AppTheme.spaceMD),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Informasi Penyewa',
                            style:
                                Theme.of(context).textTheme.displaySmall,
                          ),
                          const Divider(height: 24),
                          Row(
                            children: [
                              CircleAvatar(
                                radius: 30,
                                backgroundColor: AppTheme.primaryLight,
                                child: Text(
                                  kamar.user!.nama
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
                                      kamar.user!.nama,
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      kamar.user!.email,
                                      style: const TextStyle(
                                        fontSize: 14,
                                        color: AppTheme.textSecondary,
                                      ),
                                    ),
                                    if (kamar.user!.noTelepon != null) ...[
                                      const SizedBox(height: 4),
                                      Text(
                                        kamar.user!.noTelepon!,
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