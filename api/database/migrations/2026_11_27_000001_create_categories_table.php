<?php

use App\Enums\Models\CategoryModelEnum;
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
        Schema::create(CategoryModelEnum::tableName(), function (Blueprint $table) {
            $table->id();
            $table->string(CategoryModelEnum::name())->unique();
            $table->timestamps();
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists(CategoryModelEnum::tableName());
    }
};
