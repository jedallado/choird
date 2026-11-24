<?php

use App\Enums\Models\UserModelEnum;
use App\Enums\UserRole;
use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * Run the migrations.
     */
    public function up(): void
    {
        Schema::table(UserModelEnum::tableName(), function (Blueprint $table) {
            $table->string(UserModelEnum::role())
                ->default(UserRole::MEMBER->value)
                ->after(UserModelEnum::password());
        });

        DB::table(UserModelEnum::tableName())->update([
            UserModelEnum::role() => UserRole::ADMIN->value,
        ]);
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::table(UserModelEnum::tableName(), function (Blueprint $table) {
            $table->dropColumn(UserModelEnum::role());
        });
    }
};
