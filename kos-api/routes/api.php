<?php

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Route;
use App\Http\Controllers\AuthController;
use App\Http\Controllers\KamarController;
use App\Http\Controllers\UserController;
use App\Http\Controllers\PembayaranController;

/*
|--------------------------------------------------------------------------
| API Routes
|--------------------------------------------------------------------------
*/

// Public routes (tidak perlu autentikasi)
Route::post('/register', [AuthController::class, 'register']);
Route::post('/login', [AuthController::class, 'login']);

// Protected routes (perlu autentikasi)
Route::middleware('auth:sanctum')->group(function () {

    // Auth routes
    Route::post('/logout', [AuthController::class, 'logout']);
    Route::get('/profile', [AuthController::class, 'profile']);
    Route::put('/profile', [AuthController::class, 'updateProfile']);
    Route::post('/profile/change-password', [AuthController::class, 'changePassword']);

    // Kamar routes (semua authenticated user bisa akses read)
    Route::get('/kamar', [KamarController::class, 'index']);
    Route::get('/kamar/{id}', [KamarController::class, 'show']);
    Route::get('/kamar/statistics/dashboard', [KamarController::class, 'statistics']);

    // Kamar routes (hanya admin)
    Route::middleware('admin')->group(function () {
        Route::post('/kamar', [KamarController::class, 'store']);
        Route::put('/kamar/{id}', [KamarController::class, 'update']);
        Route::delete('/kamar/{id}', [KamarController::class, 'destroy']);
    });

    // User/Penyewa routes (hanya admin)
    Route::middleware('admin')->group(function () {
        Route::get('/users', [UserController::class, 'index']);
        Route::post('/users', [UserController::class, 'store']);
        Route::get('/users/{id}', [UserController::class, 'show']);
        Route::put('/users/{id}', [UserController::class, 'update']);
        Route::delete('/users/{id}', [UserController::class, 'destroy']);
    });

    // Pembayaran routes
    Route::get('/pembayaran', [PembayaranController::class, 'index']);
    Route::get('/pembayaran/{id}', [PembayaranController::class, 'show']);
    Route::get('/pembayaran/kamar/{kamar_id}', [PembayaranController::class, 'byKamar']);
    Route::get('/pembayaran/laporan/dashboard', [PembayaranController::class, 'laporan']);

    // Pembayaran routes (hanya admin)
    Route::middleware('admin')->group(function () {
        Route::post('/pembayaran', [PembayaranController::class, 'store']);
        Route::put('/pembayaran/{id}', [PembayaranController::class, 'update']);
        Route::delete('/pembayaran/{id}', [PembayaranController::class, 'destroy']);
    });
});
