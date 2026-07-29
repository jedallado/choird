<?php

namespace App\Filament\Resources\SetResource\Pages;

use App\Enums\Models\SetModelEnum;
use App\Filament\Resources\SetResource;
use Filament\Resources\Pages\CreateRecord;

class CreateSet extends CreateRecord
{
    protected static string $resource = SetResource::class;

    /**
     * @param  array<string, mixed>  $data
     * @return array<string, mixed>
     */
    protected function mutateFormDataBeforeCreate(array $data): array
    {
        $data[SetModelEnum::createdByUserId()] = auth()->id();

        return $data;
    }
}
