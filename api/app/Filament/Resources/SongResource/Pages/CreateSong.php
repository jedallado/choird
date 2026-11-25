<?php

namespace App\Filament\Resources\SongResource\Pages;

use App\Enums\Models\SongModelEnum;
use App\Filament\Resources\SongResource;
use Filament\Resources\Pages\CreateRecord;

class CreateSong extends CreateRecord
{
    protected static string $resource = SongResource::class;

    /**
     * @param  array<string, mixed>  $data
     * @return array<string, mixed>
     */
    protected function mutateFormDataBeforeCreate(array $data): array
    {
        $data[SongModelEnum::createdByUserId()] = auth()->id();

        return $data;
    }
}
