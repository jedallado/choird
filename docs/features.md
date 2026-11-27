# Features

Choird is an app for managing choir songs with lyrics and chords. Content is created in a web admin panel. The mobile app downloads that content and lets singers read it offline.

The mobile app does not create or edit songs or set lists. Those changes happen in the admin panel, then reach phones the next time someone syncs.

## Songs

A song is the chart a singer reads during rehearsal or a service.

Each song stores:

| Field | Purpose |
| --- | --- |
| Title | Name shown in lists and on the song screen |
| Artist | Optional |
| Key | Optional chart key, such as `G` |
| Capo | Optional fret, `0`–`11`. Shown only when greater than `0` |
| Keyboard transpose | Optional semitone shift from the chart key, `-11` to `+11`. `+2` means up a whole step. Shown only when it is not `0` |
| Content | Lyrics and chords in ChordPro |

### Admin

Leaders create, edit, search, and delete songs at `/admin`. The content field expects ChordPro, for example:

```text
[G]Amazing grace how [C]sweet the sound
```

Songs can be deleted one at a time or in bulk. A song that is still on a set list cannot be deleted, because set songs reference it.

### Mobile

The Songs tab lists the local catalog, sorted by title. Each row shows the title, the artist when present, and the key as a chip.

- Search filters the local list by title or artist. It does not call the server.
- Pull to refresh, or the sync button, downloads the full catalog and replaces the local copy.
- The screen shows the last successful sync time.
- Before the first sync, the empty state asks the user to connect once so songs can be used offline.
- If a sync fails and songs are already stored, the existing list stays and an error is shown. If nothing is stored yet, the error replaces the empty state.

Opening a song shows the artist, performance badges (key, capo, keyboard transpose), and the parsed ChordPro chart.

While reading a song, the singer can:

- Show or hide chords. Chords start visible. This choice lasts only for the current visit.
- Change text size across Small (14), Medium (16), Large (18), and Extra Large (20). The choice is saved on the device.
- Hide or show the bottom toolbar so the chart can use the full screen.

## Set lists

A set list is an ordered group of songs scheduled for a specific date and time, such as a Sunday service.

Each set stores:

| Field | Purpose |
| --- | --- |
| Name | Optional. The app shows "Untitled set" when it is blank |
| Scheduled for | Required date and time. Only one set may use a given time |
| Notes | Optional text shown at the top of the set |
| Songs | At least one song, in a chosen order |
| Created by | The admin user who created the set |

### Admin

Leaders create, edit, search, and delete set lists at `/admin`. The form includes a reorderable list of songs. The creator is recorded automatically from the signed-in admin. The list defaults to the soonest-upcoming schedule last (newest scheduled time first) and shows the song count and creator.

### Mobile

The Set Lists tab lists locally stored sets, newest schedule first. Each row shows the name, the local date and time, and the song count.

Sync works the same way as songs: pull to refresh or the sync button, a last-synced timestamp, and the same empty and error behavior. Syncing set lists also downloads the full chart for every song on those sets, so a song can be opened from a set without a separate song-catalog sync.

Opening a set shows the schedule, notes, and songs in position order. Each song row shows its position, title, artist, and key. Tapping a song opens the chart. Previous and next buttons move through the set without returning to the list.

## Chord charts

Song content is stored as ChordPro and rendered on the phone.

- Chords in square brackets, such as `[G]`, sit above the lyric they belong to.
- Section markers such as verse, chorus, bridge, intro, outro, pre-chorus, tag, and solo are shown as headings. Short aliases (`soc`, `eoc`, and similar) are recognized.
- Metadata lines such as `{title: ...}` and `{key: ...}` are not drawn as lyrics. Title, artist, key, and capo already have their own fields.
- Empty lines are preserved so the chart keeps its spacing.

## Settings

Settings is in the header menu. It shows who is signed in and a sign-out button, plus the installed app version and build number. Text size is changed on the song screen, not here. Signing out leaves downloaded songs and set lists on the phone, but they stay hidden until the next sign-in. The same menu opens Home (Songs and Set Lists) and a Posts screen that says coming soon.

## Accounts

The API has three roles. An admin can do everything, including creating users and assigning roles. A manager can edit songs and set lists, and can edit their own profile, but cannot manage users. A member can read songs and set lists and can edit their own name, email, and password.

Admins and managers sign in to the admin panel at `/admin/login`. Members cannot. Admins manage users from the Users screen in that panel. Creating a user there emails them a temporary password. Managers do not see that screen. API clients sign in with `POST /api/login` and send the bearer token for a week.

The mobile app asks for that same email and password before showing songs or set lists. The token is saved on the phone and sent with each request until it expires or the singer signs out.
