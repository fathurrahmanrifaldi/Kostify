<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use App\Models\User;
use App\Models\Kamar;
use App\Models\Pembayaran;
use Illuminate\Support\Facades\Hash;

class DatabaseSeeder extends Seeder
{
    /**
     * Seed the application's database.
     */
    public function run(): void
    {
        // Create Admin
        $admin = User::create([
            'nama' => 'Admin Kos',
            'email' => 'admin@kos.com',
            'password' => Hash::make('password'),
            'role' => 'admin',
            'no_telepon' => '081234567890',
        ]);

        // Create Penyewa
        $penyewa1 = User::create([
            'nama' => 'Budi Santoso',
            'email' => 'budi@gmail.com',
            'password' => Hash::make('password'),
            'role' => 'penyewa',
            'no_telepon' => '081234567891',
        ]);

        $penyewa2 = User::create([
            'nama' => 'Siti Aminah',
            'email' => 'siti@gmail.com',
            'password' => Hash::make('password'),
            'role' => 'penyewa',
            'no_telepon' => '081234567892',
        ]);

        $penyewa3 = User::create([
            'nama' => 'Ahmad Fadli',
            'email' => 'ahmad@gmail.com',
            'password' => Hash::make('password'),
            'role' => 'penyewa',
            'no_telepon' => '081234567893',
        ]);

        // Create Kamar
        $kamar1 = Kamar::create([
            'nomor_kamar' => 'A01',
            'tipe' => 'single',
            'harga_bulanan' => 800000,
            'status' => 'terisi',
            'fasilitas' => 'AC, Kamar Mandi Dalam, WiFi, Kasur',
            'user_id' => $penyewa1->id,
        ]);

        $kamar2 = Kamar::create([
            'nomor_kamar' => 'A02',
            'tipe' => 'single',
            'harga_bulanan' => 800000,
            'status' => 'terisi',
            'fasilitas' => 'AC, Kamar Mandi Dalam, WiFi, Kasur',
            'user_id' => $penyewa2->id,
        ]);

        $kamar3 = Kamar::create([
            'nomor_kamar' => 'B01',
            'tipe' => 'double',
            'harga_bulanan' => 1200000,
            'status' => 'terisi',
            'fasilitas' => 'AC, Kamar Mandi Dalam, WiFi, 2 Kasur, Lemari',
            'user_id' => $penyewa3->id,
        ]);

        $kamar4 = Kamar::create([
            'nomor_kamar' => 'B02',
            'tipe' => 'double',
            'harga_bulanan' => 1200000,
            'status' => 'tersedia',
            'fasilitas' => 'AC, Kamar Mandi Dalam, WiFi, 2 Kasur, Lemari',
            'user_id' => null,
        ]);

        $kamar5 = Kamar::create([
            'nomor_kamar' => 'C01',
            'tipe' => 'single',
            'harga_bulanan' => 700000,
            'status' => 'tersedia',
            'fasilitas' => 'Kipas, Kamar Mandi Luar, WiFi, Kasur',
            'user_id' => null,
        ]);

        // Create Pembayaran (3 bulan terakhir untuk penyewa yang terisi)
        $bulanSekarang = date('n');
        $tahunSekarang = date('Y');

        // Pembayaran untuk Budi (Kamar A01) - 3 bulan terakhir
        for ($i = 2; $i >= 0; $i--) {
            $bulan = $bulanSekarang - $i;
            $tahun = $tahunSekarang;
            
            if ($bulan <= 0) {
                $bulan += 12;
                $tahun--;
            }

            Pembayaran::create([
                'kamar_id' => $kamar1->id,
                'user_id' => $penyewa1->id,
                'bulan_pembayaran' => $bulan,
                'tahun_pembayaran' => $tahun,
                'tanggal_bayar' => date('Y-m-d', strtotime("$tahun-$bulan-05")),
                'jumlah' => 800000,
                'status' => $i == 0 ? 'belum' : 'lunas', // Bulan ini belum lunas
                'bukti_bayar' => null,
            ]);
        }

        // Pembayaran untuk Siti (Kamar A02) - 3 bulan terakhir (semua lunas)
        for ($i = 2; $i >= 0; $i--) {
            $bulan = $bulanSekarang - $i;
            $tahun = $tahunSekarang;
            
            if ($bulan <= 0) {
                $bulan += 12;
                $tahun--;
            }

            Pembayaran::create([
                'kamar_id' => $kamar2->id,
                'user_id' => $penyewa2->id,
                'bulan_pembayaran' => $bulan,
                'tahun_pembayaran' => $tahun,
                'tanggal_bayar' => date('Y-m-d', strtotime("$tahun-$bulan-03")),
                'jumlah' => 800000,
                'status' => 'lunas',
                'bukti_bayar' => null,
            ]);
        }

        // Pembayaran untuk Ahmad (Kamar B01) - 2 bulan terakhir saja
        for ($i = 1; $i >= 0; $i--) {
            $bulan = $bulanSekarang - $i;
            $tahun = $tahunSekarang;
            
            if ($bulan <= 0) {
                $bulan += 12;
                $tahun--;
            }

            Pembayaran::create([
                'kamar_id' => $kamar3->id,
                'user_id' => $penyewa3->id,
                'bulan_pembayaran' => $bulan,
                'tahun_pembayaran' => $tahun,
                'tanggal_bayar' => date('Y-m-d', strtotime("$tahun-$bulan-10")),
                'jumlah' => 1200000,
                'status' => 'lunas',
                'bukti_bayar' => null,
            ]);
        }

        echo "Seeding completed successfully!\n";
        echo "Admin login: admin@kos.com / password\n";
        echo "Penyewa login: budi@gmail.com / password\n";
    }
}