<?php
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Route;
use App\Http\Controllers\UserController;
use App\Http\Controllers\PegawaiController;
use App\Http\Controllers\LogsController;
use App\Http\Controllers\RoleController;

// Route untuk login dan register (tanpa auth) - bisa di web atau api
Route::post('/login', [UserController::class, 'login']);


// Group dengan auth:sanctum
Route::middleware(['auth:sanctum'])->group(function () {

    // Logout
    Route::post('/logout', [UserController::class, 'logout']);
    Route::get('/user', function (Request $request) {
        return $request->user()->load(['pegawai', 'role']);
    });

    // Role routes - hanya untuk Kepala Dinas
    Route::middleware(['role:Kepala Dinas'])->group(function () {
        Route::apiResource('roles', RoleController::class);
        Route::apiResource('users', UserController::class); 
        Route::apiResource('pegawais', PegawaiController::class);
    });

    // 1. FITUR UMUM (Semua Pegawai: Kadis, Kabid, Staff)
    Route::get('/logs', [LogsController::class, 'index']); // Lihat log sendiri
    Route::post('/logs', [LogsController::class, 'store']); // Input log
    Route::get('/logs/{id}', [LogsController::class, 'show']);
    Route::put('/logs/{id}', [LogsController::class, 'update']);
    
    // 2. FITUR ATASAN (Hanya Kadis & Kabid)
    Route::middleware(['role:Kepala Dinas|Kepala Bidang'])->group(function () {
        
        // Melihat log bawahan 
        Route::get('/logs-bawahan', [LogsController::class, 'logBawahan']);
        
        // Verifikasi log (Setuju/Tolak)
        Route::put('/logs/{id}/verifikasi', [LogsController::class, 'verifikasi']);
    });

    // 3. Info User (Helper)
    Route::get('/list-pegawai', [PegawaiController::class, 'index']);


});