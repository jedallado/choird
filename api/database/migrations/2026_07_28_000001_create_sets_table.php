<?php

use App\Enums\Models\SetModelEnum;
use App\Models\User;
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
        Schema::create(SetModelEnum::tableName(), function (Blueprint $table) {
            $table->id();
            $table->string(SetModelEnum::name())->nullable();
            $table->timestamp(SetModelEnum::scheduledFor());
            $table->foreignId(SetModelEnum::createdByUserId())
                ->constrained((new User())->getTable())
                ->cascadeOnUpdate()
                ->restrictOnDelete();
            $table->text(SetModelEnum::notes())->nullable();
            $table->timestamps();

            $table->unique(SetModelEnum::scheduledFor());
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists(SetModelEnum::tableName());
    }
};
