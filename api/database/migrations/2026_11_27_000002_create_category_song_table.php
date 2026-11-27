<?php

use App\Enums\Models\CategoryModelEnum;
use App\Enums\Models\CategorySongModelEnum;
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
        Schema::create(CategorySongModelEnum::tableName(), function (Blueprint $table) {
            $table->id();
            $table->foreignId(CategorySongModelEnum::categoryId())
                ->constrained(CategoryModelEnum::tableName())
                ->cascadeOnUpdate()
                ->restrictOnDelete();
            $table->foreignId(CategorySongModelEnum::songId())
                ->constrained(SongModelEnum::tableName())
                ->cascadeOnUpdate()
                ->cascadeOnDelete();
            $table->unique([
                CategorySongModelEnum::categoryId(),
                CategorySongModelEnum::songId(),
            ]);
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists(CategorySongModelEnum::tableName());
    }
};
