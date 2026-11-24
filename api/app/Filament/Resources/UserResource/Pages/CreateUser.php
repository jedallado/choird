<?php

namespace App\Filament\Resources\UserResource\Pages;

use App\Filament\Resources\UserResource;
use App\Services\User\CreateUserWithTemporaryPassword;
use Filament\Resources\Pages\CreateRecord;
use Illuminate\Database\Eloquent\Model;

class CreateUser extends CreateRecord
{
    protected static string $resource = UserResource::class;

    protected function handleRecordCreation(array $data): Model
    {
        return app(CreateUserWithTemporaryPassword::class)->handle($data);
    }

    protected function getCreatedNotificationTitle(): ?string
    {
        return 'User created. A temporary password was emailed to them.';
    }
}
