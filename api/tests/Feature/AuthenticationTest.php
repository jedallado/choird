<?php

namespace Tests\Feature;

use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Support\Carbon;
use Tests\TestCase;

class AuthenticationTest extends TestCase
{
    use RefreshDatabase;

    public function test_login_returns_a_token_that_lasts_seven_days(): void
    {
        $user = User::factory()->create([
            'email' => 'singer@example.com',
        ]);

        $response = $this->postJson('/api/login', [
            'email' => 'Singer@Example.com',
            'password' => 'password',
        ]);

        $response->assertOk()
            ->assertJsonPath('tokenType', 'Bearer')
            ->assertJsonPath('user.email', 'singer@example.com')
            ->assertJsonPath('user.role', 'member')
            ->assertJsonMissingPath('user.password');

        $expiresAt = Carbon::parse($response->json('expiresAt'));
        $this->assertTrue($expiresAt->between(
            now()->addDays(7)->subMinute(),
            now()->addDays(7)->addMinute(),
        ));

        $token = $response->json('token');

        $this->travel(6)->days();
        $this->withBearer($token)->getJson('/api/songs')->assertOk();

        $this->travelBack();
        $this->travel(8)->days();
        $this->withBearer($token)->getJson('/api/songs')->assertUnauthorized();
    }

    public function test_login_rejects_bad_credentials(): void
    {
        User::factory()->create([
            'email' => 'singer@example.com',
        ]);

        $this->postJson('/api/login', [
            'email' => 'singer@example.com',
            'password' => 'wrong-password',
        ])->assertUnauthorized()
            ->assertJsonPath('message', 'These credentials do not match our records.');
    }

    public function test_logout_revokes_the_current_token(): void
    {
        $user = User::factory()->create();
        $token = $user->createToken('api')->plainTextToken;

        $this->withBearer($token)->postJson('/api/logout')->assertNoContent();
        $this->withBearer($token)->getJson('/api/user')->assertUnauthorized();
    }

    public function test_a_user_can_update_their_own_profile_but_not_their_role(): void
    {
        $user = User::factory()->create([
            'email' => 'singer@example.com',
        ]);
        $token = $user->createToken('api')->plainTextToken;

        $this->withBearer($token)->putJson('/api/user', [
            'firstName' => 'New',
            'lastName' => 'Name',
            'role' => 'admin',
        ])->assertOk()
            ->assertJsonPath('data.name', 'New Name')
            ->assertJsonPath('data.firstName', 'New')
            ->assertJsonPath('data.lastName', 'Name')
            ->assertJsonPath('data.role', 'member');

        $user->refresh();
        $this->assertSame('member', $user->role->value);
        $this->assertSame('New Name', $user->name);
    }

    public function test_changing_a_password_requires_the_current_password(): void
    {
        $user = User::factory()->create([
            'email' => 'singer@example.com',
        ]);
        $token = $user->createToken('api')->plainTextToken;

        $this->withBearer($token)->putJson('/api/user', [
            'password' => 'new-password',
            'passwordConfirmation' => 'new-password',
        ])->assertUnprocessable()
            ->assertJsonValidationErrors(['current_password']);

        $this->withBearer($token)->putJson('/api/user', [
            'password' => 'new-password',
            'passwordConfirmation' => 'new-password',
            'currentPassword' => 'password',
        ])->assertOk();

        $this->postJson('/api/login', [
            'email' => 'singer@example.com',
            'password' => 'new-password',
        ])->assertOk();
    }

    public function test_catalog_routes_require_authentication(): void
    {
        $this->getJson('/api/songs')->assertUnauthorized();
        $this->getJson('/api/sets')->assertUnauthorized();
    }

    public function test_panel_access_is_limited_to_admins_and_managers(): void
    {
        $panel = filament()->getDefaultPanel();

        $this->assertTrue(User::factory()->admin()->create()->canAccessPanel($panel));
        $this->assertTrue(User::factory()->manager()->create()->canAccessPanel($panel));
        $this->assertFalse(User::factory()->create()->canAccessPanel($panel));
    }
}
