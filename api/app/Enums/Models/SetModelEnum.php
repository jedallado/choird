<?php

namespace App\Enums\Models;

enum SetModelEnum: string
{
    case TABLE_NAME = 'sets';
    case NAME = 'name';
    case SCHEDULED_FOR = 'scheduled_for';
    case CREATED_BY_USER_ID = 'created_by_user_id';
    case NOTES = 'notes';
    case CREATED_AT = 'created_at';
    case UPDATED_AT = 'updated_at';
    case CLIENT_SCHEDULED_FOR = 'scheduledFor';
    case CLIENT_CREATED_BY_USER_ID = 'createdByUserId';
    case CLIENT_CREATED_AT = 'createdAt';
    case CLIENT_UPDATED_AT = 'updatedAt';
    case CLIENT_SET_SONGS = 'setSongs';
    case SET_SONGS = 'set_songs';

    public static function tableName(): string
    {
        return self::TABLE_NAME->value;
    }

    public static function name(): string
    {
        return self::NAME->value;
    }

    public static function scheduledFor(): string
    {
        return self::SCHEDULED_FOR->value;
    }

    public static function createdByUserId(): string
    {
        return self::CREATED_BY_USER_ID->value;
    }

    public static function notes(): string
    {
        return self::NOTES->value;
    }

    public static function createdAt(): string
    {
        return self::CREATED_AT->value;
    }

    public static function updatedAt(): string
    {
        return self::UPDATED_AT->value;
    }

    public static function setSongs(): string
    {
        return self::SET_SONGS->value;
    }

    /**
     * @return list<string>
     */
    public static function fillable(): array
    {
        return [
            self::name(),
            self::scheduledFor(),
            self::createdByUserId(),
            self::notes(),
        ];
    }

    /**
     * @return array<string, string>
     */
    public static function fieldMapping(): array
    {
        return [
            self::CLIENT_SCHEDULED_FOR->value => self::scheduledFor(),
            self::CLIENT_CREATED_BY_USER_ID->value => self::createdByUserId(),
            self::CLIENT_SET_SONGS->value => self::setSongs(),
        ];
    }
}
