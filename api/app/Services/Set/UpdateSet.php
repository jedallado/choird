<?php

namespace App\Services\Set;

use App\Enums\Models\SetModelEnum;
use App\Models\Set;
use Illuminate\Support\Arr;
use Illuminate\Support\Facades\DB;

class UpdateSet
{
    /**
     * @param  array<string, mixed>  $data
     */
    public function handle(Set $set, array $data): Set
    {
        DB::transaction(function () use ($set, $data): void {
            $setData = Arr::except($data, [SetModelEnum::setSongs()]);
            $setSongs = Arr::get($data, SetModelEnum::setSongs());

            if ($setData !== []) {
                $set->update($setData);
            }

            if (is_array($setSongs)) {
                $set->setSongs()->delete();
                $set->setSongs()->createMany($setSongs);
            }
        });

        return $set->fresh(['setSongs.song']);
    }
}
