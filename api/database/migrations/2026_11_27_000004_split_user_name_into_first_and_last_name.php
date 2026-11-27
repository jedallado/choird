<?php

use App\Enums\Models\UserModelEnum;
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
        Schema::table(UserModelEnum::tableName(), function (Blueprint $table) {
            $table->renameColumn('name', UserModelEnum::firstName());
        });

        Schema::table(UserModelEnum::tableName(), function (Blueprint $table) {
            $table->string(UserModelEnum::lastName())->nullable()->after(UserModelEnum::firstName());
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::table(UserModelEnum::tableName(), function (Blueprint $table) {
            $table->dropColumn(UserModelEnum::lastName());
        });

        Schema::table(UserModelEnum::tableName(), function (Blueprint $table) {
            $table->renameColumn(UserModelEnum::firstName(), 'name');
        });
    }
};
