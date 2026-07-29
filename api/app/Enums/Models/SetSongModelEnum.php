<?php

namespace App\Enums\Models;

enum SetSongModelEnum: string
{
    case TABLE_NAME = 'set_songs';
    case SET_ID = 'set_id';
    case SONG_ID = 'song_id';
    case POSITION = 'position';
    case CREATED_AT = 'created_at';
    case UPDATED_AT = 'updated_at';
    case CLIENT_SET_ID = 'setId';
    case CLIENT_SONG_ID = 'songId';
    case CLIENT_CREATED_AT = 'createdAt';
    case CLIENT_UPDATED_AT = 'updatedAt';

    public static function tableName(): string
    {
        return self::TABLE_NAME->value;
    }

    public static function setId(): string
    {
        return self::SET_ID->value;
    }

    public static function songId(): string
    {
        return self::SONG_ID->value;
    }

    public static function position(): string
    {
        return self::POSITION->value;
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
            self::setId(),
            self::songId(),
            self::position(),
        ];
    }

    /**
     * @return array<string, string>
     */
    public static function fieldMapping(): array
    {
        return [
            self::CLIENT_SET_ID->value => self::setId(),
            self::CLIENT_SONG_ID->value => self::songId(),
        ];
    }
}
