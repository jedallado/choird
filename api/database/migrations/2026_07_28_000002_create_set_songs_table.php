<?php

use App\Enums\Models\SetModelEnum;
use App\Enums\Models\SetSongModelEnum;
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
        Schema::create(SetSongModelEnum::tableName(), function (Blueprint $table) {
            $table->id();
            $table->foreignId(SetSongModelEnum::setId())
                ->constrained(SetModelEnum::tableName())
                ->cascadeOnUpdate()
                ->cascadeOnDelete();
            $table->foreignId(SetSongModelEnum::songId())
                ->constrained(SongModelEnum::tableName())
                ->cascadeOnUpdate()
                ->restrictOnDelete();
            $table->unsignedSmallInteger(SetSongModelEnum::position());
            $table->timestamps();

            $table->unique([
                SetSongModelEnum::setId(),
                SetSongModelEnum::position(),
            ]);
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists(SetSongModelEnum::tableName());
    }
};
