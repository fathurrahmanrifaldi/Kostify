<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Kamar extends Model
{
    use HasFactory;

    /**
     * The attributes that are mass assignable.
     *
     * @var array<int, string>
     */
    protected $fillable = [
        'nomor_kamar',
        'tipe',
        'harga_bulanan',
        'status',
        'fasilitas',
        'user_id',
    ];

    /**
     * The attributes that should be cast.
     *
     * @var array<string, string>
     */
    protected $casts = [
        'harga_bulanan' => 'decimal:2',
    ];

    /**
     * Relasi: Kamar dimiliki oleh satu user (penyewa)
     */
    public function user()
    {
        return $this->belongsTo(User::class);
    }

    /**
     * Relasi: Kamar punya banyak riwayat pembayaran
     */
    public function pembayarans()
    {
        return $this->hasMany(Pembayaran::class);
    }

    /**
     * Scope untuk filter kamar tersedia
     */
    public function scopeTersedia($query)
    {
        return $query->where('status', 'tersedia');
    }

    /**
     * Scope untuk filter kamar terisi
     */
    public function scopeTerisi($query)
    {
        return $query->where('status', 'terisi');
    }
}