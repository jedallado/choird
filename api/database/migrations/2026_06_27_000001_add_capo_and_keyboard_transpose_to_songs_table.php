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
            $table->unsignedTinyInteger(SongModelEnum::capo())->nullable()->after(SongModelEnum::key());
            $table->tinyInteger(SongModelEnum::keyboardTranspose())->nullable()->after(SongModelEnum::capo());
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::table(SongModelEnum::tableName(), function (Blueprint $table) {
            $table->dropColumn([
                SongModelEnum::capo(),
                SongModelEnum::keyboardTranspose(),
            ]);
        });
    }
};
