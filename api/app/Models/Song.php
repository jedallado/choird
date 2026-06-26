<?php

namespace App\Models;

use App\Enums\Models\SongModelEnum;

class Song extends BaseModel
{
    /**
     * Get the model enum class name.
     *
     * @return class-string<SongModelEnum>
     */
    protected static function modelEnum(): string
    {
        return SongModelEnum::class;
    }
}
