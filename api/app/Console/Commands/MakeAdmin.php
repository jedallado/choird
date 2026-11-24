<?php

namespace App\Console\Commands;

use App\Enums\Models\UserModelEnum;
use App\Enums\UserRole;
use App\Services\User\CreateUser;
use Illuminate\Console\Command;
use Illuminate\Support\Facades\Validator;
use Illuminate\Validation\Rule;

class MakeAdmin extends Command
{
    protected $signature = 'choird:make-admin';

    protected $description = 'Create an admin who can sign in to the API and the admin panel';

    public function handle(CreateUser $createUser): int
    {
        $data = [
            UserModelEnum::name() => $this->ask('Name'),
            UserModelEnum::email() => $this->ask('Email'),
            UserModelEnum::password() => $this->secret('Password'),
            UserModelEnum::role() => UserRole::ADMIN->value,
        ];

        $validator = Validator::make($data, [
            UserModelEnum::name() => 'required|string|max:255',
            UserModelEnum::email() => [
                'required',
                'string',
                'email',
                'max:255',
                Rule::unique(UserModelEnum::tableName(), UserModelEnum::email()),
            ],
            UserModelEnum::password() => 'required|string|min:8',
            UserModelEnum::role() => ['required', Rule::enum(UserRole::class)],
        ]);

        if ($validator->fails()) {
            foreach ($validator->errors()->all() as $error) {
                $this->error($error);
            }

            return self::FAILURE;
        }

        $user = $createUser->handle($validator->validated());

        $this->info('Admin '.$user->getAttribute(UserModelEnum::email()).' created.');

        return self::SUCCESS;
    }
}
