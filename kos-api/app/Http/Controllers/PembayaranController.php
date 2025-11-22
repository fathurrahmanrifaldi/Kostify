<?php

namespace App\Http\Controllers;

use App\Models\Pembayaran;
use Illuminate\Http\Request;

class PembayaranController extends Controller
{
    /**
     * Display a listing of pembayaran
     */
    public function index(Request $request)
    {
        $user = $request->user();
        
        $query = Pembayaran::with(['kamar', 'user']);

        // Jika penyewa, hanya tampilkan pembayaran miliknya
        if ($user->isPenyewa()) {
            $query->where('user_id', $user->id);
        }

        // Filter by status jika ada
        if ($request->has('status')) {
            $query->where('status', $request->status);
        }

        // Filter by bulan dan tahun jika ada
        if ($request->has('bulan') && $request->has('tahun')) {
            $query->byPeriode($request->bulan, $request->tahun);
        }

        // Filter by kamar_id jika ada
        if ($request->has('kamar_id')) {
            $query->where('kamar_id', $request->kamar_id);
        }

        $pembayarans = $query->orderBy('tahun_pembayaran', 'desc')
                             ->orderBy('bulan_pembayaran', 'desc')
                             ->get();

        return response()->json([
            'success' => true,
            'data' => $pembayarans
        ], 200);
    }

    /**
     * Store a newly created pembayaran
     */
    public function store(Request $request)
    {
        $request->validate([
            'kamar_id' => 'required|exists:kamars,id',
            'user_id' => 'required|exists:users,id',
            'bulan_pembayaran' => 'required|integer|min:1|max:12',
            'tahun_pembayaran' => 'required|integer|min:2020',
            'tanggal_bayar' => 'required|date',
            'jumlah' => 'required|numeric|min:0',
            'status' => 'required|in:lunas,belum',
            'bukti_bayar' => 'nullable|string',
        ]);

        // Cek apakah pembayaran untuk bulan/tahun ini sudah ada
        $exists = Pembayaran::where('kamar_id', $request->kamar_id)
                           ->where('user_id', $request->user_id)
                           ->where('bulan_pembayaran', $request->bulan_pembayaran)
                           ->where('tahun_pembayaran', $request->tahun_pembayaran)
                           ->exists();

        if ($exists) {
            return response()->json([
                'success' => false,
                'message' => 'Pembayaran untuk bulan ini sudah tercatat'
            ], 400);
        }

        $pembayaran = Pembayaran::create($request->all());
        $pembayaran->load(['kamar', 'user']);

        return response()->json([
            'success' => true,
            'message' => 'Pembayaran berhasil dicatat',
            'data' => $pembayaran
        ], 201);
    }

    /**
     * Display the specified pembayaran
     */
    public function show(Request $request, $id)
    {
        $user = $request->user();
        $pembayaran = Pembayaran::with(['kamar', 'user'])->find($id);

        if (!$pembayaran) {
            return response()->json([
                'success' => false,
                'message' => 'Pembayaran tidak ditemukan'
            ], 404);
        }

        // Jika penyewa, hanya bisa lihat pembayaran miliknya
        if ($user->isPenyewa() && $pembayaran->user_id !== $user->id) {
            return response()->json([
                'success' => false,
                'message' => 'Akses ditolak'
            ], 403);
        }

        return response()->json([
            'success' => true,
            'data' => $pembayaran
        ], 200);
    }

    /**
     * Update the specified pembayaran
     */
    public function update(Request $request, $id)
    {
        $pembayaran = Pembayaran::find($id);

        if (!$pembayaran) {
            return response()->json([
                'success' => false,
                'message' => 'Pembayaran tidak ditemukan'
            ], 404);
        }

        $request->validate([
            'kamar_id' => 'sometimes|exists:kamars,id',
            'user_id' => 'sometimes|exists:users,id',
            'bulan_pembayaran' => 'sometimes|integer|min:1|max:12',
            'tahun_pembayaran' => 'sometimes|integer|min:2020',
            'tanggal_bayar' => 'sometimes|date',
            'jumlah' => 'sometimes|numeric|min:0',
            'status' => 'sometimes|in:lunas,belum',
            'bukti_bayar' => 'nullable|string',
        ]);

        $pembayaran->update($request->all());
        $pembayaran->load(['kamar', 'user']);

        return response()->json([
            'success' => true,
            'message' => 'Pembayaran berhasil diupdate',
            'data' => $pembayaran
        ], 200);
    }

    /**
     * Remove the specified pembayaran
     */
    public function destroy($id)
    {
        $pembayaran = Pembayaran::find($id);

        if (!$pembayaran) {
            return response()->json([
                'success' => false,
                'message' => 'Pembayaran tidak ditemukan'
            ], 404);
        }

        $pembayaran->delete();

        return response()->json([
            'success' => true,
            'message' => 'Pembayaran berhasil dihapus'
        ], 200);
    }

    /**
     * Get pembayaran by kamar_id
     */
    public function byKamar($kamar_id)
    {
        $pembayarans = Pembayaran::with(['user', 'kamar'])
                                 ->where('kamar_id', $kamar_id)
                                 ->orderBy('tahun_pembayaran', 'desc')
                                 ->orderBy('bulan_pembayaran', 'desc')
                                 ->get();

        return response()->json([
            'success' => true,
            'data' => $pembayarans
        ], 200);
    }

    /**
     * Get laporan pembayaran (dashboard)
     */
    public function laporan(Request $request)
    {
        $bulan = $request->input('bulan', date('n'));
        $tahun = $request->input('tahun', date('Y'));

        $total = Pembayaran::byPeriode($bulan, $tahun)->sum('jumlah');
        $lunas = Pembayaran::byPeriode($bulan, $tahun)->lunas()->count();
        $belum = Pembayaran::byPeriode($bulan, $tahun)->belum()->count();

        return response()->json([
            'success' => true,
            'data' => [
                'bulan' => $bulan,
                'tahun' => $tahun,
                'total_pembayaran' => $total,
                'lunas' => $lunas,
                'belum_lunas' => $belum,
            ]
        ], 200);
    }
}