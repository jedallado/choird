<?php

namespace App\Services\Auth;

use App\Models\User;
use Laravel\Sanctum\PersonalAccessToken;

class LogoutUser
{
    public function handle(User $user): void
    {
        $token = $user->currentAccessToken();

        if ($token instanceof PersonalAccessToken) {
            $token->delete();
        }
    }
}
