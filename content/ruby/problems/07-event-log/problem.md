# 07 · Member Engagement Event Log (parsing + aggregation)

You receive raw lines from a partner feed in the form `"timestamp,member_id,event_type"`, e.g. `"1700,m42,call_completed"`. Feeds are messy. This is the data-wrangling style of question, close to what their Partner Data Exchange team does.

---

## Part 1: ingest and count

- `ingest(line)` returns `true` if the line was stored, or `false` if it was malformed.
  - Valid means: exactly 3 comma-separated fields after trimming whitespace, an integer timestamp (digits only), and non-empty member and event fields.
- `count_by_type` returns `{ event_type => count }`.

---

## Part 2: most engaged members

- `top_members(k)` returns up to `k` member ids by event count, descending; ties by member id ascending.

---

## Part 3: sessions

Events can arrive out of order.

- `sessions(member, gap)` counts sessions: sort the member's timestamps; a new session starts whenever the difference from the previous event is GREATER than `gap`. A member with no events has 0 sessions.

---

## Part 4: busiest window

- `busiest_window(window)` looks at ALL events and returns `[start_ts, count]` for the window `[t, t + window)` holding the most events, where `t` is an event's timestamp. Ties go to the earliest `t`. Returns `nil` if there are no events.

---

## Interviewer notes (read after solving)

- Talk about the bad-input policy: skip and count rejects, don't crash the batch. Ask whether duplicates should be dropped.
- Part 4: a sorted array with two pointers is O(n log n). Mention it before writing a nested loop, or write the nested loop first and say you'd optimize it.
- Ruby tools that shine here: `tally`, `sort_by { |id, n| [-n, id] }`, `each_cons(2)`, `Integer(str, exception: false)`.
