<?php

namespace App\Http\Requests\Song;

use App\Enums\Models\SongModelEnum;
use App\Http\Requests\BaseFormRequest;

class SongPutRequest extends BaseFormRequest
{
    public function authorize(): bool
    {
        return true;
    }

    /**
     * @return array<string, string>
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
            SongModelEnum::title() . '.required' => 'Title is required.',
            SongModelEnum::content() . '.required' => 'Content is required.',
        ];
    }
}
