<?php

use App\Http\Controllers\Api\SongController;
use Illuminate\Support\Facades\Route;

Route::apiResource('songs', SongController::class);
