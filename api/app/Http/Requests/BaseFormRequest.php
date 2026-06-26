<?php

namespace App\Http\Requests;

use Illuminate\Foundation\Http\FormRequest;

abstract class BaseFormRequest extends FormRequest
{
    /**
     * @return array<string, string>
     */
    abstract protected function fieldMapping(): array;

    protected function prepareForValidation(): void
    {
        $mappedData = [];

        foreach ($this->fieldMapping() as $clientField => $backendField) {
            if ($this->has($clientField)) {
                $mappedData[$backendField] = $this->input($clientField);
            }
        }

        if ($mappedData !== []) {
            $this->merge($mappedData);
        }
    }
}
