<!DOCTYPE html>
<html lang="{{ str_replace('_', '-', app()->getLocale()) }}" class="scroll-smooth">
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Choird — Songs &amp; sets for your choir</title>
    <meta name="description" content="[Placeholder: one-sentence description of Choird for search engines.]">

    <link rel="preconnect" href="https://fonts.bunny.net">
    <link href="https://fonts.bunny.net/css?family=figtree:400,500,600,700|fraunces:600,700" rel="stylesheet">
    @vite(['resources/css/app.css'])
</head>
<body class="landing-bg font-figtree text-ink antialiased">

    {{-- Navigation --}}
    <header class="sticky top-0 z-50 border-b border-accent/10 bg-paper/80 backdrop-blur">
        <nav class="mx-auto flex max-w-6xl items-center justify-between px-6 py-4">
            <a href="#top" class="flex flex-col gap-1">
                <span class="font-display text-2xl font-semibold leading-none tracking-tight">Choird</span>
                <span class="text-[0.6rem] font-medium uppercase tracking-[0.18em] text-accent">Songs &amp; sets</span>
            </a>
            <ul class="hidden items-center gap-8 text-sm font-medium text-ink/70 md:flex">
                <li><a class="hover:text-accent" href="#features">Features</a></li>
                <li><a class="hover:text-accent" href="#how-it-works">How it works</a></li>
                <li><a class="hover:text-accent" href="#screens">Screens</a></li>
                <li><a class="hover:text-accent" href="#about">About</a></li>
                <li><a class="hover:text-accent" href="#contact">Contact</a></li>
            </ul>
            <a href="{{ url('/admin/login') }}"
               class="rounded-full border border-accent/40 px-4 py-2 text-sm font-semibold text-accent-dark transition hover:bg-accent hover:text-white">
                Manager login
            </a>
        </nav>
    </header>

    <main id="top">

        {{-- Hero --}}
        <section class="mx-auto grid max-w-6xl items-center gap-12 px-6 pb-20 pt-16 md:grid-cols-2 md:pt-24">
            <div>
                <p class="mb-4 inline-block rounded-full bg-accent/10 px-3 py-1 text-xs font-semibold uppercase tracking-widest text-accent-dark">
                    [Placeholder: tagline badge]
                </p>
                <h1 class="font-display text-4xl font-semibold leading-[1.1] tracking-tight sm:text-5xl lg:text-6xl">
                    Every song. Every chord.
                    <span class="text-accent">Always in tune.</span>
                </h1>
                <p class="mt-6 max-w-xl text-lg leading-relaxed text-ink/70">
                    Choird is a choir songbook. Managers prepare songs and set lists in one place, and singers read
                    lyrics and chords on their phones, even offline.
                    [Placeholder: refine this hero paragraph.]
                </p>

                <div class="mt-8 flex flex-wrap items-center gap-3">
                    <a href="#" class="flex items-center gap-3 rounded-xl bg-ink px-5 py-3 text-white transition hover:bg-accent-dark">
                        <svg class="h-6 w-6" viewBox="0 0 24 24" fill="currentColor" aria-hidden="true"><path d="M16.4 12.6c0-2.3 1.9-3.4 2-3.5-1.1-1.6-2.8-1.8-3.4-1.8-1.4-.1-2.8.9-3.5.9s-1.8-.8-3-.8c-1.5 0-3 .9-3.8 2.3-1.6 2.8-.4 7 1.2 9.3.8 1.1 1.700 2.400 2.900 2.300 1.200 0 1.600-.8 3-.8s1.800.8 3 .7c1.300 0 2.100-1.100 2.800-2.200.9-1.300 1.300-2.500 1.300-2.600-.1 0-2.500-1-2.500-3.800zM14.200 5.700c.6-.8 1.100-1.800.9-2.900-.9 0-2 .6-2.700 1.400-.6.700-1.100 1.800-.9 2.800 1 .1 2-.5 2.700-1.300z"/></svg>
                        <span class="text-left leading-tight">
                            <span class="block text-[0.65rem] uppercase tracking-wider text-white/70">Download on the</span>
                            <span class="block text-base font-semibold">App Store</span>
                        </span>
                    </a>
                    <a href="#" class="flex items-center gap-3 rounded-xl bg-ink px-5 py-3 text-white transition hover:bg-accent-dark">
                        <svg class="h-6 w-6" viewBox="0 0 24 24" fill="currentColor" aria-hidden="true"><path d="M4 2.8v18.4c0 .5.5.8.9.6l16-9.2c.4-.2.4-.8 0-1L4.900 2.200c-.4-.2-.9.100-.9.600z"/></svg>
                        <span class="text-left leading-tight">
                            <span class="block text-[0.65rem] uppercase tracking-wider text-white/70">Get it on</span>
                            <span class="block text-base font-semibold">Google Play</span>
                        </span>
                    </a>
                </div>
                <p class="mt-4 text-sm text-ink/50">
                    Choir manager?
                    <a href="{{ url('/admin/login') }}" class="font-semibold text-accent-dark underline underline-offset-4 hover:text-accent">Sign in to the admin panel</a>
                </p>
            </div>

            {{-- Phone mockup (placeholder screenshot) --}}
            <div class="relative mx-auto w-full max-w-xs">
                <div class="absolute -inset-6 -z-10 rounded-[3rem] bg-accent/10 blur-2xl"></div>
                <div class="rounded-[2.5rem] border-[10px] border-ink bg-ink shadow-2xl shadow-accent/30">
                    <div class="overflow-hidden rounded-[1.8rem] bg-paper">
                        <div class="border-b border-outline bg-white/60 px-5 py-4">
                            <p class="font-display text-lg font-semibold">Amazing Grace</p>
                            <p class="text-xs text-ink/50">John Newton</p>
                            <div class="mt-2 flex gap-2 text-[0.65rem] font-semibold">
                                <span class="rounded-full bg-chord/10 px-2 py-0.5 text-chord">Key G</span>
                                <span class="rounded-full bg-accent/10 px-2 py-0.5 text-accent-dark">Capo 2</span>
                            </div>
                        </div>
                        <div class="space-y-5 px-5 py-6 font-mono text-sm leading-tight">
                            <div>
                                <p class="font-bold text-chord">G &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;C &nbsp;&nbsp;G</p>
                                <p>Amazing grace how sweet</p>
                            </div>
                            <div>
                                <p class="font-bold text-chord">G &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;D</p>
                                <p>the sound that saved</p>
                            </div>
                            <div>
                                <p class="font-bold text-chord">G &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;C &nbsp;&nbsp;G</p>
                                <p>a wretch like me</p>
                            </div>
                            <p class="text-center text-[0.65rem] uppercase tracking-widest text-ink/30">[Placeholder: app screenshot]</p>
                        </div>
                    </div>
                </div>
            </div>
        </section>

        {{-- Features --}}
        <section id="features" class="mx-auto max-w-6xl px-6 py-20">
            <div class="mx-auto max-w-2xl text-center">
                <p class="text-xs font-semibold uppercase tracking-[0.18em] text-accent">Features</p>
                <h2 class="mt-3 font-display text-3xl font-semibold tracking-tight sm:text-4xl">Everything your choir needs on a Sunday</h2>
                <p class="mt-4 text-ink/70">[Placeholder: short intro to the features.]</p>
            </div>

            @php
                $features = [
                    ['title' => 'Lyrics & chords', 'body' => 'Chords sit right above the words they belong to, rendered cleanly from ChordPro.', 'icon' => 'M9 18V5l12-2v13M9 18a3 3 0 11-6 0 3 3 0 016 0zm12-2a3 3 0 11-6 0 3 3 0 016 0z'],
                    ['title' => 'Works offline', 'body' => 'Sync once, then read songs and sets anywhere, even without a signal in the sanctuary.', 'icon' => 'M3 15a4 4 0 004 4h9a5 5 0 10-.1-9.999 5.002 5.002 0 10-9.780 1.400A4.002 4.002 0 003 15z'],
                    ['title' => 'Set lists', 'body' => 'Songs in order for a specific date and time, with notes from the manager at the top.', 'icon' => 'M8 6h13M8 12h13M8 18h13M3 6h.01M3 12h.01M3 18h.01'],
                    ['title' => 'Key, capo & transpose', 'body' => 'Performance badges show the key, capo fret, and keyboard transpose at a glance.', 'icon' => 'M12 6v6l4 2m6-2a10 10 0 11-20 0 10 10 0 0120 0z'],
                    ['title' => 'Readable your way', 'body' => 'Show or hide chords, pick a comfortable text size, and go full screen to read.', 'icon' => 'M4 7V5h16v2M9 19h6M12 5v14'],
                    ['title' => 'Manager admin panel', 'body' => 'Managers manage songs, set lists, and users from a simple web admin panel.', 'icon' => 'M16 7a4 4 0 11-8 0 4 4 0 018 0zM12 14a7 7 0 00-7 7h14a7 7 0 00-7-7z'],
                ];
            @endphp

            <div class="mt-14 grid gap-6 sm:grid-cols-2 lg:grid-cols-3">
                @foreach ($features as $feature)
                    <article class="rounded-2xl border border-accent/15 bg-white/70 p-6 shadow-sm shadow-accent/5 transition hover:-translate-y-1 hover:shadow-lg hover:shadow-accent/10">
                        <span class="flex h-11 w-11 items-center justify-center rounded-xl bg-accent/10 text-accent-dark">
                            <svg class="h-5 w-5" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><path d="{{ $feature['icon'] }}"/></svg>
                        </span>
                        <h3 class="mt-5 font-display text-xl font-semibold">{{ $feature['title'] }}</h3>
                        <p class="mt-2 text-sm leading-relaxed text-ink/70">{{ $feature['body'] }}</p>
                    </article>
                @endforeach
            </div>
        </section>

        {{-- How it works --}}
        <section id="how-it-works" class="bg-ink py-20 text-paper">
            <div class="mx-auto max-w-6xl px-6">
                <div class="mx-auto max-w-2xl text-center">
                    <p class="text-xs font-semibold uppercase tracking-[0.18em] text-[#bcaaa4]">How it works</p>
                    <h2 class="mt-3 font-display text-3xl font-semibold tracking-tight sm:text-4xl">From the admin panel to every phone</h2>
                </div>
                <ol class="mt-14 grid gap-8 md:grid-cols-3">
                    @foreach ([
                        ['Prepare', 'Managers add songs in ChordPro and schedule set lists in the admin panel.'],
                        ['Sync', 'Singers sign in and sync once. Songs and sets are saved on the phone.'],
                        ['Sing', 'Open the set, follow along with chords, and move through songs with one tap.'],
                    ] as $i => [$title, $body])
                        <li class="rounded-2xl border border-white/10 bg-white/5 p-8">
                            <span class="font-display text-5xl font-semibold text-[#bcaaa4]">{{ $i + 1 }}</span>
                            <h3 class="mt-4 font-display text-xl font-semibold">{{ $title }}</h3>
                            <p class="mt-2 text-sm leading-relaxed text-paper/70">{{ $body }}</p>
                        </li>
                    @endforeach
                </ol>
            </div>
        </section>

        {{-- Screens --}}
        <section id="screens" class="mx-auto max-w-6xl px-6 py-20">
            <div class="mx-auto max-w-2xl text-center">
                <p class="text-xs font-semibold uppercase tracking-[0.18em] text-accent">Screens</p>
                <h2 class="mt-3 font-display text-3xl font-semibold tracking-tight sm:text-4xl">A look inside the app</h2>
                <p class="mt-4 text-ink/70">[Placeholder: replace these with real screenshots.]</p>
            </div>
            <div class="mt-14 grid gap-8 sm:grid-cols-2 lg:grid-cols-4">
                @foreach (['Songs list', 'Song chart', 'Set lists', 'Settings'] as $label)
                    <figure class="text-center">
                        <div class="mx-auto flex aspect-[9/19] w-full max-w-[13rem] items-center justify-center rounded-[1.75rem] border-[6px] border-ink bg-paper-deep shadow-xl shadow-accent/20">
                            <span class="px-4 text-xs font-medium uppercase tracking-widest text-accent">[Screenshot]</span>
                        </div>
                        <figcaption class="mt-4 text-sm font-semibold text-ink/70">{{ $label }}</figcaption>
                    </figure>
                @endforeach
            </div>
        </section>

        {{-- About --}}
        <section id="about" class="border-y border-accent/10 bg-white/50 py-20">
            <div class="mx-auto grid max-w-6xl items-center gap-12 px-6 md:grid-cols-2">
                <div class="flex aspect-[4/3] items-center justify-center rounded-3xl border border-dashed border-accent/40 bg-paper-deep">
                    <span class="text-xs font-medium uppercase tracking-widest text-accent">[Placeholder: team or choir photo]</span>
                </div>
                <div>
                    <p class="text-xs font-semibold uppercase tracking-[0.18em] text-accent">About</p>
                    <h2 class="mt-3 font-display text-3xl font-semibold tracking-tight sm:text-4xl">Built for choirs, by [Placeholder: your name/team]</h2>
                    <p class="mt-5 leading-relaxed text-ink/70">
                        [Placeholder: tell the story behind Choird. Why you built it, who it's for, and what you
                        hope it does for choirs and worship teams.]
                    </p>
                    <p class="mt-4 leading-relaxed text-ink/70">
                        [Placeholder: second paragraph about your mission or values.]
                    </p>
                    <dl class="mt-8 grid grid-cols-3 gap-4 text-center">
                        @foreach ([['[00]', 'Choirs'], ['[000]', 'Songs'], ['[00]', 'Managers']] as [$value, $label])
                            <div class="rounded-xl border border-accent/15 bg-white/70 p-4">
                                <dt class="font-display text-2xl font-semibold text-accent-dark">{{ $value }}</dt>
                                <dd class="mt-1 text-xs uppercase tracking-wider text-ink/50">{{ $label }}</dd>
                            </div>
                        @endforeach
                    </dl>
                </div>
            </div>
        </section>

        {{-- Contact --}}
        <section id="contact" class="mx-auto max-w-6xl px-6 py-20">
            <div class="grid gap-12 md:grid-cols-5">
                <div class="md:col-span-2">
                    <p class="text-xs font-semibold uppercase tracking-[0.18em] text-accent">Contact us</p>
                    <h2 class="mt-3 font-display text-3xl font-semibold tracking-tight sm:text-4xl">Let's talk</h2>
                    <p class="mt-4 leading-relaxed text-ink/70">
                        [Placeholder: invite visitors to reach out with questions, feedback, or to bring Choird to their choir.]
                    </p>
                    <ul class="mt-8 space-y-4 text-sm">
                        <li class="flex items-center gap-3">
                            <span class="flex h-9 w-9 items-center justify-center rounded-lg bg-accent/10 text-accent-dark">
                                <svg class="h-4 w-4" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><path d="M3 8l9 6 9-6M5 5h14a2 2 0 012 2v10a2 2 0 01-2 2H5a2 2 0 01-2-2V7a2 2 0 012-2z"/></svg>
                            </span>
                            [placeholder@choird.app]
                        </li>
                        <li class="flex items-center gap-3">
                            <span class="flex h-9 w-9 items-center justify-center rounded-lg bg-accent/10 text-accent-dark">
                                <svg class="h-4 w-4" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><path d="M12 21s7-6.2 7-12a7 7 0 10-14 0c0 5.800 7 12 7 12zm0-9a3 3 0 100-6 3 3 0 000 6z"/></svg>
                            </span>
                            [Placeholder: location]
                        </li>
                    </ul>
                </div>

                <form id="contact-form" class="space-y-5 rounded-3xl border border-accent/15 bg-white/80 p-8 shadow-xl shadow-accent/10 md:col-span-3" novalidate>
                    <div class="grid gap-5 sm:grid-cols-2">
                        <label class="block text-sm font-medium">
                            Name
                            <input type="text" name="name" placeholder="Your name" class="mt-1.5 w-full rounded-xl border border-outline bg-paper px-4 py-3 text-sm outline-none transition focus:border-accent focus:ring-2 focus:ring-accent/20">
                        </label>
                        <label class="block text-sm font-medium">
                            Email
                            <input type="email" name="email" placeholder="you@example.com" class="mt-1.5 w-full rounded-xl border border-outline bg-paper px-4 py-3 text-sm outline-none transition focus:border-accent focus:ring-2 focus:ring-accent/20">
                        </label>
                    </div>
                    <label class="block text-sm font-medium">
                        Message
                        <textarea name="message" rows="5" placeholder="How can we help?" class="mt-1.5 w-full rounded-xl border border-outline bg-paper px-4 py-3 text-sm outline-none transition focus:border-accent focus:ring-2 focus:ring-accent/20"></textarea>
                    </label>
                    <button type="submit" class="w-full rounded-xl bg-accent px-6 py-3.5 text-sm font-semibold text-white transition hover:bg-accent-dark sm:w-auto">
                        Send message
                    </button>
                    <p id="contact-note" class="hidden text-sm text-accent-dark">
                        This form isn't connected yet. [Placeholder: success message.]
                    </p>
                </form>
            </div>
        </section>
    </main>

    {{-- Footer --}}
    <footer class="border-t border-accent/10 bg-paper-deep/60">
        <div class="mx-auto flex max-w-6xl flex-col items-center justify-between gap-4 px-6 py-8 text-sm text-ink/60 sm:flex-row">
            <div class="flex items-baseline gap-2">
                <span class="font-display text-lg font-semibold text-ink">Choird</span>
                <span class="text-[0.6rem] font-medium uppercase tracking-[0.18em] text-accent">Songs &amp; sets</span>
            </div>
            <p>&copy; {{ date('Y') }} Choird. All rights reserved.</p>
            <a href="{{ url('/admin/login') }}" class="font-medium hover:text-accent">Manager login</a>
        </div>
    </footer>

    <script>
        document.getElementById('contact-form').addEventListener('submit', function (e) {
            e.preventDefault();
            document.getElementById('contact-note').classList.remove('hidden');
        });
    </script>
</body>
</html>
