<?php

namespace App\Filament\Resources;

use App\Enums\Models\UserModelEnum;
use App\Enums\UserRole;
use App\Filament\Resources\UserResource\Pages\CreateUser;
use App\Filament\Resources\UserResource\Pages\EditUser;
use App\Filament\Resources\UserResource\Pages\ListUsers;
use App\Models\User;
use App\Services\User\DeleteUser;
use BackedEnum;
use Filament\Actions\DeleteAction;
use Filament\Actions\EditAction;
use Filament\Forms\Components\Select;
use Filament\Forms\Components\TextInput;
use Filament\Notifications\Notification;
use Filament\Resources\Resource;
use Filament\Schemas\Schema;
use Filament\Support\Exceptions\Halt;
use Filament\Support\Icons\Heroicon;
use Filament\Tables\Columns\TextColumn;
use Filament\Tables\Table;
use Illuminate\Validation\ValidationException;

class UserResource extends Resource
{
    protected static ?string $model = User::class;

    protected static string|BackedEnum|null $navigationIcon = Heroicon::OutlinedUsers;

    protected static ?string $recordTitleAttribute = UserModelEnum::NAME->value;

    public static function form(Schema $schema): Schema
    {
        return $schema
            ->components([
                TextInput::make(UserModelEnum::name())
                    ->required()
                    ->maxLength(255),
                TextInput::make(UserModelEnum::email())
                    ->email()
                    ->required()
                    ->maxLength(255)
                    ->unique(ignoreRecord: true)
                    ->helperText(fn (string $operation): ?string => $operation === 'create'
                        ? 'A temporary password will be emailed to this address.'
                        : null),
                Select::make(UserModelEnum::role())
                    ->options(self::roleOptions())
                    ->required()
                    ->disabled(fn (?User $record): bool => $record instanceof User && $record->isLastAdmin())
                    ->helperText(fn (?User $record): ?string => $record instanceof User && $record->isLastAdmin()
                        ? 'The last admin cannot be demoted.'
                        : null),
                TextInput::make(UserModelEnum::password())
                    ->password()
                    ->revealable()
                    ->label('Password')
                    ->helperText('Leave blank to keep the current password.')
                    ->visible(fn (string $operation): bool => $operation === 'edit')
                    ->minLength(8)
                    ->dehydrated(fn (?string $state): bool => filled($state))
                    ->rule('confirmed'),
                TextInput::make(UserModelEnum::PASSWORD_CONFIRMATION->value)
                    ->password()
                    ->revealable()
                    ->label('Confirm password')
                    ->visible(fn (string $operation): bool => $operation === 'edit')
                    ->dehydrated(false),
            ]);
    }

    public static function table(Table $table): Table
    {
        return $table
            ->columns([
                TextColumn::make(UserModelEnum::name())
                    ->searchable()
                    ->sortable(),
                TextColumn::make(UserModelEnum::email())
                    ->searchable()
                    ->sortable(),
                TextColumn::make(UserModelEnum::role())
                    ->badge()
                    ->formatStateUsing(function (UserRole|string|null $state): string {
                        $value = $state instanceof UserRole ? $state->value : (string) $state;

                        return self::roleOptions()[$value] ?? $value;
                    })
                    ->sortable(),
                TextColumn::make(UserModelEnum::updatedAt())
                    ->label('Updated')
                    ->dateTime()
                    ->sortable(),
            ])
            ->defaultSort(UserModelEnum::name())
            ->recordActions([
                EditAction::make(),
                self::deleteAction(),
            ]);
    }

    public static function deleteAction(): DeleteAction
    {
        return DeleteAction::make()
            ->visible(function (User $record): bool {
                $actor = auth()->user();

                return $actor instanceof User
                    && app(DeleteUser::class)->denialReason($actor, $record) === null;
            })
            ->using(function (User $record): void {
                $actor = auth()->user();

                if (! $actor instanceof User) {
                    abort(403);
                }

                try {
                    app(DeleteUser::class)->handle($actor, $record);
                } catch (ValidationException $exception) {
                    Notification::make()
                        ->title(collect($exception->errors())->flatten()->first())
                        ->danger()
                        ->send();

                    throw new Halt;
                }
            });
    }

    public static function getRelations(): array
    {
        return [];
    }

    public static function getPages(): array
    {
        return [
            'index' => ListUsers::route('/'),
            'create' => CreateUser::route('/create'),
            'edit' => EditUser::route('/{record}/edit'),
        ];
    }

    /**
     * @return array<string, string>
     */
    public static function roleOptions(): array
    {
        return [
            UserRole::ADMIN->value => 'Admin',
            UserRole::MANAGER->value => 'Manager',
            UserRole::MEMBER->value => 'Member',
        ];
    }
}
