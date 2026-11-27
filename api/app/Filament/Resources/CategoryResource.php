<?php

namespace App\Filament\Resources;

use App\Enums\Models\CategoryModelEnum;
use App\Filament\Resources\CategoryResource\Pages\CreateCategory;
use App\Filament\Resources\CategoryResource\Pages\EditCategory;
use App\Filament\Resources\CategoryResource\Pages\ListCategories;
use App\Models\Category;
use App\Services\Category\DeleteCategory;
use BackedEnum;
use Filament\Actions\BulkActionGroup;
use Filament\Actions\DeleteAction;
use Filament\Actions\DeleteBulkAction;
use Filament\Actions\EditAction;
use Filament\Forms\Components\TextInput;
use Filament\Notifications\Notification;
use Filament\Resources\Resource;
use Filament\Schemas\Schema;
use Filament\Support\Exceptions\Halt;
use Filament\Support\Icons\Heroicon;
use Filament\Tables\Columns\TextColumn;
use Filament\Tables\Table;
use Illuminate\Database\Eloquent\Collection as EloquentCollection;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Support\Collection;
use Illuminate\Support\LazyCollection;
use Illuminate\Validation\ValidationException;

class CategoryResource extends Resource
{
    protected static ?string $model = Category::class;

    protected static string|BackedEnum|null $navigationIcon = Heroicon::OutlinedTag;

    protected static ?string $recordTitleAttribute = CategoryModelEnum::NAME->value;

    public static function form(Schema $schema): Schema
    {
        return $schema
            ->components([
                TextInput::make(CategoryModelEnum::name())
                    ->required()
                    ->maxLength(255)
                    ->unique(ignoreRecord: true),
            ]);
    }

    public static function table(Table $table): Table
    {
        return $table
            ->columns([
                TextColumn::make(CategoryModelEnum::name())
                    ->searchable()
                    ->sortable(),
                TextColumn::make('songs_count')
                    ->counts('songs')
                    ->label('Songs')
                    ->sortable(),
                TextColumn::make(CategoryModelEnum::updatedAt())
                    ->label('Updated')
                    ->dateTime()
                    ->sortable(),
            ])
            ->defaultSort(CategoryModelEnum::name())
            ->recordActions([
                EditAction::make(),
                self::deleteAction(),
            ])
            ->toolbarActions([
                BulkActionGroup::make([
                    self::deleteBulkAction(),
                ]),
            ]);
    }

    public static function deleteAction(): DeleteAction
    {
        return DeleteAction::make()
            ->using(function (Category $record): bool {
                try {
                    app(DeleteCategory::class)->handle($record);
                } catch (ValidationException $exception) {
                    Notification::make()
                        ->title(self::validationMessage($exception))
                        ->danger()
                        ->send();

                    throw new Halt;
                }

                return true;
            });
    }

    public static function deleteBulkAction(): DeleteBulkAction
    {
        return DeleteBulkAction::make()
            ->using(function (DeleteBulkAction $action, EloquentCollection|Collection|LazyCollection $records): void {
                $records->each(function (Model $record) use ($action): void {
                    if (! $record instanceof Category) {
                        return;
                    }

                    try {
                        app(DeleteCategory::class)->handle($record);
                    } catch (ValidationException $exception) {
                        $action->reportBulkProcessingFailure(
                            'in_use',
                            self::validationMessage($exception),
                        );
                    }
                });
            });
    }

    public static function getRelations(): array
    {
        return [];
    }

    public static function getPages(): array
    {
        return [
            'index' => ListCategories::route('/'),
            'create' => CreateCategory::route('/create'),
            'edit' => EditCategory::route('/{record}/edit'),
        ];
    }

    private static function validationMessage(ValidationException $exception): string
    {
        $message = collect($exception->errors())->flatten()->first();

        return is_string($message) ? $message : DeleteCategory::IN_USE_MESSAGE;
    }
}
