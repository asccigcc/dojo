# 01 · Medication Refill Tracker (warm-up)

Track prescriptions and refills for a care team. Days are plain integers that stand in for calendar dates (day 0 = start, day 5 = five days later).

Two different numbers matter:
- `days_supply` is how long ONE fill lasts (a 30-day bottle). It never changes.
- `day` in `fill(id, day)` is WHEN the patient picked it up (like a date).

Example: a 30-day prescription filled on day 5 runs out on day 35.

---

## Part 1: prescriptions and fills

```ruby
tracker = RefillTracker.new
tracker.add_prescription("rx1", "pat_a", "metformin", 30, 3)  # id, patient, drug, days_supply, fills allowed
tracker.fill("rx1", 0)    # => :ok
tracker.remaining("rx1")  # => 2
```

- `fill(id, day)` returns `:ok` and uses one fill, or `:no_refills` when none remain.
- `remaining(id)` returns the fills left.

---

## Part 2: when is the next fill due?

- `next_due(id)` returns `last_fill_day + days_supply`, or `nil` if it has never been filled.

---

## Part 3: overdue list

- `overdue(today)` returns prescription ids whose `next_due` is before `today` and that still have fills left.
- Never-filled prescriptions are not overdue.
- Order: most overdue first (earliest due day); ties by id ascending.

---

## Part 4: early-refill rule and patient summary

Insurers reject refills that come too early.

- A fill is `:too_early` if `day < last_fill + ceil(days_supply * 0.75)`. A rejected fill does not use a refill.
- `patient_summary(patient)` returns `{ drug => remaining }` for that patient's prescriptions.

---

## Interviewer notes (read after solving)

- Good clarifying questions: Does the first fill count against the allowance? Can a prescription id be re-added? What should happen for unknown ids?
- Follow-ups: Complexity of `overdue` (O(n log n)). How would you make it fast with 10M prescriptions? (Index by due day, or a sorted structure.)
