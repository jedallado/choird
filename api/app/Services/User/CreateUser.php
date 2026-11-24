<?php

namespace App\Services\User;

use App\Enums\Models\UserModelEnum;
use App\Models\User;
use Illuminate\Support\Arr;

class CreateUser
{
    /**
     * @param  array<string, mixed>  $data
     */
    public function handle(array $data): User
    {
        return User::create(Arr::only($data, UserModelEnum::fillable()));
    }
}
