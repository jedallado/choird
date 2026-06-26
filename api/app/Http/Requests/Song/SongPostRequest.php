<?php

namespace App\Http\Requests\Song;

use App\Enums\Models\SongModelEnum;
use App\Http\Requests\BaseFormRequest;

class SongPostRequest extends BaseFormRequest
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
            SongModelEnum::title() => 'required|string|max:255',
            SongModelEnum::artist() => 'nullable|string|max:255',
            SongModelEnum::key() => 'nullable|string|max:10',
            SongModelEnum::content() => 'required|string',
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
