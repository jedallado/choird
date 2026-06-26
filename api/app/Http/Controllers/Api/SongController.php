<?php

namespace App\Http\Controllers\Api;

use App\Enums\Models\SongModelEnum;
use App\Http\Controllers\Controller;
use App\Http\Requests\Song\SongPostRequest;
use App\Http\Requests\Song\SongPutRequest;
use App\Http\Resources\SongResource;
use App\Models\Song;
use App\Services\Song\CreateSong;
use App\Services\Song\DeleteSong;
use App\Services\Song\UpdateSong;
use Illuminate\Http\Resources\Json\AnonymousResourceCollection;
use Illuminate\Http\Response;

class SongController extends Controller
{
    public function index(): AnonymousResourceCollection
    {
        return SongResource::collection(
            Song::query()->orderBy(SongModelEnum::title())->get()
        );
    }

    public function store(SongPostRequest $request, CreateSong $createSong): SongResource
    {
        $song = $createSong->handle($request->validated());

        return new SongResource($song);
    }

    public function show(Song $song): SongResource
    {
        return new SongResource($song);
    }

    public function update(SongPutRequest $request, Song $song, UpdateSong $updateSong): SongResource
    {
        $song = $updateSong->handle($song, $request->validated());

        return new SongResource($song);
    }

    public function destroy(Song $song, DeleteSong $deleteSong): Response
    {
        $deleteSong->handle($song);

        return response()->noContent();
    }
}
