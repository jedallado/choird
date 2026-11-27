<?php

namespace Tests\Feature;

use App\Enums\Models\CategoryModelEnum;
use App\Enums\Models\CategorySongModelEnum;
use App\Enums\Models\SongModelEnum;
use App\Filament\Resources\SongResource\Pages\CreateSong;
use App\Filament\Resources\SongResource\Pages\ListSongs;
use App\Models\Category;
use App\Models\Song;
use App\Models\User;
use Filament\Facades\Filament;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Livewire\Livewire;
use Tests\TestCase;

class SongCategoryTest extends TestCase
{
    use RefreshDatabase;

    protected function setUp(): void
    {
        parent::setUp();

        Filament::setCurrentPanel(Filament::getPanel('admin'));
    }

    public function test_a_song_can_be_created_with_categories(): void
    {
        $manager = User::factory()->manager()->create();
        $worship = Category::create([
            CategoryModelEnum::name() => 'Worship',
        ]);
        $hymns = Category::create([
            CategoryModelEnum::name() => 'Hymns',
        ]);

        $response = $this->withBearer($manager->createToken('api')->plainTextToken)
            ->postJson('/api/songs', [
                'title' => 'Amazing Grace',
                'content' => '[G]Amazing grace',
                'categoryIds' => [$worship->id, $hymns->id],
            ])
            ->assertCreated()
            ->assertJsonPath('data.categories.0.id', $hymns->id)
            ->assertJsonPath('data.categories.0.name', 'Hymns')
            ->assertJsonPath('data.categories.1.id', $worship->id)
            ->assertJsonPath('data.categories.1.name', 'Worship');

        $songId = $response->json('data.id');

        $this->assertDatabaseHas(CategorySongModelEnum::tableName(), [
            CategorySongModelEnum::songId() => $songId,
            CategorySongModelEnum::categoryId() => $hymns->id,
        ]);
        $this->assertDatabaseHas(CategorySongModelEnum::tableName(), [
            CategorySongModelEnum::songId() => $songId,
            CategorySongModelEnum::categoryId() => $worship->id,
        ]);
    }

    public function test_songs_without_categories_return_an_empty_list(): void
    {
        $member = User::factory()->create();
        $song = Song::create([
            SongModelEnum::title() => 'Amazing Grace',
            SongModelEnum::content() => '[G]Amazing grace',
        ]);

        $this->withBearer($member->createToken('api')->plainTextToken)
            ->getJson('/api/songs/'.$song->id)
            ->assertOk()
            ->assertJsonPath('data.categories', []);

        $this->withBearer($member->createToken('api')->plainTextToken)
            ->getJson('/api/songs')
            ->assertOk()
            ->assertJsonPath('data.0.categories', []);
    }

    public function test_updating_a_song_replaces_categories_only_when_ids_are_sent(): void
    {
        $manager = User::factory()->manager()->create();
        $token = $manager->createToken('api')->plainTextToken;
        $hymns = Category::create([
            CategoryModelEnum::name() => 'Hymns',
        ]);
        $worship = Category::create([
            CategoryModelEnum::name() => 'Worship',
        ]);
        $song = Song::create([
            SongModelEnum::title() => 'Amazing Grace',
            SongModelEnum::content() => '[G]Amazing grace',
        ]);
        $song->categories()->attach($hymns->id);

        $this->withBearer($token)
            ->putJson('/api/songs/'.$song->id, [
                'title' => 'Amazing Grace (updated)',
            ])
            ->assertOk()
            ->assertJsonPath('data.categories.0.id', $hymns->id);

        $this->withBearer($token)
            ->putJson('/api/songs/'.$song->id, [
                'categoryIds' => [$worship->id],
            ])
            ->assertOk()
            ->assertJsonPath('data.categories.0.id', $worship->id)
            ->assertJsonMissingPath('data.categories.1');

        $this->withBearer($token)
            ->putJson('/api/songs/'.$song->id, [
                'categoryIds' => [],
            ])
            ->assertOk()
            ->assertJsonPath('data.categories', []);

        $this->assertDatabaseMissing(CategorySongModelEnum::tableName(), [
            CategorySongModelEnum::songId() => $song->id,
        ]);
    }

    public function test_unknown_category_ids_are_rejected(): void
    {
        $manager = User::factory()->manager()->create();
        $song = Song::create([
            SongModelEnum::title() => 'Amazing Grace',
            SongModelEnum::content() => '[G]Amazing grace',
        ]);

        $this->withBearer($manager->createToken('api')->plainTextToken)
            ->putJson('/api/songs/'.$song->id, [
                'categoryIds' => [999],
            ])
            ->assertUnprocessable()
            ->assertJsonValidationErrors(SongModelEnum::categoryIds().'.0');
    }

    public function test_deleting_a_song_keeps_its_categories(): void
    {
        $manager = User::factory()->manager()->create();
        $category = Category::create([
            CategoryModelEnum::name() => 'Hymns',
        ]);
        $song = Song::create([
            SongModelEnum::title() => 'Amazing Grace',
            SongModelEnum::content() => '[G]Amazing grace',
        ]);
        $song->categories()->attach($category->id);

        $this->withBearer($manager->createToken('api')->plainTextToken)
            ->deleteJson('/api/songs/'.$song->id)
            ->assertNoContent();

        $this->assertModelMissing($song);
        $this->assertModelExists($category);
        $this->assertDatabaseMissing(CategorySongModelEnum::tableName(), [
            CategorySongModelEnum::songId() => $song->id,
        ]);
    }

    public function test_an_admin_can_assign_categories_when_creating_a_song(): void
    {
        $admin = User::factory()->admin()->create();
        $category = Category::create([
            CategoryModelEnum::name() => 'Hymns',
        ]);

        Livewire::actingAs($admin)
            ->test(CreateSong::class)
            ->fillForm([
                SongModelEnum::title() => 'Amazing Grace',
                SongModelEnum::content() => '[G]Amazing grace',
                'categories' => [$category->id],
            ])
            ->call('create')
            ->assertHasNoFormErrors();

        $song = Song::query()->firstOrFail();

        $this->assertTrue($song->categories()->whereKey($category->id)->exists());

        Livewire::actingAs($admin)
            ->test(ListSongs::class)
            ->assertSee('Hymns');
    }
}
