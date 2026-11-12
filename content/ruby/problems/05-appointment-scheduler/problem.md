# 05 · Provider Appointment Scheduler (overlaps + search)

Book telehealth appointments with providers. Times are integer minutes; an appointment covers the half-open range `[start, start + duration)`, so a 9:00–9:30 slot and a 9:30–10:00 slot do NOT overlap.

---

## Part 1: book and cancel

```ruby
s = Scheduler.new
s.book("dr_lee", 540, 30)  # => "A1"   (ids are "A1", "A2", ... across all providers)
s.book("dr_lee", 555, 30)  # => nil    (overlaps A1; a failed booking uses no id)
s.book("dr_lee", 570, 30)  # => "A2"
s.cancel("A1")             # => true   (false if unknown or already cancelled)
```

---

## Part 2: a provider's day

- `schedule(provider)` returns `[[start, end], ...]` sorted by start (end = start + duration).

---

## Part 3: next available slot

- `next_available(provider, after, duration, day_end)` returns the earliest start `>= after` where the appointment fits without overlap and ends at or before `day_end`. Returns `nil` if there's no room.

---

## Part 4: book with any provider

- `book_any(providers, start, duration)` books the free provider with the FEWEST appointments; ties go to the order in the list. Returns `[provider, id]` or `nil`.

---

## Interviewer notes (read after solving)

- Say "half-open intervals" out loud: overlap is `a_start < b_end && b_start < a_end`.
- `next_available`: the candidate starts are `after` plus every appointment end time. Checking only those is enough, and it's a nice insight to explain.
- Follow-up: time zones, provider working hours, buffer time between visits, and double booking under concurrency (a DB exclusion constraint on a `tsrange`).
