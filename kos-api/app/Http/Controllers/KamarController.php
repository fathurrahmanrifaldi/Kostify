<?php

namespace App\Http\Controllers;

use App\Models\Kamar;
use Illuminate\Http\Request;

class KamarController extends Controller
{
    /**
     * Display a listing of kamars
     */
    public function index(Request $request)
    {
        $query = Kamar::with('user');

        // Filter by status jika ada
        if ($request->has('status')) {
            $query->where('status', $request->status);
        }

        // Filter by tipe jika ada
        if ($request->has('tipe')) {
            $query->where('tipe', $request->tipe);
        }

        $kamars = $query->orderBy('nomor_kamar', 'asc')->get();

        return response()->json([
            'success' => true,
            'data' => $kamars
        ], 200);
    }

    /**
     * Store a newly created kamar
     */
    public function store(Request $request)
    {
        $request->validate([
            'nomor_kamar' => 'required|string|max:10|unique:kamars',
            'tipe' => 'required|in:single,double',
            'harga_bulanan' => 'required|numeric|min:0',
            'status' => 'required|in:tersedia,terisi',
            'fasilitas' => 'nullable|string',
            'user_id' => 'nullable|exists:users,id',
        ]);

        $kamar = Kamar::create($request->all());

        return response()->json([
            'success' => true,
            'message' => 'Kamar berhasil ditambahkan',
            'data' => $kamar
        ], 201);
    }

    /**
     * Display the specified kamar
     */
    public function show($id)
    {
        $kamar = Kamar::with(['user', 'pembayarans'])->find($id);

        if (!$kamar) {
            return response()->json([
                'success' => false,
                'message' => 'Kamar tidak ditemukan'
            ], 404);
        }

        return response()->json([
            'success' => true,
            'data' => $kamar
        ], 200);
    }

    /**
     * Update the specified kamar
     */
    public function update(Request $request, $id)
    {
        $kamar = Kamar::find($id);

        if (!$kamar) {
            return response()->json([
                'success' => false,
                'message' => 'Kamar tidak ditemukan'
            ], 404);
        }

        $request->validate([
            'nomor_kamar' => 'sometimes|string|max:10|unique:kamars,nomor_kamar,' . $id,
            'tipe' => 'sometimes|in:single,double',
            'harga_bulanan' => 'sometimes|numeric|min:0',
            'status' => 'sometimes|in:tersedia,terisi',
            'fasilitas' => 'nullable|string',
            'user_id' => 'nullable|exists:users,id',
        ]);

        $kamar->update($request->all());

        return response()->json([
            'success' => true,
            'message' => 'Kamar berhasil diupdate',
            'data' => $kamar
        ], 200);
    }

    /**
     * Remove the specified kamar
     */
    public function destroy($id)
    {
        $kamar = Kamar::find($id);

        if (!$kamar) {
            return response()->json([
                'success' => false,
                'message' => 'Kamar tidak ditemukan'
            ], 404);
        }

        // Cek apakah kamar punya riwayat pembayaran
        if ($kamar->pembayarans()->count() > 0) {
            return response()->json([
                'success' => false,
                'message' => 'Kamar tidak bisa dihapus karena memiliki riwayat pembayaran'
            ], 400);
        }

        $kamar->delete();

        return response()->json([
            'success' => true,
            'message' => 'Kamar berhasil dihapus'
        ], 200);
    }

    /**
     * Get dashboard statistics
     */
    public function statistics()
    {
        $total = Kamar::count();
        $tersedia = Kamar::tersedia()->count();
        $terisi = Kamar::terisi()->count();

        return response()->json([
            'success' => true,
            'data' => [
                'total_kamar' => $total,
                'kamar_tersedia' => $tersedia,
                'kamar_terisi' => $terisi,
            ]
        ], 200);
    }
}