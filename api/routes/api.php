<?php

use App\Http\Controllers\Api\SongController;
use App\Http\Controllers\Api\SetController;
use Illuminate\Support\Facades\Route;

Route::apiResource('songs', SongController::class);
Route::apiResource('sets', SetController::class);
