<?php

namespace App\Models;

use App\Enums\Models\SetModelEnum;
use App\Enums\Models\SetSongModelEnum;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\HasMany;

class Set extends BaseModel
{
    /**
     * Get the model enum class name.
     *
     * @return class-string<SetModelEnum>
     */
    protected static function modelEnum(): string
    {
        return SetModelEnum::class;
    }

    /**
     * @return array<string, string>
     */
    protected function casts(): array
    {
        return [
            SetModelEnum::scheduledFor() => 'datetime',
        ];
    }

    /**
     * @return HasMany<SetSong, $this>
     */
    public function setSongs(): HasMany
    {
        return $this->hasMany(SetSong::class)
            ->orderBy(SetSongModelEnum::position());
    }

    /**
     * @return BelongsTo<User, $this>
     */
    public function createdByUser(): BelongsTo
    {
        return $this->belongsTo(User::class, SetModelEnum::createdByUserId());
    }
}
