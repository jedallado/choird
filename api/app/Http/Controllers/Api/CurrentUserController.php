<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Http\Requests\User\CurrentUserPutRequest;
use App\Http\Resources\UserResource;
use App\Services\User\UpdateCurrentUser;
use Illuminate\Http\Request;

class CurrentUserController extends Controller
{
    public function show(Request $request): UserResource
    {
        return new UserResource($request->user());
    }

    public function update(CurrentUserPutRequest $request, UpdateCurrentUser $updateCurrentUser): UserResource
    {
        $user = $updateCurrentUser->handle($request->user(), $request->validated());

        return new UserResource($user);
    }
}
