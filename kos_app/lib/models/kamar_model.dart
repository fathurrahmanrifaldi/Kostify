import 'user_model.dart';

class Kamar {
  final int id;
  final String nomorKamar;
  final String tipe;
  final double hargaBulanan;
  final String status;
  final String? fasilitas;
  final int? userId;
  final User? user;
  final DateTime? createdAt;

  Kamar({
    required this.id,
    required this.nomorKamar,
    required this.tipe,
    required this.hargaBulanan,
    required this.status,
    this.fasilitas,
    this.userId,
    this.user,
    this.createdAt,
  });

  // From JSON
  factory Kamar.fromJson(Map<String, dynamic> json) {
    return Kamar(
      id: json['id'],
      nomorKamar: json['nomor_kamar'],
      tipe: json['tipe'],
      hargaBulanan: double.parse(json['harga_bulanan'].toString()),
      status: json['status'],
      fasilitas: json['fasilitas'],
      userId: json['user_id'],
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
      'nomor_kamar': nomorKamar,
      'tipe': tipe,
      'harga_bulanan': hargaBulanan,
      'status': status,
      'fasilitas': fasilitas,
      'user_id': userId,
      'created_at': createdAt?.toIso8601String(),
    };
  }

  // Helper methods
  bool get isTersedia => status == 'tersedia';
  bool get isTerisi => status == 'terisi';
  bool get isSingle => tipe == 'single';
  bool get isDouble => tipe == 'double';

  String get namaPenyewa => user?.nama ?? 'Belum ada penyewa';

  // Copy with
  Kamar copyWith({
    int? id,
    String? nomorKamar,
    String? tipe,
    double? hargaBulanan,
    String? status,
    String? fasilitas,
    int? userId,
    User? user,
    DateTime? createdAt,
  }) {
    return Kamar(
      id: id ?? this.id,
      nomorKamar: nomorKamar ?? this.nomorKamar,
      tipe: tipe ?? this.tipe,
      hargaBulanan: hargaBulanan ?? this.hargaBulanan,
      status: status ?? this.status,
      fasilitas: fasilitas ?? this.fasilitas,
      userId: userId ?? this.userId,
      user: user ?? this.user,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}