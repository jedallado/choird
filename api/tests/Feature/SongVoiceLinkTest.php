<?php

namespace Tests\Feature;

use App\Enums\Models\SongModelEnum;
use App\Filament\Resources\SongResource\Pages\CreateSong;
use App\Filament\Resources\SongResource\Pages\EditSong;
use App\Models\Song;
use App\Models\User;
use Filament\Facades\Filament;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Livewire\Livewire;
use Tests\TestCase;

class SongVoiceLinkTest extends TestCase
{
    use RefreshDatabase;

    protected function setUp(): void
    {
        parent::setUp();

        Filament::setCurrentPanel(Filament::getPanel('admin'));
    }

    public function test_a_song_can_be_created_with_a_link_for_each_voice(): void
    {
        $manager = User::factory()->manager()->create();

        $this->withBearer($manager->createToken('api')->plainTextToken)
            ->postJson('/api/songs', [
                'title' => 'Amazing Grace',
                'content' => '[G]Amazing grace',
                'sopranoUrl' => 'https://www.youtube.com/watch?v=soprano',
                'altoUrl' => 'https://youtu.be/alto',
                'tenorUrl' => 'http://example.com/tenor',
                'bassUrl' => 'https://example.com/bass',
            ])
            ->assertCreated()
            ->assertJsonPath('data.sopranoUrl', 'https://www.youtube.com/watch?v=soprano')
            ->assertJsonPath('data.altoUrl', 'https://youtu.be/alto')
            ->assertJsonPath('data.tenorUrl', 'http://example.com/tenor')
            ->assertJsonPath('data.bassUrl', 'https://example.com/bass');

        $this->assertDatabaseHas(SongModelEnum::tableName(), [
            SongModelEnum::title() => 'Amazing Grace',
            SongModelEnum::sopranoUrl() => 'https://www.youtube.com/watch?v=soprano',
            SongModelEnum::altoUrl() => 'https://youtu.be/alto',
            SongModelEnum::tenorUrl() => 'http://example.com/tenor',
            SongModelEnum::bassUrl() => 'https://example.com/bass',
        ]);
    }

    public function test_voice_links_are_optional(): void
    {
        $member = User::factory()->create();
        $song = Song::create([
            SongModelEnum::title() => 'Amazing Grace',
            SongModelEnum::content() => '[G]Amazing grace',
        ]);

        $this->withBearer($member->createToken('api')->plainTextToken)
            ->getJson('/api/songs/'.$song->id)
            ->assertOk()
            ->assertJsonPath('data.sopranoUrl', null)
            ->assertJsonPath('data.altoUrl', null)
            ->assertJsonPath('data.tenorUrl', null)
            ->assertJsonPath('data.bassUrl', null);
    }

    public function test_updating_one_voice_link_leaves_the_others_in_place(): void
    {
        $manager = User::factory()->manager()->create();
        $token = $manager->createToken('api')->plainTextToken;
        $song = Song::create([
            SongModelEnum::title() => 'Amazing Grace',
            SongModelEnum::content() => '[G]Amazing grace',
            SongModelEnum::sopranoUrl() => 'https://example.com/soprano',
            SongModelEnum::altoUrl() => 'https://example.com/alto',
        ]);

        $this->withBearer($token)
            ->putJson('/api/songs/'.$song->id, [
                'tenorUrl' => 'https://example.com/tenor',
            ])
            ->assertOk()
            ->assertJsonPath('data.sopranoUrl', 'https://example.com/soprano')
            ->assertJsonPath('data.altoUrl', 'https://example.com/alto')
            ->assertJsonPath('data.tenorUrl', 'https://example.com/tenor')
            ->assertJsonPath('data.bassUrl', null);

        $this->withBearer($token)
            ->putJson('/api/songs/'.$song->id, [
                'sopranoUrl' => null,
            ])
            ->assertOk()
            ->assertJsonPath('data.sopranoUrl', null)
            ->assertJsonPath('data.altoUrl', 'https://example.com/alto');
    }

    public function test_a_voice_link_must_be_a_web_address(): void
    {
        $manager = User::factory()->manager()->create();

        $this->withBearer($manager->createToken('api')->plainTextToken)
            ->postJson('/api/songs', [
                'title' => 'Amazing Grace',
                'content' => '[G]Amazing grace',
                'sopranoUrl' => 'not a link',
                'altoUrl' => 'ftp://example.com/alto',
            ])
            ->assertUnprocessable()
            ->assertJsonValidationErrors([
                SongModelEnum::sopranoUrl(),
                SongModelEnum::altoUrl(),
            ]);
    }

    public function test_an_admin_can_set_voice_links_from_the_panel(): void
    {
        $admin = User::factory()->admin()->create();

        Livewire::actingAs($admin)
            ->test(CreateSong::class)
            ->fillForm([
                SongModelEnum::title() => 'Amazing Grace',
                SongModelEnum::content() => '[G]Amazing grace',
                SongModelEnum::sopranoUrl() => 'https://www.youtube.com/watch?v=soprano',
                SongModelEnum::altoUrl() => 'https://youtu.be/alto',
            ])
            ->call('create')
            ->assertHasNoFormErrors();

        $song = Song::query()->firstOrFail();

        $this->assertSame(
            'https://www.youtube.com/watch?v=soprano',
            $song->getAttribute(SongModelEnum::sopranoUrl()),
        );
        $this->assertSame(
            'https://youtu.be/alto',
            $song->getAttribute(SongModelEnum::altoUrl()),
        );
        $this->assertNull($song->getAttribute(SongModelEnum::tenorUrl()));
        $this->assertNull($song->getAttribute(SongModelEnum::bassUrl()));
    }

    public function test_an_admin_can_clear_a_voice_link(): void
    {
        $admin = User::factory()->admin()->create();
        $this->actingAs($admin);

        $song = Song::create([
            SongModelEnum::title() => 'Amazing Grace',
            SongModelEnum::content() => '[G]Amazing grace',
            SongModelEnum::sopranoUrl() => 'https://example.com/soprano',
            SongModelEnum::createdByUserId() => $admin->id,
        ]);

        Livewire::test(EditSong::class, ['record' => $song->id])
            ->fillForm([
                SongModelEnum::sopranoUrl() => '',
            ])
            ->call('save')
            ->assertHasNoFormErrors();

        $this->assertNull($song->refresh()->getAttribute(SongModelEnum::sopranoUrl()));
    }

    public function test_the_panel_rejects_a_voice_link_that_is_not_a_web_address(): void
    {
        $admin = User::factory()->admin()->create();

        Livewire::actingAs($admin)
            ->test(CreateSong::class)
            ->fillForm([
                SongModelEnum::title() => 'Amazing Grace',
                SongModelEnum::content() => '[G]Amazing grace',
                SongModelEnum::bassUrl() => 'not a link',
            ])
            ->call('create')
            ->assertHasFormErrors([
                SongModelEnum::bassUrl() => 'url',
            ]);

        $this->assertDatabaseMissing(SongModelEnum::tableName(), [
            SongModelEnum::title() => 'Amazing Grace',
        ]);
    }
}
