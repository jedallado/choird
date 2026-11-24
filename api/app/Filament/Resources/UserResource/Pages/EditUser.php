<?php

namespace App\Filament\Resources\UserResource\Pages;

use App\Filament\Resources\UserResource;
use App\Services\User\UpdateUser;
use Filament\Resources\Pages\EditRecord;
use Illuminate\Database\Eloquent\Model;

class EditUser extends EditRecord
{
    protected static string $resource = UserResource::class;

    protected function getHeaderActions(): array
    {
        return [
            UserResource::deleteAction(),
        ];
    }

    protected function handleRecordUpdate(Model $record, array $data): Model
    {
        return app(UpdateUser::class)->handle($record, $data);
    }
}
