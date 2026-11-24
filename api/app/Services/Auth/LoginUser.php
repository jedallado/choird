<?php

namespace App\Services\Auth;

use App\Enums\Models\UserModelEnum;
use App\Models\User;
use Illuminate\Auth\AuthenticationException;
use Illuminate\Support\Facades\Hash;
use Laravel\Sanctum\NewAccessToken;

class LoginUser
{
    /**
     * @return array{user: User, token: NewAccessToken}
     */
    public function handle(string $email, string $password): array
    {
        $user = User::query()
            ->whereRaw('lower('.UserModelEnum::email().') = ?', [mb_strtolower($email)])
            ->first();

        if (! $user || ! Hash::check($password, $user->getAuthPassword())) {
            throw new AuthenticationException('These credentials do not match our records.');
        }

        $minutes = (int) config('sanctum.expiration');
        $expiresAt = now()->addMinutes($minutes);

        return [
            'user' => $user,
            'token' => $user->createToken('api', ['*'], $expiresAt),
        ];
    }
}
