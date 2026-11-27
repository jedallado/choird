<?php

namespace App\Http\Resources;

use App\Enums\Models\UserModelEnum;
use App\Enums\UserRole;
use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class UserResource extends JsonResource
{
    /**
     * @return array<string, mixed>
     */
    public function toArray(Request $request): array
    {
        $role = $this->getAttribute(UserModelEnum::role());

        return [
            'id' => $this->id,
            'name' => $this->getAttribute(UserModelEnum::fullName()),
            'firstName' => $this->getAttribute(UserModelEnum::firstName()),
            'lastName' => $this->getAttribute(UserModelEnum::lastName()),
            'email' => $this->getAttribute(UserModelEnum::email()),
            'role' => $role instanceof UserRole ? $role->value : $role,
            'createdAt' => $this->getAttribute(UserModelEnum::createdAt()),
            'updatedAt' => $this->getAttribute(UserModelEnum::updatedAt()),
        ];
    }
}
