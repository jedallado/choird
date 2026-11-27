<?php

namespace App\Services\Song;

use App\Enums\Models\SongModelEnum;
use App\Models\Song;
use Illuminate\Support\Arr;
use Illuminate\Support\Facades\DB;

class UpdateSong
{
    /**
     * @param  array<string, mixed>  $data
     */
    public function handle(Song $song, array $data): Song
    {
        DB::transaction(function () use ($song, $data): void {
            $categoryIds = Arr::get($data, SongModelEnum::categoryIds());
            $songData = Arr::except($data, [SongModelEnum::categoryIds()]);

            if ($songData !== []) {
                $song->update($songData);
            }

            if (is_array($categoryIds)) {
                $song->categories()->sync($categoryIds);
            }
        });

        return $song->refresh()->load('categories');
    }
}
