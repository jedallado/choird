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
        Schema::table(SongModelEnum::tableName(), function (Blueprint $table) {
            $table->string(SongModelEnum::sopranoUrl(), 2048)
                ->nullable()
                ->after(SongModelEnum::content());
            $table->string(SongModelEnum::altoUrl(), 2048)
                ->nullable()
                ->after(SongModelEnum::sopranoUrl());
            $table->string(SongModelEnum::tenorUrl(), 2048)
                ->nullable()
                ->after(SongModelEnum::altoUrl());
            $table->string(SongModelEnum::bassUrl(), 2048)
                ->nullable()
                ->after(SongModelEnum::tenorUrl());
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::table(SongModelEnum::tableName(), function (Blueprint $table) {
            $table->dropColumn([
                SongModelEnum::sopranoUrl(),
                SongModelEnum::altoUrl(),
                SongModelEnum::tenorUrl(),
                SongModelEnum::bassUrl(),
            ]);
        });
    }
};
