# Buddy — a personal 6-month tracker

A single-file app for one 6-month push: journal daily, track a handful of goals,
and stay pointed at them. No accounts, no server, no build step — everything
lives in your browser's localStorage.

## Use it

Open `index.html` in any browser. That's it. Bookmark it (or serve it via
GitHub Pages) and use the **same browser** each time, since that's where your
data lives.

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

## Your data

Stored only in this browser under the `buddy-tracker-v1` localStorage key.
Use **Settings → Export data** for a JSON backup and **Import data** to
restore it (e.g. on a new machine).
