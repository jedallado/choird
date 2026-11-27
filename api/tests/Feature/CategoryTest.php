<?php

namespace Tests\Feature;

use App\Enums\Models\CategoryModelEnum;
use App\Enums\Models\CategorySongModelEnum;
use App\Enums\Models\SongModelEnum;
use App\Filament\Resources\CategoryResource\Pages\CreateCategory;
use App\Filament\Resources\CategoryResource\Pages\EditCategory;
use App\Filament\Resources\CategoryResource\Pages\ListCategories;
use App\Models\Category;
use App\Models\Song;
use App\Models\User;
use App\Services\Category\DeleteCategory;
use Filament\Facades\Filament;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Livewire\Livewire;
use Tests\TestCase;

class CategoryTest extends TestCase
{
    use RefreshDatabase;

    protected function setUp(): void
    {
        parent::setUp();

        Filament::setCurrentPanel(Filament::getPanel('admin'));
    }

    public function test_authenticated_users_can_list_and_show_categories(): void
    {
        $member = User::factory()->create();
        $token = $member->createToken('api')->plainTextToken;

        Category::create([CategoryModelEnum::name() => 'Worship']);
        Category::create([CategoryModelEnum::name() => 'Hymns']);

        $this->withBearer($token)
            ->getJson('/api/categories')
            ->assertOk()
            ->assertJsonPath('data.0.name', 'Hymns')
            ->assertJsonPath('data.1.name', 'Worship')
            ->assertJsonMissingPath('data.0.createdAt');

        $hymns = Category::query()->where(CategoryModelEnum::name(), 'Hymns')->firstOrFail();

        $this->withBearer($token)
            ->getJson('/api/categories/'.$hymns->id)
            ->assertOk()
            ->assertJsonPath('data.id', $hymns->id)
            ->assertJsonPath('data.name', 'Hymns')
            ->assertJsonMissingPath('data.createdAt');
    }

    public function test_guests_cannot_read_categories(): void
    {
        $this->getJson('/api/categories')->assertUnauthorized();
    }

    public function test_categories_cannot_be_changed_through_the_api(): void
    {
        $member = User::factory()->create();
        $token = $member->createToken('api')->plainTextToken;
        $category = Category::create([
            CategoryModelEnum::name() => 'Hymns',
        ]);

        $this->withBearer($token)
            ->postJson('/api/categories', [
                CategoryModelEnum::name() => 'Worship',
            ])
            ->assertMethodNotAllowed();

        $this->withBearer($token)
            ->putJson('/api/categories/'.$category->id, [
                CategoryModelEnum::name() => 'Worship',
            ])
            ->assertMethodNotAllowed();

        $this->withBearer($token)
            ->deleteJson('/api/categories/'.$category->id)
            ->assertMethodNotAllowed();

        $this->assertDatabaseHas(CategoryModelEnum::tableName(), [
            CategoryModelEnum::name() => 'Hymns',
        ]);
    }

    public function test_an_admin_can_create_a_category_from_the_panel(): void
    {
        $admin = User::factory()->admin()->create();

        Livewire::actingAs($admin)
            ->test(CreateCategory::class)
            ->fillForm([
                CategoryModelEnum::name() => 'Hymns',
            ])
            ->call('create')
            ->assertHasNoFormErrors();

        $this->assertDatabaseHas(CategoryModelEnum::tableName(), [
            CategoryModelEnum::name() => 'Hymns',
        ]);
    }

    public function test_a_category_assigned_to_a_song_cannot_be_deleted(): void
    {
        $admin = User::factory()->admin()->create();
        $category = Category::create([
            CategoryModelEnum::name() => 'Hymns',
        ]);
        $song = Song::create([
            SongModelEnum::title() => 'Amazing Grace',
            SongModelEnum::content() => '[G]Amazing grace',
        ]);
        $song->categories()->attach($category->id);

        Livewire::actingAs($admin)
            ->test(EditCategory::class, ['record' => $category->id])
            ->callAction('delete')
            ->assertNotified(DeleteCategory::IN_USE_MESSAGE);

        $this->assertModelExists($category);
        $this->assertDatabaseHas(CategorySongModelEnum::tableName(), [
            CategorySongModelEnum::categoryId() => $category->id,
            CategorySongModelEnum::songId() => $song->id,
        ]);
    }

    public function test_an_unused_category_can_be_deleted(): void
    {
        $admin = User::factory()->admin()->create();
        $category = Category::create([
            CategoryModelEnum::name() => 'Hymns',
        ]);

        Livewire::actingAs($admin)
            ->test(EditCategory::class, ['record' => $category->id])
            ->callAction('delete');

        $this->assertModelMissing($category);
    }

    public function test_bulk_delete_keeps_categories_that_songs_still_use(): void
    {
        $admin = User::factory()->admin()->create();
        $used = Category::create([
            CategoryModelEnum::name() => 'Hymns',
        ]);
        $free = Category::create([
            CategoryModelEnum::name() => 'Other',
        ]);
        $song = Song::create([
            SongModelEnum::title() => 'Amazing Grace',
            SongModelEnum::content() => '[G]Amazing grace',
        ]);
        $song->categories()->attach($used->id);

        Livewire::actingAs($admin)
            ->test(ListCategories::class)
            ->callTableBulkAction('delete', [$used, $free]);

        $this->assertModelExists($used);
        $this->assertModelMissing($free);
    }
}
