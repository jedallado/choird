<?php

namespace App\Http\Resources;

use App\Enums\Models\SongModelEnum;
use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class SongResource extends JsonResource
{
    /**
     * @return array<string, mixed>
     */
    public function toArray(Request $request): array
    {
        return [
            'id' => $this->id,
            'title' => $this->getAttribute(SongModelEnum::title()),
            'artist' => $this->getAttribute(SongModelEnum::artist()),
            'key' => $this->getAttribute(SongModelEnum::key()),
            'content' => $this->getAttribute(SongModelEnum::content()),
            'createdAt' => $this->getAttribute(SongModelEnum::createdAt()),
            'updatedAt' => $this->getAttribute(SongModelEnum::updatedAt()),
        ];
    }
}
