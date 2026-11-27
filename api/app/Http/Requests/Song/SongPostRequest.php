<?php

namespace App\Http\Requests\Song;

use App\Enums\Models\CategoryModelEnum;
use App\Enums\Models\SongModelEnum;
use App\Http\Requests\BaseFormRequest;
use App\Models\User;
use Illuminate\Validation\Rule;

class SongPostRequest extends BaseFormRequest
{
    public function authorize(): bool
    {
        $user = $this->user();

        return $user instanceof User && $user->canEditCatalog();
    }

    /**
     * @return array<string, mixed>
     */
    public function rules(): array
    {
        return [
            SongModelEnum::title() => 'required|string|max:255',
            SongModelEnum::artist() => 'nullable|string|max:255',
            SongModelEnum::key() => 'nullable|string|max:10',
            SongModelEnum::capo() => 'nullable|integer|min:0|max:11',
            SongModelEnum::keyboardTranspose() => 'nullable|integer|min:-11|max:11',
            SongModelEnum::content() => 'required|string',
            SongModelEnum::categoryIds() => 'sometimes|array',
            SongModelEnum::categoryIds().'.*' => [
                'integer',
                'distinct',
                Rule::exists(CategoryModelEnum::tableName(), 'id'),
            ],
        ];
    }

    /**
     * @return array<string, string>
     */
    protected function fieldMapping(): array
    {
        return SongModelEnum::fieldMapping();
    }

    /**
     * @return array<string, string>
     */
    public function messages(): array
    {
        return [
            SongModelEnum::title().'.required' => 'Title is required.',
            SongModelEnum::content().'.required' => 'Content is required.',
            SongModelEnum::categoryIds().'.*.exists' => 'A selected category does not exist.',
            SongModelEnum::categoryIds().'.*.distinct' => 'Each category can only be selected once.',
        ];
    }
}
