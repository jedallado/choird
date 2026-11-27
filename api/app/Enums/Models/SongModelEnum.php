<?php

namespace App\Enums\Models;

enum SongModelEnum: string
{
    case TABLE_NAME = 'songs';
    case TITLE = 'title';
    case ARTIST = 'artist';
    case KEY = 'key';
    case CAPO = 'capo';
    case KEYBOARD_TRANSPOSE = 'keyboard_transpose';
    case CONTENT = 'content';
    case SOPRANO_URL = 'soprano_url';
    case ALTO_URL = 'alto_url';
    case TENOR_URL = 'tenor_url';
    case BASS_URL = 'bass_url';
    case CREATED_BY_USER_ID = 'created_by_user_id';
    case CATEGORY_IDS = 'category_ids';
    case CLIENT_KEYBOARD_TRANSPOSE = 'keyboardTranspose';
    case CLIENT_CATEGORY_IDS = 'categoryIds';
    case CLIENT_SOPRANO_URL = 'sopranoUrl';
    case CLIENT_ALTO_URL = 'altoUrl';
    case CLIENT_TENOR_URL = 'tenorUrl';
    case CLIENT_BASS_URL = 'bassUrl';
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

    public static function capo(): string
    {
        return self::CAPO->value;
    }

    public static function keyboardTranspose(): string
    {
        return self::KEYBOARD_TRANSPOSE->value;
    }

    public static function content(): string
    {
        return self::CONTENT->value;
    }

    public static function sopranoUrl(): string
    {
        return self::SOPRANO_URL->value;
    }

    public static function altoUrl(): string
    {
        return self::ALTO_URL->value;
    }

    public static function tenorUrl(): string
    {
        return self::TENOR_URL->value;
    }

    public static function bassUrl(): string
    {
        return self::BASS_URL->value;
    }

    public static function createdByUserId(): string
    {
        return self::CREATED_BY_USER_ID->value;
    }

    public static function categoryIds(): string
    {
        return self::CATEGORY_IDS->value;
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
            self::capo(),
            self::keyboardTranspose(),
            self::content(),
            self::sopranoUrl(),
            self::altoUrl(),
            self::tenorUrl(),
            self::bassUrl(),
            self::createdByUserId(),
        ];
    }

    /**
     * @return array<string, string>
     */
    public static function fieldMapping(): array
    {
        return [
            self::CLIENT_KEYBOARD_TRANSPOSE->value => self::keyboardTranspose(),
            self::CLIENT_CATEGORY_IDS->value => self::categoryIds(),
            self::CLIENT_SOPRANO_URL->value => self::sopranoUrl(),
            self::CLIENT_ALTO_URL->value => self::altoUrl(),
            self::CLIENT_TENOR_URL->value => self::tenorUrl(),
            self::CLIENT_BASS_URL->value => self::bassUrl(),
        ];
    }
}
