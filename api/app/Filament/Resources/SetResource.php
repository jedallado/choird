<?php

namespace App\Filament\Resources;

use App\Enums\Models\SetModelEnum;
use App\Enums\Models\SetSongModelEnum;
use App\Enums\Models\SongModelEnum;
use App\Filament\Resources\SetResource\Pages\CreateSet;
use App\Filament\Resources\SetResource\Pages\EditSet;
use App\Filament\Resources\SetResource\Pages\ListSets;
use App\Models\Set;
use App\Models\Song;
use BackedEnum;
use Filament\Actions\BulkActionGroup;
use Filament\Actions\DeleteAction;
use Filament\Actions\DeleteBulkAction;
use Filament\Actions\EditAction;
use Filament\Forms\Components\DateTimePicker;
use Filament\Forms\Components\Repeater;
use Filament\Forms\Components\Select;
use Filament\Forms\Components\Textarea;
use Filament\Forms\Components\TextInput;
use Filament\Resources\Resource;
use Filament\Schemas\Schema;
use Filament\Support\Icons\Heroicon;
use Filament\Tables\Columns\TextColumn;
use Filament\Tables\Table;

class SetResource extends Resource
{
    protected static ?string $model = Set::class;

    protected static string|BackedEnum|null $navigationIcon = Heroicon::OutlinedQueueList;

    protected static ?string $recordTitleAttribute = 'name';

    public static function form(Schema $schema): Schema
    {
        return $schema
            ->components([
                TextInput::make(SetModelEnum::name())
                    ->maxLength(255)
                    ->placeholder('Sunday Worship'),
                DateTimePicker::make(SetModelEnum::scheduledFor())
                    ->label('Scheduled for')
                    ->required()
                    ->seconds(false)
                    ->unique(ignoreRecord: true),
                Textarea::make(SetModelEnum::notes())
                    ->rows(3)
                    ->columnSpanFull(),
                Repeater::make('setSongs')
                    ->relationship()
                    ->orderColumn(SetSongModelEnum::position())
                    ->schema([
                        Select::make(SetSongModelEnum::songId())
                            ->label('Song')
                            ->relationship('song', SongModelEnum::title())
                            ->searchable()
                            ->preload()
                            ->required(),
                    ])
                    ->addActionLabel('Add song')
                    ->reorderable()
                    ->collapsible()
                    ->minItems(1)
                    ->columnSpanFull()
                    ->itemLabel(fn (array $state): ?string => isset($state[SetSongModelEnum::songId()])
                        ? (string) (Song::query()->find($state[SetSongModelEnum::songId()])?->getAttribute(SongModelEnum::title()) ?? 'Song')
                        : null),
            ]);
    }

    public static function table(Table $table): Table
    {
        return $table
            ->columns([
                TextColumn::make(SetModelEnum::name())
                    ->searchable()
                    ->sortable()
                    ->placeholder('Untitled set'),
                TextColumn::make(SetModelEnum::scheduledFor())
                    ->label('Scheduled for')
                    ->dateTime()
                    ->sortable(),
                TextColumn::make('set_songs_count')
                    ->counts('setSongs')
                    ->label('Songs'),
                TextColumn::make('createdByUser.name')
                    ->label('Created by')
                    ->sortable(),
                TextColumn::make(SetModelEnum::updatedAt())
                    ->label('Updated')
                    ->dateTime()
                    ->sortable(),
            ])
            ->defaultSort(SetModelEnum::scheduledFor(), 'desc')
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
            'index' => ListSets::route('/'),
            'create' => CreateSet::route('/create'),
            'edit' => EditSet::route('/{record}/edit'),
        ];
    }
}
