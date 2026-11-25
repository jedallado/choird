<?php

namespace App\Models;

use App\Enums\Models\SongModelEnum;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

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

    /**
     * @return BelongsTo<User, $this>
     */
    public function createdByUser(): BelongsTo
    {
        return $this->belongsTo(User::class, SongModelEnum::createdByUserId());
    }
}
