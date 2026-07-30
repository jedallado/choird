<?php

namespace App\Http\Controllers\Api;

use App\Enums\Models\SetModelEnum;
use App\Http\Controllers\Controller;
use App\Http\Requests\Set\SetPostRequest;
use App\Http\Requests\Set\SetPutRequest;
use App\Http\Resources\SetResource;
use App\Models\Set;
use App\Services\Set\CreateSet;
use App\Services\Set\DeleteSet;
use App\Services\Set\UpdateSet;
use Illuminate\Http\Resources\Json\AnonymousResourceCollection;
use Illuminate\Http\Response;

class SetController extends Controller
{
    public function index(): AnonymousResourceCollection
    {
        return SetResource::collection(
            Set::query()
                ->with(['setSongs.song'])
                ->orderByDesc(SetModelEnum::scheduledFor())
                ->get()
        );
    }

    public function store(SetPostRequest $request, CreateSet $createSet): SetResource
    {
        $set = $createSet->handle($request->validated());

        return new SetResource($set);
    }

    public function show(Set $set): SetResource
    {
        return new SetResource($set->load(['setSongs.song']));
    }

    public function update(SetPutRequest $request, Set $set, UpdateSet $updateSet): SetResource
    {
        $set = $updateSet->handle($set, $request->validated());

        return new SetResource($set);
    }

    public function destroy(Set $set, DeleteSet $deleteSet): Response
    {
        $deleteSet->handle($set);

        return response()->noContent();
    }
}
