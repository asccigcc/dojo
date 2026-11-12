# 03 · Insurance Coverage Windows (intervals)

Members have insurance coverage periods. Days are integers and ranges are inclusive (`[1, 10]` covers days 1 through 10). This connects to your eligibility work, so mention that while you solve it.

---

## Part 1: add and check

```ruby
book = CoverageBook.new
book.add("m1", 1, 10)
book.covered?("m1", 5)   # => true
book.covered?("m1", 11)  # => false
book.covered?("m2", 5)   # => false
```

---

## Part 2: merged periods

- `periods(member)` returns sorted, merged `[start, end]` pairs.
- Merge both overlapping AND adjacent periods: `[1,10]` + `[11,20]` → `[1,20]`.

---

## Part 3: gaps

- `gaps(member, from, to)` returns the uncovered `[start, end]` sub-ranges inside `[from, to]`, sorted.

```ruby
# coverage [5,10], [20,25]
book.gaps("m1", 1, 30)  # => [[1,4], [11,19], [26,30]]
```

---

## Part 4: primary payer

`add` now accepts `payer:` and `priority:` keywords (defaults `"UNKNOWN"` and `99`). A lower priority number means primary.

- `primary_payer(member, day)` returns the payer with the lowest priority covering that day, or `nil`.
- Ties go to the period that was added first.
- `covered?`, `periods`, and `gaps` ignore payers (all coverage counts).

---

## Interviewer notes (read after solving)

- Sort-then-sweep merge is O(n log n). Explain the adjacent-merge choice: coverage on day 10 and day 11 means no gap.
- Edge cases: an empty member, a range fully covered (`[]`), periods that extend past `from`/`to`, and periods added out of order.
