<?php

namespace App\Http\Requests\Song;

use App\Enums\Models\CategoryModelEnum;
use App\Enums\Models\SongModelEnum;
use App\Http\Requests\BaseFormRequest;
use App\Models\User;
use Illuminate\Validation\Rule;

class SongPutRequest extends BaseFormRequest
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
            SongModelEnum::title() => 'sometimes|required|string|max:255',
            SongModelEnum::artist() => 'sometimes|nullable|string|max:255',
            SongModelEnum::key() => 'sometimes|nullable|string|max:10',
            SongModelEnum::capo() => 'sometimes|nullable|integer|min:0|max:11',
            SongModelEnum::keyboardTranspose() => 'sometimes|nullable|integer|min:-11|max:11',
            SongModelEnum::content() => 'sometimes|required|string',
            SongModelEnum::sopranoUrl() => 'sometimes|nullable|url:http,https|max:2048',
            SongModelEnum::altoUrl() => 'sometimes|nullable|url:http,https|max:2048',
            SongModelEnum::tenorUrl() => 'sometimes|nullable|url:http,https|max:2048',
            SongModelEnum::bassUrl() => 'sometimes|nullable|url:http,https|max:2048',
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
            SongModelEnum::sopranoUrl().'.url' => 'Soprano link must be a valid web address.',
            SongModelEnum::altoUrl().'.url' => 'Alto link must be a valid web address.',
            SongModelEnum::tenorUrl().'.url' => 'Tenor link must be a valid web address.',
            SongModelEnum::bassUrl().'.url' => 'Bass link must be a valid web address.',
            SongModelEnum::categoryIds().'.*.exists' => 'A selected category does not exist.',
            SongModelEnum::categoryIds().'.*.distinct' => 'Each category can only be selected once.',
        ];
    }
}
