<?php

namespace App\Services\Song;

use App\Models\Song;

class DeleteSong
{
    public function handle(Song $song): void
    {
        $song->delete();
    }
}
