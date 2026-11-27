<?php

namespace App\Http\Requests\User;

use App\Enums\Models\UserModelEnum;
use App\Enums\UserRole;
use App\Http\Requests\BaseFormRequest;
use App\Models\User;
use Illuminate\Validation\Rule;

class UserPostRequest extends BaseFormRequest
{
    public function authorize(): bool
    {
        $user = $this->user();

        return $user instanceof User && $user->isAdmin();
    }

    /**
     * @return array<string, mixed>
     */
    public function rules(): array
    {
        return [
            UserModelEnum::firstName() => 'required|string|max:255',
            UserModelEnum::lastName() => 'nullable|string|max:255',
            UserModelEnum::email() => [
                'required',
                'string',
                'email',
                'max:255',
                Rule::unique(UserModelEnum::tableName(), UserModelEnum::email()),
            ],
            UserModelEnum::password() => 'required|string|min:8|confirmed',
            UserModelEnum::role() => ['required', Rule::enum(UserRole::class)],
        ];
    }

    /**
     * @return array<string, string>
     */
    protected function fieldMapping(): array
    {
        return UserModelEnum::fieldMapping();
    }

    /**
     * @return array<string, string>
     */
    public function messages(): array
    {
        return [
            UserModelEnum::firstName().'.required' => 'First name is required.',
            UserModelEnum::lastName().'.max' => 'Last name must be 255 characters or fewer.',
            UserModelEnum::email().'.required' => 'Email is required.',
            UserModelEnum::email().'.unique' => 'Email is already in use.',
            UserModelEnum::password().'.required' => 'Password is required.',
            UserModelEnum::password().'.min' => 'Password must be at least 8 characters.',
            UserModelEnum::password().'.confirmed' => 'Password confirmation does not match.',
            UserModelEnum::role().'.required' => 'Role is required.',
        ];
    }
}
