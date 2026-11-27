<?php

namespace App\Filament\Resources;

use App\Enums\Models\CategoryModelEnum;
use App\Enums\Models\SongModelEnum;
use App\Enums\Models\UserModelEnum;
use App\Filament\Resources\SongResource\Pages\CreateSong;
use App\Filament\Resources\SongResource\Pages\EditSong;
use App\Filament\Resources\SongResource\Pages\ListSongs;
use App\Models\Song;
use BackedEnum;
use Filament\Actions\BulkActionGroup;
use Filament\Actions\DeleteAction;
use Filament\Actions\DeleteBulkAction;
use Filament\Actions\EditAction;
use Filament\Forms\Components\Select;
use Filament\Forms\Components\Textarea;
use Filament\Forms\Components\TextInput;
use Filament\Infolists\Components\TextEntry;
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
                TextEntry::make('createdByUser.'.UserModelEnum::name())
                    ->label('Created by')
                    ->placeholder('Unknown')
                    ->hiddenOn('create'),
                Select::make('categories')
                    ->label('Categories')
                    ->relationship(
                        name: 'categories',
                        titleAttribute: CategoryModelEnum::name(),
                    )
                    ->multiple()
                    ->preload()
                    ->searchable()
                    ->columnSpanFull(),
                self::voiceUrlInput(
                    SongModelEnum::sopranoUrl(),
                    'Soprano',
                    'Optional web link, such as a YouTube recording.',
                ),
                self::voiceUrlInput(SongModelEnum::altoUrl(), 'Alto'),
                self::voiceUrlInput(SongModelEnum::tenorUrl(), 'Tenor'),
                self::voiceUrlInput(SongModelEnum::bassUrl(), 'Bass'),
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
                TextColumn::make('categories.'.CategoryModelEnum::name())
                    ->label('Categories')
                    ->badge(),
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

    private static function voiceUrlInput(string $name, string $label, ?string $helperText = null): TextInput
    {
        $input = TextInput::make($name)
            ->label($label)
            ->placeholder('https://www.youtube.com/watch?v=')
            ->type('url')
            ->rule('url:http,https', fn (mixed $state): bool => filled($state))
            ->maxLength(2048)
            ->columnSpanFull()
            ->dehydrateStateUsing(fn (?string $state): ?string => filled($state) ? $state : null)
            ->validationMessages([
                'url' => $label.' link must be a valid web address.',
            ]);

        if ($helperText !== null) {
            $input->helperText($helperText);
        }

        return $input;
    }
}
