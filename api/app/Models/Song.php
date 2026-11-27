<?php

namespace App\Models;

use App\Enums\Models\CategoryModelEnum;
use App\Enums\Models\CategorySongModelEnum;
use App\Enums\Models\SongModelEnum;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\BelongsToMany;

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

    /**
     * @return BelongsToMany<Category, $this>
     */
    public function categories(): BelongsToMany
    {
        return $this->belongsToMany(
            Category::class,
            CategorySongModelEnum::tableName(),
            CategorySongModelEnum::songId(),
            CategorySongModelEnum::categoryId(),
        )->orderBy(CategoryModelEnum::tableName().'.'.CategoryModelEnum::name());
    }
}
