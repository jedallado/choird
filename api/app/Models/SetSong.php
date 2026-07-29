<?php

namespace App\Models;

use App\Enums\Models\SetSongModelEnum;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class SetSong extends BaseModel
{
    /**
     * Get the model enum class name.
     *
     * @return class-string<SetSongModelEnum>
     */
    protected static function modelEnum(): string
    {
        return SetSongModelEnum::class;
    }

    /**
     * @return BelongsTo<Set, $this>
     */
    public function set(): BelongsTo
    {
        return $this->belongsTo(Set::class, SetSongModelEnum::setId());
    }

    /**
     * @return BelongsTo<Song, $this>
     */
    public function song(): BelongsTo
    {
        return $this->belongsTo(Song::class, SetSongModelEnum::songId());
    }
}
