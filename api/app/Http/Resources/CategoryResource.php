<?php

namespace App\Http\Resources;

use App\Enums\Models\CategoryModelEnum;
use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class CategoryResource extends JsonResource
{
    /**
     * @return array<string, mixed>
     */
    public function toArray(Request $request): array
    {
        return [
            'id' => $this->id,
            'name' => $this->getAttribute(CategoryModelEnum::name()),
        ];
    }
}
