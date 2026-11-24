<?php

namespace App\Http\Requests\Auth;

use App\Enums\Models\UserModelEnum;
use App\Http\Requests\BaseFormRequest;

class LoginRequest extends BaseFormRequest
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
            UserModelEnum::email() => 'required|string|email',
            UserModelEnum::password() => 'required|string',
        ];
    }

    /**
     * @return array<string, string>
     */
    protected function fieldMapping(): array
    {
        return [];
    }

    /**
     * @return array<string, string>
     */
    public function messages(): array
    {
        return [
            UserModelEnum::email().'.required' => 'Email is required.',
            UserModelEnum::password().'.required' => 'Password is required.',
        ];
    }
}
