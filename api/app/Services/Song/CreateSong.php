<?php

namespace App\Services\Song;

use App\Enums\Models\SongModelEnum;
use App\Models\Song;
use Illuminate\Support\Arr;
use Illuminate\Support\Facades\DB;

class CreateSong
{
    /**
     * @param  array<string, mixed>  $data
     */
    public function handle(array $data): Song
    {
        $song = DB::transaction(function () use ($data): Song {
            $categoryIds = Arr::get($data, SongModelEnum::categoryIds());
            $songData = Arr::except($data, [SongModelEnum::categoryIds()]);

            $song = Song::create($songData);

            if (is_array($categoryIds)) {
                $song->categories()->sync($categoryIds);
            }

            return $song;
        });

        return $song->refresh()->load('categories');
    }
}
