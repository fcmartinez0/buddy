# Buddy — a personal goal, journal & budget tracker

A single-file app for one focused push — you choose the window (3 to 24
months): journal daily, track goals and habits, budget your money, and stay
pointed at all of it. No accounts, no server, no build step — everything lives
in your browser's localStorage.

## Use it

Open `index.html` in any browser. That's it — data lives in that browser's
localStorage. To use it on your iPhone **and** your MacBook with the same data,
see the sync setup below.

On first run you pick a start date, a window length, and a one-line mission;
a countdown to the end of the window stays in the header.

## What's inside

- **Today** — day counter, journal streak, up to 3 focus items for the day
  (linkable to goals), a daily-habit tracker with streaks, a pomodoro focus
  timer (25+5), a quick journal box, a guided weekly review, a rotating
  research-backed "technique of the day", per-goal progress bars, and a
  calendar heatmap of journaling consistency across the whole window.
- **Goals** — each goal has a "why", optional target date, and milestones;
  progress comes from checking milestones off (or a manual slider via
  check-ins for goals without them). A nudge appears when a goal has gone a
  week without a check-in. One-click templates cover networking,
  cybersecurity, gym, screen time, and saving money.
- **Budget** — monthly income + planned spending per category, quick expense
  logging, this-month-vs-plan bars with overspend warnings, and a cumulative
  savings projection chart with **scenario sliders**: drag any category to
  "what if I spent this much instead" and watch where the dashed what-if line
  lands by the end of your window.
- **Journal** — one entry a day (more if you insist): mood, wins, free text,
  and tags linking the entry to goals. Weekly reviews land here too.

## The productivity science baked in

The app's mechanics come from behavior-change research rather than vibes:
**implementation intentions** (if-then phrasing in the focus list — a
meta-analysis of 94 studies found medium-to-large effects on follow-through),
**habit stacking and environment design** (habit suggestions and templates),
**the progress principle** (wins line, streaks, visible progress bars),
**weekly reviews**, the **fresh start effect** (the window itself), and
**pay-yourself-first budgeting**. Fifteen techniques rotate daily on the
Today tab.

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
   **Add to Home Screen** (it installs as a full-screen standalone app with
   its own icon), open it, and paste the same token in settings. It finds the
   gist and pulls everything down. After the first online visit a service
   worker keeps the app working offline; changes sync next time you're
   connected.

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
