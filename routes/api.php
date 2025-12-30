<?php

use App\Http\Controllers\ProvinsiController;
use Illuminate\Support\Facades\Route;

Route::prefix('provinsi')->controller(ProvinsiController::class)->group(function () {
    Route::get('/', 'index');
    Route::get('/{code}', 'show');
    Route::post('/', 'store');
    Route::put('/{code}', 'update');
    Route::delete('/{code}', 'destroy');
});
