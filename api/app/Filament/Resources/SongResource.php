<?php

namespace App\Filament\Resources;

use App\Enums\Models\SongModelEnum;
use App\Filament\Resources\SongResource\Pages\CreateSong;
use App\Filament\Resources\SongResource\Pages\EditSong;
use App\Filament\Resources\SongResource\Pages\ListSongs;
use App\Models\Song;
use BackedEnum;
use Filament\Actions\BulkActionGroup;
use Filament\Actions\DeleteAction;
use Filament\Actions\DeleteBulkAction;
use Filament\Actions\EditAction;
use Filament\Forms\Components\Textarea;
use Filament\Forms\Components\TextInput;
use Filament\Resources\Resource;
use Filament\Schemas\Schema;
use Filament\Support\Icons\Heroicon;
use Filament\Tables\Columns\TextColumn;
use Filament\Tables\Table;

class SongResource extends Resource
{
    protected static ?string $model = Song::class;

    protected static string|BackedEnum|null $navigationIcon = Heroicon::OutlinedMusicalNote;

    protected static ?string $recordTitleAttribute = 'title';

    public static function form(Schema $schema): Schema
    {
        return $schema
            ->components([
                TextInput::make(SongModelEnum::title())
                    ->required()
                    ->maxLength(255),
                TextInput::make(SongModelEnum::artist())
                    ->maxLength(255),
                TextInput::make(SongModelEnum::key())
                    ->label('Key')
                    ->maxLength(10)
                    ->placeholder('G'),
                TextInput::make(SongModelEnum::capo())
                    ->label('Capo')
                    ->numeric()
                    ->minValue(0)
                    ->maxValue(11)
                    ->placeholder('0–11'),
                TextInput::make(SongModelEnum::keyboardTranspose())
                    ->label('Keyboard transpose')
                    ->numeric()
                    ->minValue(-11)
                    ->maxValue(11)
                    ->helperText('Semitones from chart key. +2 = up a whole step.'),
                Textarea::make(SongModelEnum::content())
                    ->required()
                    ->rows(20)
                    ->columnSpanFull()
                    ->helperText('ChordPro format, e.g. [G]Amazing grace how [C]sweet the sound'),
            ]);
    }

    public static function table(Table $table): Table
    {
        return $table
            ->columns([
                TextColumn::make(SongModelEnum::title())
                    ->searchable()
                    ->sortable(),
                TextColumn::make(SongModelEnum::artist())
                    ->searchable()
                    ->sortable(),
                TextColumn::make(SongModelEnum::key())
                    ->label('Key')
                    ->sortable(),
                TextColumn::make(SongModelEnum::capo())
                    ->label('Capo')
                    ->sortable(),
                TextColumn::make(SongModelEnum::keyboardTranspose())
                    ->label('Keyboard')
                    ->sortable(),
                TextColumn::make(SongModelEnum::updatedAt())
                    ->label('Updated')
                    ->dateTime()
                    ->sortable(),
            ])
            ->filters([
                //
            ])
            ->recordActions([
                EditAction::make(),
                DeleteAction::make(),
            ])
            ->toolbarActions([
                BulkActionGroup::make([
                    DeleteBulkAction::make(),
                ]),
            ]);
    }

    public static function getRelations(): array
    {
        return [
            //
        ];
    }

    public static function getPages(): array
    {
        return [
            'index' => ListSongs::route('/'),
            'create' => CreateSong::route('/create'),
            'edit' => EditSong::route('/{record}/edit'),
        ];
    }
}
