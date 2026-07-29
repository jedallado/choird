<?php

namespace App\Http\Resources;

use App\Enums\Models\SetModelEnum;
use App\Enums\Models\SetSongModelEnum;
use App\Enums\Models\SongModelEnum;
use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class SetResource extends JsonResource
{
    /**
     * @return array<string, mixed>
     */
    public function toArray(Request $request): array
    {
        return [
            'id' => $this->id,
            'name' => $this->getAttribute(SetModelEnum::name()),
            'scheduledFor' => $this->getAttribute(SetModelEnum::scheduledFor()),
            'createdByUserId' => $this->getAttribute(SetModelEnum::createdByUserId()),
            'notes' => $this->getAttribute(SetModelEnum::notes()),
            'setSongs' => $this->whenLoaded('setSongs', function (): array {
                return $this->setSongs->map(function ($setSong): array {
                    return [
                        'id' => $setSong->id,
                        'songId' => $setSong->getAttribute(SetSongModelEnum::songId()),
                        'position' => $setSong->getAttribute(SetSongModelEnum::position()),
                        'song' => $setSong->relationLoaded('song') && $setSong->song !== null ? [
                            'id' => $setSong->song->id,
                            'title' => $setSong->song->getAttribute(SongModelEnum::title()),
                            'artist' => $setSong->song->getAttribute(SongModelEnum::artist()),
                            'key' => $setSong->song->getAttribute(SongModelEnum::key()),
                            'capo' => $setSong->song->getAttribute(SongModelEnum::capo()),
                            'keyboardTranspose' => $setSong->song->getAttribute(SongModelEnum::keyboardTranspose()),
                        ] : null,
                    ];
                })->all();
            }, []),
            'createdAt' => $this->getAttribute(SetModelEnum::createdAt()),
            'updatedAt' => $this->getAttribute(SetModelEnum::updatedAt()),
        ];
    }
}
