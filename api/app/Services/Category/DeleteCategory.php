<?php

namespace App\Services\Category;

use App\Enums\Models\CategoryModelEnum;
use App\Models\Category;
use Illuminate\Database\QueryException;
use Illuminate\Validation\ValidationException;

class DeleteCategory
{
    public const IN_USE_MESSAGE = 'This category cannot be deleted while songs still use it.';

    public function denialReason(Category $category): ?string
    {
        if ($category->songs()->exists()) {
            return self::IN_USE_MESSAGE;
        }

        return null;
    }

    public function handle(Category $category): void
    {
        $reason = $this->denialReason($category);

        if ($reason !== null) {
            throw ValidationException::withMessages([
                CategoryModelEnum::name() => $reason,
            ]);
        }

        try {
            $category->delete();
        } catch (QueryException) {
            throw ValidationException::withMessages([
                CategoryModelEnum::name() => self::IN_USE_MESSAGE,
            ]);
        }
    }
}
