<?php

use App\Enums\Models\SongModelEnum;
use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * Run the migrations.
     */
    public function up(): void
    {
        Schema::create(SongModelEnum::tableName(), function (Blueprint $table) {
            $table->id();
            $table->string(SongModelEnum::title());
            $table->string(SongModelEnum::artist())->nullable();
            $table->string(SongModelEnum::key(), 10)->nullable();
            $table->longText(SongModelEnum::content());
            $table->timestamps();
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists(SongModelEnum::tableName());
    }
};
