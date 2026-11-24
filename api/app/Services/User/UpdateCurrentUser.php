<?php

namespace App\Services\User;

use App\Enums\Models\UserModelEnum;
use App\Models\User;
use Illuminate\Support\Arr;

class UpdateCurrentUser
{
    /**
     * @param  array<string, mixed>  $data
     */
    public function handle(User $user, array $data): User
    {
        $updates = Arr::only($data, [
            UserModelEnum::name(),
            UserModelEnum::email(),
            UserModelEnum::password(),
        ]);

        if (($updates[UserModelEnum::password()] ?? null) === null || $updates[UserModelEnum::password()] === '') {
            unset($updates[UserModelEnum::password()]);
        }

        $user->update($updates);

        return $user->refresh();
    }
}
