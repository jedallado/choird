<?php

namespace App\Services\User;

use App\Enums\Models\UserModelEnum;
use App\Mail\TemporaryPasswordMail;
use App\Models\User;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Mail;
use Illuminate\Support\Str;

class CreateUserWithTemporaryPassword
{
    public function __construct(private CreateUser $createUser) {}

    /**
     * @param  array<string, mixed>  $data
     */
    public function handle(array $data): User
    {
        $password = Str::password(6, symbols: false);

        return DB::transaction(function () use ($data, $password): User {
            $user = $this->createUser->handle([
                ...$data,
                UserModelEnum::password() => $password,
            ]);

            Mail::to($user)->send(new TemporaryPasswordMail($user, $password));

            return $user;
        });
    }
}
