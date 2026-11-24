<?php

namespace App\Http\Controllers\Api;

use App\Enums\Models\UserModelEnum;
use App\Http\Controllers\Controller;
use App\Http\Requests\Auth\LoginRequest;
use App\Http\Resources\UserResource;
use App\Services\Auth\LoginUser;
use App\Services\Auth\LogoutUser;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Http\Response;

class AuthController extends Controller
{
    public function login(LoginRequest $request, LoginUser $loginUser): JsonResponse
    {
        $result = $loginUser->handle(
            $request->validated(UserModelEnum::email()),
            $request->validated(UserModelEnum::password()),
        );

        return response()->json([
            'token' => $result['token']->plainTextToken,
            'tokenType' => 'Bearer',
            'expiresAt' => $result['token']->accessToken->expires_at,
            'user' => (new UserResource($result['user']))->resolve(),
        ]);
    }

    public function logout(Request $request, LogoutUser $logoutUser): Response
    {
        $logoutUser->handle($request->user());

        return response()->noContent();
    }
}
