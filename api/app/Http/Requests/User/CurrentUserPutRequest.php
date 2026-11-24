<?php

namespace App\Http\Requests\User;

use App\Enums\Models\UserModelEnum;
use App\Http\Requests\BaseFormRequest;
use App\Models\User;
use Illuminate\Validation\Rule;

class CurrentUserPutRequest extends BaseFormRequest
{
    public function authorize(): bool
    {
        return $this->user() instanceof User;
    }

    /**
     * @return array<string, mixed>
     */
    public function rules(): array
    {
        /** @var User $user */
        $user = $this->user();

        return [
            UserModelEnum::name() => 'sometimes|required|string|max:255',
            UserModelEnum::email() => [
                'sometimes',
                'required',
                'string',
                'email',
                'max:255',
                Rule::unique(UserModelEnum::tableName(), UserModelEnum::email())->ignore($user->id),
            ],
            UserModelEnum::password() => 'sometimes|required|string|min:8|confirmed',
            UserModelEnum::currentPassword() => 'required_with:'.UserModelEnum::password().'|string|current_password:sanctum',
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
            UserModelEnum::name().'.required' => 'Name is required.',
            UserModelEnum::email().'.required' => 'Email is required.',
            UserModelEnum::email().'.unique' => 'Email is already in use.',
            UserModelEnum::password().'.required' => 'Password is required.',
            UserModelEnum::password().'.min' => 'Password must be at least 8 characters.',
            UserModelEnum::password().'.confirmed' => 'Password confirmation does not match.',
            UserModelEnum::currentPassword().'.required_with' => 'Current password is required to change your password.',
            UserModelEnum::currentPassword().'.current_password' => 'Current password is incorrect.',
        ];
    }
}
