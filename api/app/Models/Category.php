<?php

namespace App\Models;

use App\Enums\Models\CategoryModelEnum;
use App\Enums\Models\CategorySongModelEnum;
use Illuminate\Database\Eloquent\Relations\BelongsToMany;

class Category extends BaseModel
{
    /**
     * Get the model enum class name.
     *
     * @return class-string<CategoryModelEnum>
     */
    protected static function modelEnum(): string
    {
        return CategoryModelEnum::class;
    }

    /**
     * @return BelongsToMany<Song, $this>
     */
    public function songs(): BelongsToMany
    {
        return $this->belongsToMany(
            Song::class,
            CategorySongModelEnum::tableName(),
            CategorySongModelEnum::categoryId(),
            CategorySongModelEnum::songId(),
        );
    }
}
