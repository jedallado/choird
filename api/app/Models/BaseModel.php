<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

abstract class BaseModel extends Model
{
    /**
     * Get the model enum class name.
     *
     * @return class-string
     */
    abstract protected static function modelEnum(): string;

    public function __construct(array $attributes = [])
    {
        $enumClass = static::modelEnum();

        $this->table = $enumClass::tableName();
        $this->fillable = $enumClass::fillable();

        parent::__construct($attributes);
    }
}
