<?php

namespace App\Services\User;

use App\Enums\Models\UserModelEnum;
use App\Models\User;
use Illuminate\Validation\ValidationException;

class DeleteUser
{
    public function denialReason(User $actor, User $user): ?string
    {
        if ($actor->is($user)) {
            return 'You cannot delete your own account.';
        }

        if ($user->isLastAdmin()) {
            return 'The last admin cannot be deleted.';
        }

        if ($user->sets()->exists()) {
            return 'This user cannot be deleted while they still have set lists.';
        }

        return null;
    }

    public function handle(User $actor, User $user): void
    {
        $reason = $this->denialReason($actor, $user);

        if ($reason !== null) {
            $key = $user->isLastAdmin() && ! $actor->is($user)
                ? UserModelEnum::role()
                : 'user';

            throw ValidationException::withMessages([
                $key => $reason,
            ]);
        }

        $user->tokens()->delete();
        $user->delete();
    }
}
