<?php

namespace App\Services\Set;

use App\Enums\Models\SetModelEnum;
use App\Models\Set;
use Illuminate\Support\Arr;
use Illuminate\Support\Facades\DB;

class CreateSet
{
    /**
     * @param  array<string, mixed>  $data
     */
    public function handle(array $data): Set
    {
        /** @var Set $set */
        $set = DB::transaction(function () use ($data): Set {
            $setSongs = Arr::get($data, SetModelEnum::setSongs(), []);
            $setData = Arr::except($data, [SetModelEnum::setSongs()]);

            $set = Set::create($setData);

            if (is_array($setSongs) && $setSongs !== []) {
                $set->setSongs()->createMany($setSongs);
            }

            return $set;
        });

        return $set->fresh(['setSongs.song']);
    }
}
