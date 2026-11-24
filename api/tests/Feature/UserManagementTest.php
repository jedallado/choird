<?php

namespace Tests\Feature;

use App\Enums\Models\SetModelEnum;
use App\Enums\UserRole;
use App\Models\Set;
use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

class UserManagementTest extends TestCase
{
    use RefreshDatabase;

    public function test_only_admins_can_manage_users(): void
    {
        $admin = User::factory()->admin()->create();
        $manager = User::factory()->manager()->create();
        $member = User::factory()->create();

        $payload = [
            'name' => 'New Singer',
            'email' => 'new@example.com',
            'password' => 'password123',
            'passwordConfirmation' => 'password123',
            'role' => 'member',
        ];

        $this->withBearer($manager->createToken('api')->plainTextToken)
            ->postJson('/api/users', $payload)
            ->assertForbidden();

        $this->withBearer($member->createToken('api')->plainTextToken)
            ->getJson('/api/users')
            ->assertForbidden();

        $this->withBearer($admin->createToken('api')->plainTextToken)
            ->postJson('/api/users', $payload)
            ->assertCreated()
            ->assertJsonPath('data.role', 'member')
            ->assertJsonPath('data.email', 'new@example.com');
    }

    public function test_the_last_admin_cannot_be_demoted_or_deleted(): void
    {
        $admin = User::factory()->admin()->create();
        $token = $admin->createToken('api')->plainTextToken;

        $this->withBearer($token)->putJson('/api/users/'.$admin->id, [
            'role' => UserRole::MANAGER->value,
        ])->assertUnprocessable()
            ->assertJsonValidationErrors(['role']);

        $this->withBearer($token)->deleteJson('/api/users/'.$admin->id)
            ->assertUnprocessable()
            ->assertJsonValidationErrors(['user']);

        $this->assertTrue($admin->refresh()->isAdmin());
    }

    public function test_an_admin_can_demote_another_admin_when_one_remains(): void
    {
        $admin = User::factory()->admin()->create();
        $other = User::factory()->admin()->create();

        $this->withBearer($admin->createToken('api')->plainTextToken)
            ->putJson('/api/users/'.$other->id, [
                'role' => UserRole::MEMBER->value,
            ])->assertOk()
            ->assertJsonPath('data.role', 'member');
    }

    public function test_an_admin_cannot_delete_a_user_who_created_a_set(): void
    {
        $admin = User::factory()->admin()->create();
        $manager = User::factory()->manager()->create();

        Set::create([
            SetModelEnum::scheduledFor() => now(),
            SetModelEnum::createdByUserId() => $manager->id,
        ]);

        $this->withBearer($admin->createToken('api')->plainTextToken)
            ->deleteJson('/api/users/'.$manager->id)
            ->assertUnprocessable()
            ->assertJsonValidationErrors(['user']);

        $this->assertModelExists($manager);
    }
}
