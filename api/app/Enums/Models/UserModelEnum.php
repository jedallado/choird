<?php

namespace App\Enums\Models;

enum UserModelEnum: string
{
    case TABLE_NAME = 'users';
    case FIRST_NAME = 'first_name';
    case LAST_NAME = 'last_name';
    case FULL_NAME = 'name';
    case EMAIL = 'email';
    case EMAIL_VERIFIED_AT = 'email_verified_at';
    case PASSWORD = 'password';
    case ROLE = 'role';
    case REMEMBER_TOKEN = 'remember_token';
    case CREATED_AT = 'created_at';
    case UPDATED_AT = 'updated_at';
    case CLIENT_FIRST_NAME = 'firstName';
    case CLIENT_LAST_NAME = 'lastName';
    case CLIENT_CURRENT_PASSWORD = 'currentPassword';
    case CLIENT_PASSWORD_CONFIRMATION = 'passwordConfirmation';
    case CURRENT_PASSWORD = 'current_password';
    case PASSWORD_CONFIRMATION = 'password_confirmation';
    case CLIENT_CREATED_AT = 'createdAt';
    case CLIENT_UPDATED_AT = 'updatedAt';

    public static function tableName(): string
    {
        return self::TABLE_NAME->value;
    }

    public static function firstName(): string
    {
        return self::FIRST_NAME->value;
    }

    public static function lastName(): string
    {
        return self::LAST_NAME->value;
    }

    public static function fullName(): string
    {
        return self::FULL_NAME->value;
    }

    public static function email(): string
    {
        return self::EMAIL->value;
    }

    public static function emailVerifiedAt(): string
    {
        return self::EMAIL_VERIFIED_AT->value;
    }

    public static function password(): string
    {
        return self::PASSWORD->value;
    }

    public static function role(): string
    {
        return self::ROLE->value;
    }

    public static function rememberToken(): string
    {
        return self::REMEMBER_TOKEN->value;
    }

    public static function createdAt(): string
    {
        return self::CREATED_AT->value;
    }

    public static function updatedAt(): string
    {
        return self::UPDATED_AT->value;
    }

    public static function currentPassword(): string
    {
        return self::CURRENT_PASSWORD->value;
    }

    /**
     * @return list<string>
     */
    public static function fillable(): array
    {
        return [
            self::firstName(),
            self::lastName(),
            self::email(),
            self::password(),
            self::role(),
        ];
    }

    /**
     * @return array<string, string>
     */
    public static function fieldMapping(): array
    {
        return [
            self::CLIENT_FIRST_NAME->value => self::firstName(),
            self::CLIENT_LAST_NAME->value => self::lastName(),
            self::CLIENT_CURRENT_PASSWORD->value => self::currentPassword(),
            self::CLIENT_PASSWORD_CONFIRMATION->value => self::PASSWORD_CONFIRMATION->value,
        ];
    }
}
