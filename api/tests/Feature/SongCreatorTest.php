<?php

namespace Tests\Feature;

use App\Enums\Models\SongModelEnum;
use App\Filament\Resources\SongResource\Pages\CreateSong;
use App\Filament\Resources\SongResource\Pages\EditSong;
use App\Models\Song;
use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Livewire\Livewire;
use Tests\TestCase;

class SongCreatorTest extends TestCase
{
    use RefreshDatabase;

    public function test_the_song_edit_page_shows_who_created_it(): void
    {
        $admin = User::factory()->admin()->create();
        $this->actingAs($admin);

        $song = Song::create([
            SongModelEnum::title() => 'Amazing Grace',
            SongModelEnum::content() => '[G]Amazing grace',
            SongModelEnum::createdByUserId() => $admin->id,
        ]);

        Livewire::test(EditSong::class, ['record' => $song->id])
            ->assertSuccessful()
            ->assertSee('Created by')
            ->assertSee($admin->name);
    }

    public function test_the_song_create_page_does_not_ask_for_a_creator(): void
    {
        $admin = User::factory()->admin()->create();
        $this->actingAs($admin);

        Livewire::test(CreateSong::class)
            ->assertSuccessful()
            ->assertDontSee('Created by');
    }
}
