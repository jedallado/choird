<?php

namespace Database\Factories;

use App\Enums\Models\UserModelEnum;
use App\Enums\UserRole;
use App\Models\User;
use Illuminate\Database\Eloquent\Factories\Factory;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Str;

/**
 * @extends Factory<User>
 */
class UserFactory extends Factory
{
    /**
     * The current password being used by the factory.
     */
    protected static ?string $password;

    /**
     * Define the model's default state.
     *
     * @return array<string, mixed>
     */
    public function definition(): array
    {
        return [
            UserModelEnum::name() => fake()->name(),
            UserModelEnum::email() => fake()->unique()->safeEmail(),
            UserModelEnum::emailVerifiedAt() => now(),
            UserModelEnum::password() => static::$password ??= Hash::make('password'),
            UserModelEnum::role() => UserRole::MEMBER,
            UserModelEnum::rememberToken() => Str::random(10),
        ];
    }

    public function admin(): static
    {
        return $this->state(fn (array $attributes) => [
            UserModelEnum::role() => UserRole::ADMIN,
        ]);
    }

    public function manager(): static
    {
        return $this->state(fn (array $attributes) => [
            UserModelEnum::role() => UserRole::MANAGER,
        ]);
    }

    /**
     * Indicate that the model's email address should be unverified.
     */
    public function unverified(): static
    {
        return $this->state(fn (array $attributes) => [
            'email_verified_at' => null,
        ]);
    }
}
