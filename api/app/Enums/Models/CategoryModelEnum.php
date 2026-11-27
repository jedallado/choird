<?php

namespace App\Enums\Models;

enum CategoryModelEnum: string
{
    case TABLE_NAME = 'categories';
    case NAME = 'name';
    case CREATED_AT = 'created_at';
    case UPDATED_AT = 'updated_at';

    public static function tableName(): string
    {
        return self::TABLE_NAME->value;
    }

    public static function name(): string
    {
        return self::NAME->value;
    }

    public static function createdAt(): string
    {
        return self::CREATED_AT->value;
    }

    public static function updatedAt(): string
    {
        return self::UPDATED_AT->value;
    }

    /**
     * @return list<string>
     */
    public static function fillable(): array
    {
        return [
            self::name(),
        ];
    }

    /**
     * @return array<string, string>
     */
    public static function fieldMapping(): array
    {
        return [];
    }
}
