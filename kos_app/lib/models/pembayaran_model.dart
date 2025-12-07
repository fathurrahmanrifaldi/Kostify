import 'user_model.dart';
import 'kamar_model.dart';

class Pembayaran {
  final int id;
  final int kamarId;
  final int userId;
  final int bulanPembayaran;
  final int tahunPembayaran;
  final DateTime tanggalBayar;
  final double jumlah;
  final String status;
  final String? buktiBayar;
  final Kamar? kamar;
  final User? user;
  final DateTime? createdAt;

  Pembayaran({
    required this.id,
    required this.kamarId,
    required this.userId,
    required this.bulanPembayaran,
    required this.tahunPembayaran,
    required this.tanggalBayar,
    required this.jumlah,
    required this.status,
    this.buktiBayar,
    this.kamar,
    this.user,
    this.createdAt,
  });

  // From JSON
  factory Pembayaran.fromJson(Map<String, dynamic> json) {
    return Pembayaran(
      id: json['id'],
      kamarId: json['kamar_id'],
      userId: json['user_id'],
      bulanPembayaran: json['bulan_pembayaran'],
      tahunPembayaran: json['tahun_pembayaran'],
      tanggalBayar: DateTime.parse(json['tanggal_bayar']),
      jumlah: double.parse(json['jumlah'].toString()),
      status: json['status'],
      buktiBayar: json['bukti_bayar'],
      kamar: json['kamar'] != null ? Kamar.fromJson(json['kamar']) : null,
      user: json['user'] != null ? User.fromJson(json['user']) : null,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : null,
    );
  }

  // To JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'kamar_id': kamarId,
      'user_id': userId,
      'bulan_pembayaran': bulanPembayaran,
      'tahun_pembayaran': tahunPembayaran,
      'tanggal_bayar': tanggalBayar.toIso8601String().split('T')[0],
      'jumlah': jumlah,
      'status': status,
      'bukti_bayar': buktiBayar,
      'created_at': createdAt?.toIso8601String(),
    };
  }

  // Helper methods
  bool get isLunas => status == 'lunas';
  bool get isBelum => status == 'belum';

  String get namaBulan {
    const bulan = [
      'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
      'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'
    ];
    return bulan[bulanPembayaran - 1];
  }

  String get periode => '$namaBulan $tahunPembayaran';

  String get nomorKamar => kamar?.nomorKamar ?? '-';
  String get namaPenyewa => user?.nama ?? '-';

  // Copy with
  Pembayaran copyWith({
    int? id,
    int? kamarId,
    int? userId,
    int? bulanPembayaran,
    int? tahunPembayaran,
    DateTime? tanggalBayar,
    double? jumlah,
    String? status,
    String? buktiBayar,
    Kamar? kamar,
    User? user,
    DateTime? createdAt,
  }) {
    return Pembayaran(
      id: id ?? this.id,
      kamarId: kamarId ?? this.kamarId,
      userId: userId ?? this.userId,
      bulanPembayaran: bulanPembayaran ?? this.bulanPembayaran,
      tahunPembayaran: tahunPembayaran ?? this.tahunPembayaran,
      tanggalBayar: tanggalBayar ?? this.tanggalBayar,
      jumlah: jumlah ?? this.jumlah,
      status: status ?? this.status,
      buktiBayar: buktiBayar ?? this.buktiBayar,
      kamar: kamar ?? this.kamar,
      user: user ?? this.user,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}