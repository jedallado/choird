<?php

namespace App\Services\Song;

use App\Models\Song;

class UpdateSong
{
    /**
     * @param  array<string, mixed>  $data
     */
    public function handle(Song $song, array $data): Song
    {
        $song->update($data);

        return $song->fresh();
    }
}
