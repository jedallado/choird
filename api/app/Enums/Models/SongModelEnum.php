<?php

namespace App\Enums\Models;

enum SongModelEnum: string
{
    case TABLE_NAME = 'songs';
    case TITLE = 'title';
    case ARTIST = 'artist';
    case KEY = 'key';
    case CONTENT = 'content';
    case CREATED_AT = 'created_at';
    case UPDATED_AT = 'updated_at';
    case CLIENT_CREATED_AT = 'createdAt';
    case CLIENT_UPDATED_AT = 'updatedAt';

    public static function tableName(): string
    {
        return self::TABLE_NAME->value;
    }

    public static function title(): string
    {
        return self::TITLE->value;
    }

    public static function artist(): string
    {
        return self::ARTIST->value;
    }

    public static function key(): string
    {
        return self::KEY->value;
    }

    public static function content(): string
    {
        return self::CONTENT->value;
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
            self::title(),
            self::artist(),
            self::key(),
            self::content(),
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
