<?php

use App\Http\Controllers\Api\AuthController;
use App\Http\Controllers\Api\CategoryController;
use App\Http\Controllers\Api\CurrentUserController;
use App\Http\Controllers\Api\SetController;
use App\Http\Controllers\Api\SongController;
use App\Http\Controllers\Api\UserController;
use Illuminate\Support\Facades\Route;

Route::post('login', [AuthController::class, 'login'])->middleware('throttle:10,1');

Route::middleware('auth:sanctum')->group(function () {
    Route::post('logout', [AuthController::class, 'logout']);
    Route::get('user', [CurrentUserController::class, 'show']);
    Route::put('user', [CurrentUserController::class, 'update']);
    Route::apiResource('users', UserController::class);
    Route::apiResource('categories', CategoryController::class)->only(['index', 'show']);
    Route::apiResource('songs', SongController::class);
    Route::apiResource('sets', SetController::class);
});
