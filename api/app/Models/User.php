<?php

namespace App\Models;

use App\Enums\Models\SetModelEnum;
use App\Enums\Models\SongModelEnum;
use App\Enums\Models\UserModelEnum;
use App\Enums\UserRole;
use Database\Factories\UserFactory;
use Filament\Models\Contracts\FilamentUser;
use Filament\Panel;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Relations\HasMany;
use Illuminate\Foundation\Auth\User as Authenticatable;
use Illuminate\Notifications\Notifiable;
use Laravel\Sanctum\HasApiTokens;

class User extends Authenticatable implements FilamentUser
{
    /** @use HasFactory<UserFactory> */
    use HasApiTokens, HasFactory, Notifiable;

    /**
     * The attributes that are mass assignable.
     *
     * @var list<string>
     */
    protected $fillable = [
        UserModelEnum::NAME->value,
        UserModelEnum::EMAIL->value,
        UserModelEnum::PASSWORD->value,
        UserModelEnum::ROLE->value,
    ];

    /**
     * The attributes that should be hidden for serialization.
     *
     * @var list<string>
     */
    protected $hidden = [
        UserModelEnum::PASSWORD->value,
        UserModelEnum::REMEMBER_TOKEN->value,
    ];

    /**
     * Get the attributes that should be cast.
     *
     * @return array<string, string>
     */
    protected function casts(): array
    {
        return [
            UserModelEnum::EMAIL_VERIFIED_AT->value => 'datetime',
            UserModelEnum::PASSWORD->value => 'hashed',
            UserModelEnum::ROLE->value => UserRole::class,
        ];
    }

    public function canAccessPanel(Panel $panel): bool
    {
        return $this->canEditCatalog();
    }

    public function isAdmin(): bool
    {
        return $this->role === UserRole::ADMIN;
    }

    public function canEditCatalog(): bool
    {
        return $this->role === UserRole::ADMIN || $this->role === UserRole::MANAGER;
    }

    public function isLastAdmin(): bool
    {
        if (! $this->isAdmin()) {
            return false;
        }

        return static::query()
            ->where(UserModelEnum::role(), UserRole::ADMIN->value)
            ->count() === 1;
    }

    /**
     * @return HasMany<Set, $this>
     */
    public function sets(): HasMany
    {
        return $this->hasMany(Set::class, SetModelEnum::createdByUserId());
    }

    /**
     * @return HasMany<Song, $this>
     */
    public function songs(): HasMany
    {
        return $this->hasMany(Song::class, SongModelEnum::createdByUserId());
    }
}
