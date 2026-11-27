<?php

namespace App\Http\Controllers\Api;

use App\Enums\Models\UserModelEnum;
use App\Http\Controllers\Controller;
use App\Http\Requests\User\UserPostRequest;
use App\Http\Requests\User\UserPutRequest;
use App\Http\Resources\UserResource;
use App\Models\User;
use App\Services\User\CreateUser;
use App\Services\User\DeleteUser;
use App\Services\User\UpdateUser;
use Illuminate\Http\Resources\Json\AnonymousResourceCollection;
use Illuminate\Http\Response;
use Illuminate\Support\Facades\Gate;

class UserController extends Controller
{
    public function index(): AnonymousResourceCollection
    {
        Gate::authorize('manageUsers');

        return UserResource::collection(
            User::query()
                ->orderBy(UserModelEnum::firstName())
                ->orderBy(UserModelEnum::lastName())
                ->get()
        );
    }

    public function store(UserPostRequest $request, CreateUser $createUser): UserResource
    {
        Gate::authorize('manageUsers');

        $user = $createUser->handle($request->validated());

        return new UserResource($user);
    }

    public function show(User $user): UserResource
    {
        Gate::authorize('manageUsers');

        return new UserResource($user);
    }

    public function update(UserPutRequest $request, User $user, UpdateUser $updateUser): UserResource
    {
        Gate::authorize('manageUsers');

        $user = $updateUser->handle($user, $request->validated());

        return new UserResource($user);
    }

    public function destroy(User $user, DeleteUser $deleteUser): Response
    {
        Gate::authorize('manageUsers');

        $deleteUser->handle(request()->user(), $user);

        return response()->noContent();
    }
}
