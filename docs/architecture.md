# Architecture

Choird is a monorepo with two applications that share one catalog:

- `api/` — Laravel API and Filament admin panel. This is the source of truth.
- `mobile/` — Flutter app. It reads the API and keeps a local copy for offline use.

```text
Admin (browser)
    │  session login
    ▼
Filament  /admin
    │
    ▼
Laravel services ──► MySQL or PostgreSQL
    ▲
    │  unauthenticated JSON
    │
Flutter app
    │
    ▼
Drift (SQLite) on the device
```

Leaders write songs and set lists in Filament. The mobile app never writes catalog data back. It downloads songs and sets, stores them locally, and renders charts from that cache.

## API

The HTTP API lives under `/api` and exposes two REST resources:

| Resource | Routes |
| --- | --- |
| Songs | `GET/POST /api/songs`, `GET/PUT/DELETE /api/songs/{id}` |
| Sets | `GET/POST /api/sets`, `GET/PUT/DELETE /api/sets/{id}` |

List and show responses use Laravel's resource wrapper: a `data` array or object. Field names in JSON are camelCase (`keyboardTranspose`, `scheduledFor`, `setSongs`, `createdAt`). Database columns stay snake_case. Enums in `api/app/Enums/Models/` own both names and the mapping between them.

`GET /api/songs` returns every song, ordered by title. `GET /api/sets` returns every set with its songs and a short song summary (title, artist, key, capo, keyboard transpose), ordered by schedule, newest first. Full ChordPro content is not included on the set payload. The app fetches that with `GET /api/songs/{id}`.

These routes have no authentication. Form requests currently authorize every caller. The mobile app only uses the GET endpoints. Create, update, and delete exist for the same resources and are what the admin path and any future writer would use.

A health check is available at `/up`.

### Request path

Controllers in `api/app/Http/Controllers/Api/` stay thin. A write goes through:

1. A form request (`SongPostRequest`, `SongPutRequest`, `SetPostRequest`, `SetPutRequest`) that validates input and maps client field names to columns.
2. A single-action service (`CreateSong`, `UpdateSong`, `DeleteSong`, `CreateSet`, `UpdateSet`, `DeleteSet`) whose `handle()` method performs the change.
3. An API resource (`SongResource`, `SetResource`) that shapes the JSON response.

Set create and update run in a database transaction. Updating a set replaces its song rows when `setSongs` is present. Deleting a set cascades to those rows. Deleting a song is blocked while a set still references it. `scheduled_for` is unique, so two sets cannot share a time.

Models extend `BaseModel`. The base constructor sets the table name and fillable columns from the model enum, so those strings are not repeated on the model.

### Admin panel

Filament serves the admin UI at `/admin`. Login is session-based and uses the `users` table. Creating a set stamps `created_by_user_id` with the signed-in user. The panel is the supported way to edit the catalog; the mobile app does not expose those forms.

The panel reuses the same models as the API. It does not call the JSON endpoints.

### Deployment

The API is built from `api/Dockerfile` and deployed to Railway. Configuration, migrations, the queue worker, and the admin user command are described in [`api/DEPLOY.md`](../api/DEPLOY.md). Sessions, cache, and queues use the database. Production traffic is trusted from the proxy (`trustProxies` is `*`) so HTTPS and the generated domain work behind Railway.

## Mobile app

The Flutter app (`mobile/`) is a single `MaterialApp` with three tabs that stay mounted in an `IndexedStack`: Songs, Set Lists, and Settings.

### Where the API lives

`ApiConfig` chooses the base URL:

- Release builds use `https://choird-production.up.railway.app`.
- Debug builds use `localApiBaseUrl` from `api_config.local.dart` when it is set.
- Otherwise debug builds use `http://10.0.2.2:8000` on Android and `http://127.0.0.1:8000` elsewhere.

`SongApi` and `SetApi` issue GET requests and decode the `data` envelope into `Song` and `SetList`.

### Offline cache

The phone is usable with no network after one successful sync. Drift stores three tables in a SQLite database named `choird` under the app support directory:

- `songs` — full song rows, including ChordPro content
- `sets` — set metadata
- `set_songs` — order plus the short song summary needed to draw the set list

Screen code talks to repositories, not to the database or HTTP client directly.

`SongRepository`:

- `getLocalSongs()` reads the cache.
- `syncSongs()` downloads the full catalog, replaces every local song row, and records the sync time.
- `getSong(id)` returns the cached song, or fetches and upserts that one song when it is missing. Set lists use this so a chart can open offline after a set sync.

`SetRepository.syncSets()` downloads every set, then downloads the full content of each referenced song and upserts those songs. It then replaces the local sets and set-song rows. Song rows that are not part of the sync are left in place, so a set sync does not wipe a previously downloaded catalog. A song sync does the opposite: it replaces the whole song table.

Last-sync timestamps are stored separately from the database, in shared preferences (`SongSyncPreferences`, `SetSyncPreferences`). Text size uses the same store (`SongContentPreferences`).

### Charts

`ChordProParser` turns stored content into lines: empty space, section headings, or lyrics with chord positions. `ChordLyricContent` lays those lines out with chords above the lyric in a monospace face (`Roboto Mono`) so chord alignment stays stable when chords are shown.

## Data model

```text
users
  id, name, email, password, …

songs
  id, title, artist, key, capo, keyboard_transpose, content, timestamps

sets
  id, name, scheduled_for (unique), created_by_user_id → users, notes, timestamps

set_songs
  id, set_id → sets, song_id → songs, position, timestamps
  unique (set_id, position)
```

`set_songs.position` starts at 1. The admin repeater writes that order. The set screen sorts by it before display.

## What this design leaves out

These are current boundaries, not planned work:

- The JSON API is open. Possession of the base URL is enough to read or change the catalog.
- Sync is a full download, not a delta. There is no push of local edits, because the app does not edit.
- Song sync and set sync are independent. Each has its own button and timestamp.
- The mobile app has no user accounts.
