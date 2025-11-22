<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Pembayaran extends Model
{
    use HasFactory;

    /**
     * The attributes that are mass assignable.
     *
     * @var array<int, string>
     */
    protected $fillable = [
        'kamar_id',
        'user_id',
        'bulan_pembayaran',
        'tahun_pembayaran',
        'tanggal_bayar',
        'jumlah',
        'status',
        'bukti_bayar',
    ];

    /**
     * The attributes that should be cast.
     *
     * @var array<string, string>
     */
    protected $casts = [
        'tanggal_bayar' => 'date',
        'jumlah' => 'decimal:2',
    ];

    /**
     * Relasi: Pembayaran milik satu kamar
     */
    public function kamar()
    {
        return $this->belongsTo(Kamar::class);
    }

    /**
     * Relasi: Pembayaran dilakukan oleh satu user
     */
    public function user()
    {
        return $this->belongsTo(User::class);
    }

    /**
     * Scope untuk filter pembayaran lunas
     */
    public function scopeLunas($query)
    {
        return $query->where('status', 'lunas');
    }

    /**
     * Scope untuk filter pembayaran belum lunas
     */
    public function scopeBelum($query)
    {
        return $query->where('status', 'belum');
    }

    /**
     * Scope untuk filter by bulan dan tahun
     */
    public function scopeByPeriode($query, $bulan, $tahun)
    {
        return $query->where('bulan_pembayaran', $bulan)
                     ->where('tahun_pembayaran', $tahun);
    }
}