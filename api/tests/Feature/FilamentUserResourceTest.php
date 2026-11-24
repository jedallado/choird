<?php

namespace Tests\Feature;

use App\Enums\UserRole;
use App\Filament\Resources\UserResource;
use App\Filament\Resources\UserResource\Pages\CreateUser;
use App\Filament\Resources\UserResource\Pages\ListUsers;
use App\Mail\TemporaryPasswordMail;
use App\Models\User;
use Filament\Facades\Filament;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Facades\Mail;
use Livewire\Livewire;
use Tests\TestCase;

class FilamentUserResourceTest extends TestCase
{
    use RefreshDatabase;

    protected function setUp(): void
    {
        parent::setUp();

        Filament::setCurrentPanel(Filament::getPanel('admin'));
    }

    public function test_only_admins_can_open_user_management(): void
    {
        $admin = User::factory()->admin()->create();
        $manager = User::factory()->manager()->create();

        $this->actingAs($manager);
        $this->assertFalse(UserResource::canAccess());
        $this->get('/admin/users')->assertForbidden();

        $this->actingAs($admin);
        $this->assertTrue(UserResource::canAccess());
        $this->get('/admin/users')->assertOk();
    }

    public function test_an_admin_can_create_a_user_from_the_panel(): void
    {
        Mail::fake();

        $admin = User::factory()->admin()->create();

        Livewire::actingAs($admin)
            ->test(CreateUser::class)
            ->fillForm([
                'name' => 'New Singer',
                'email' => 'singer@example.com',
                'role' => UserRole::MEMBER->value,
            ])
            ->call('create')
            ->assertHasNoFormErrors();

        $singer = User::query()->where('email', 'singer@example.com')->first();

        $this->assertNotNull($singer);
        $this->assertSame(UserRole::MEMBER, $singer->role);

        Mail::assertSent(TemporaryPasswordMail::class, function (TemporaryPasswordMail $mail) use ($singer): bool {
            return $mail->hasTo('singer@example.com')
                && strlen($mail->temporaryPassword) === 6
                && Hash::check($mail->temporaryPassword, $singer->password);
        });
    }

    public function test_a_manager_cannot_open_the_user_list(): void
    {
        $manager = User::factory()->manager()->create();

        Livewire::actingAs($manager)
            ->test(ListUsers::class)
            ->assertForbidden();
    }
}
