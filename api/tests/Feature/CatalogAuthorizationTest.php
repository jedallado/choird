<?php

namespace Tests\Feature;

use App\Enums\Models\SongModelEnum;
use App\Models\Song;
use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

class CatalogAuthorizationTest extends TestCase
{
    use RefreshDatabase;

    public function test_members_can_read_but_not_change_the_catalog(): void
    {
        $member = User::factory()->create();
        $token = $member->createToken('api')->plainTextToken;
        $song = Song::create([
            'title' => 'Amazing Grace',
            'content' => '[G]Amazing grace',
        ]);

        $this->withBearer($token)->getJson('/api/songs')->assertOk();
        $this->withBearer($token)->getJson('/api/songs/'.$song->id)->assertOk();
        $this->withBearer($token)->getJson('/api/sets')->assertOk();

        $this->withBearer($token)->postJson('/api/songs', [
            'title' => 'New Song',
            'content' => 'Lyrics',
        ])->assertForbidden();

        $this->withBearer($token)->putJson('/api/songs/'.$song->id, [
            'title' => 'Changed',
        ])->assertForbidden();

        $this->withBearer($token)->deleteJson('/api/songs/'.$song->id)->assertForbidden();
        $this->withBearer($token)->postJson('/api/sets', [])->assertForbidden();
    }

    public function test_managers_can_edit_songs(): void
    {
        $manager = User::factory()->manager()->create();

        $this->withBearer($manager->createToken('api')->plainTextToken)
            ->postJson('/api/songs', [
                'title' => 'New Song',
                'content' => 'Lyrics',
            ])->assertCreated()
            ->assertJsonPath('data.title', 'New Song')
            ->assertJsonMissingPath('data.createdByUserId');

        $this->assertDatabaseHas(SongModelEnum::tableName(), [
            SongModelEnum::title() => 'New Song',
            SongModelEnum::createdByUserId() => $manager->id,
        ]);
    }
}
