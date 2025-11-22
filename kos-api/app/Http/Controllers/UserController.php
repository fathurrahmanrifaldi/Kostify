<?php

namespace App\Http\Controllers;

use App\Models\User;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Hash;

class UserController extends Controller
{
    /**
     * Display a listing of users (penyewa only)
     */
    public function index()
    {
        $users = User::where('role', 'penyewa')
                     ->with('kamars')
                     ->orderBy('nama', 'asc')
                     ->get();

        return response()->json([
            'success' => true,
            'data' => $users
        ], 200);
    }

    /**
     * Store a newly created user (penyewa)
     */
    public function store(Request $request)
    {
        $request->validate([
            'nama' => 'required|string|max:100',
            'email' => 'required|string|email|max:100|unique:users',
            'password' => 'required|string|min:6',
            'no_telepon' => 'nullable|string|max:15',
        ]);

        $user = User::create([
            'nama' => $request->nama,
            'email' => $request->email,
            'password' => Hash::make($request->password),
            'role' => 'penyewa',
            'no_telepon' => $request->no_telepon,
        ]);

        return response()->json([
            'success' => true,
            'message' => 'Penyewa berhasil ditambahkan',
            'data' => $user
        ], 201);
    }

    /**
     * Display the specified user
     */
    public function show($id)
    {
        $user = User::with(['kamars', 'pembayarans'])->find($id);

        if (!$user) {
            return response()->json([
                'success' => false,
                'message' => 'User tidak ditemukan'
            ], 404);
        }

        return response()->json([
            'success' => true,
            'data' => $user
        ], 200);
    }

    /**
     * Update the specified user
     */
    public function update(Request $request, $id)
    {
        $user = User::find($id);

        if (!$user) {
            return response()->json([
                'success' => false,
                'message' => 'User tidak ditemukan'
            ], 404);
        }

        $request->validate([
            'nama' => 'sometimes|string|max:100',
            'email' => 'sometimes|string|email|max:100|unique:users,email,' . $id,
            'password' => 'sometimes|string|min:6',
            'no_telepon' => 'nullable|string|max:15',
        ]);

        $data = $request->except('password');
        
        if ($request->has('password')) {
            $data['password'] = Hash::make($request->password);
        }

        $user->update($data);

        return response()->json([
            'success' => true,
            'message' => 'User berhasil diupdate',
            'data' => $user
        ], 200);
    }

    /**
     * Remove the specified user
     */
    public function destroy($id)
    {
        $user = User::find($id);

        if (!$user) {
            return response()->json([
                'success' => false,
                'message' => 'User tidak ditemukan'
            ], 404);
        }

        // Cek apakah user masih menempati kamar
        if ($user->kamars()->where('status', 'terisi')->count() > 0) {
            return response()->json([
                'success' => false,
                'message' => 'User tidak bisa dihapus karena masih menempati kamar'
            ], 400);
        }

        $user->delete();

        return response()->json([
            'success' => true,
            'message' => 'User berhasil dihapus'
        ], 200);
    }
}