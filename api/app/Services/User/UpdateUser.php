<?php

namespace App\Services\User;

use App\Enums\Models\UserModelEnum;
use App\Enums\UserRole;
use App\Models\User;
use Illuminate\Support\Arr;
use Illuminate\Validation\ValidationException;

class UpdateUser
{
    /**
     * @param  array<string, mixed>  $data
     */
    public function handle(User $user, array $data): User
    {
        $updates = Arr::only($data, UserModelEnum::fillable());

        if (($updates[UserModelEnum::password()] ?? null) === null || $updates[UserModelEnum::password()] === '') {
            unset($updates[UserModelEnum::password()]);
        }

        $nextRole = $updates[UserModelEnum::role()] ?? null;

        if ($nextRole !== null && $nextRole !== UserRole::ADMIN->value && $user->isLastAdmin()) {
            throw ValidationException::withMessages([
                UserModelEnum::role() => 'The last admin cannot be demoted.',
            ]);
        }

        $user->update($updates);

        return $user->refresh();
    }
}
