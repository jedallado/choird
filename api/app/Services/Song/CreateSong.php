<?php

namespace App\Services\Song;

use App\Models\Song;

class CreateSong
{
    /**
     * @param  array<string, mixed>  $data
     */
    public function handle(array $data): Song
    {
        $song = Song::create($data);

        return $song;
    }
}
