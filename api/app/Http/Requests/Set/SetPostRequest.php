<?php

namespace App\Http\Requests\Set;

use App\Enums\Models\SetModelEnum;
use App\Enums\Models\SetSongModelEnum;
use App\Enums\Models\SongModelEnum;
use App\Http\Requests\BaseFormRequest;
use App\Models\User;
use Illuminate\Validation\Rule;

class SetPostRequest extends BaseFormRequest
{
    public function authorize(): bool
    {
        return true;
    }

    /**
     * @return array<string, mixed>
     */
    public function rules(): array
    {
        return [
            SetModelEnum::name() => 'nullable|string|max:255',
            SetModelEnum::scheduledFor() => 'required|date',
            SetModelEnum::createdByUserId() => [
                'required',
                'integer',
                Rule::exists((new User())->getTable(), 'id'),
            ],
            SetModelEnum::notes() => 'nullable|string',
            SetModelEnum::setSongs() => 'required|array|min:1',
            SetModelEnum::setSongs() . '.*.' . SetSongModelEnum::songId() => [
                'required',
                'integer',
                Rule::exists(SongModelEnum::tableName(), 'id'),
            ],
            SetModelEnum::setSongs() . '.*.' . SetSongModelEnum::position() => [
                'required',
                'integer',
                'min:1',
                'distinct',
            ],
        ];
    }

    /**
     * @return array<string, string>
     */
    protected function fieldMapping(): array
    {
        return SetModelEnum::fieldMapping();
    }

    protected function prepareForValidation(): void
    {
        parent::prepareForValidation();

        $setSongs = $this->input(SetModelEnum::setSongs());

        if (! is_array($setSongs)) {
            return;
        }

        $mappedSetSongs = array_map(function (mixed $setSong): mixed {
            if (! is_array($setSong)) {
                return $setSong;
            }

            if (array_key_exists(SetSongModelEnum::CLIENT_SONG_ID->value, $setSong)) {
                $setSong[SetSongModelEnum::songId()] = $setSong[SetSongModelEnum::CLIENT_SONG_ID->value];
            }

            return $setSong;
        }, $setSongs);

        $this->merge([
            SetModelEnum::setSongs() => $mappedSetSongs,
        ]);
    }

    /**
     * @return array<string, string>
     */
    public function messages(): array
    {
        return [
            SetModelEnum::scheduledFor() . '.required' => 'Scheduled date and time is required.',
            SetModelEnum::createdByUserId() . '.required' => 'Creator is required.',
            SetModelEnum::setSongs() . '.required' => 'At least one song is required.',
        ];
    }
}
