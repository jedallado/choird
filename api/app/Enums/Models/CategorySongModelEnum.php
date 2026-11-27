<?php

namespace App\Enums\Models;

enum CategorySongModelEnum: string
{
    case TABLE_NAME = 'category_song';
    case CATEGORY_ID = 'category_id';
    case SONG_ID = 'song_id';

    public static function tableName(): string
    {
        return self::TABLE_NAME->value;
    }

    public static function categoryId(): string
    {
        return self::CATEGORY_ID->value;
    }

    public static function songId(): string
    {
        return self::SONG_ID->value;
    }

    /**
     * @return list<string>
     */
    public static function fillable(): array
    {
        return [
            self::categoryId(),
            self::songId(),
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
