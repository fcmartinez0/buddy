# Buddy — a personal 6-month tracker

A single-file app for one 6-month push: journal daily, track a handful of goals,
and stay pointed at them. No accounts, no server, no build step — everything
lives in your browser's localStorage.

## Use it

Open `index.html` in any browser. That's it — data lives in that browser's
localStorage. To use it on your iPhone **and** your MacBook with the same data,
see the sync setup below.

On first run you pick a start date and write a one-line mission; the window
ends exactly 6 months later and a countdown stays in the header.

## What's inside

- **Today** — day counter, journal streak, up to 3 focus items for the day
  (linkable to goals), a quick journal box, per-goal progress bars, and a
  calendar heatmap of your journaling consistency across the whole window.
- **Goals** — each goal has a "why", optional target date, and milestones;
  progress comes from checking milestones off (or a manual slider via
  check-ins for goals without them). A nudge appears when a goal has gone a
  week without a check-in.
- **Journal** — one entry a day (more if you insist): mood, wins, free text,
  and tags linking the entry to goals. Editable after the fact.

## iPhone + MacBook, synced

Sync works through a **private GitHub gist** — no server of your own, and it
works in Safari on iOS and any browser on the Mac. One-time setup:

1. **Host the app at a URL** so both devices open the same page: in this
   repo's GitHub settings go to *Pages* → deploy from branch → `main`, root.
   Your app will be at `https://<username>.github.io/buddy/`.
2. **Create a sync token**: GitHub → Settings → Developer settings →
   *Personal access tokens (classic)* → generate new token with **only the
   `gist` scope** and a long expiration. Copy it.
3. **On the MacBook**: open the app, gear icon → *Sync across devices*,
   paste the token, hit *Connect & sync*. Buddy creates a private gist
   (`buddy-tracker.json`) and pushes your data to it.
4. **On the iPhone**: open the same URL in Safari, tap Share →
   **Add to Home Screen** (it installs like an app), open it, and paste the
   same token in settings. It finds the gist and pulls everything down.

From then on both devices sync automatically — a couple of seconds after any
change, whenever the app comes back to the foreground, and on demand via the
✓/⟳ pill in the header. Edits merge per item (newest wins) and deletions
propagate properly, so it's fine to use both devices in the same day.

**Token notes:** the token is stored only in each device's browser storage and
is sent only to `api.github.com`. Scoping it to `gist` means that even if a
device is compromised, the token can't touch your repositories. It is *not*
included in Settings → Export data backups.

## Your data

Stored in each browser under the `buddy-tracker-v1` localStorage key, plus the
private gist when sync is on. Use **Settings → Export data** for a JSON backup
and **Import data** to restore it.
