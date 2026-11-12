# 08 · Duplicate Patient Records (normalization + grouping)

Health plan files often contain the same person several times. Find and merge the duplicates. Record ids are integers.

---

## Part 1: exact-ish name matches

```ruby
d = Dedup.new
d.add(1, first: "Mary ", last: "O'Neil", dob: "1980-02-01", phone: "(501) 555-0100")
d.add(2, first: "mary",  last: "ONEIL",  dob: "1980-02-01")
d.duplicate_groups  # => [[1, 2]]
```

- Normalize names: lowercase, keep letters only.
- Records match when normalized first + last + dob are equal.
- `duplicate_groups` returns only groups with 2+ records. Ids inside a group are sorted, and groups are sorted by their first id.

---

## Part 2: phone matches, transitively

- Records ALSO match when dob is equal and their phones are equal, comparing the last 10 digits of the phone (ignore phones with fewer than 10 digits, and `nil`).
- Matching is transitive: if 1~2 by name and 2~3 by phone, then `[1, 2, 3]` is one group.

---

## Part 3: golden record

- `golden_record(ids)` returns `{ first:, last:, dob:, phone: }`. For each field, use the most common non-nil, non-empty raw value among those records; ties go to the value from the lowest id.

---

## Part 4: nicknames

Use this map on normalized first names before matching:

```ruby
NICKNAMES = { "bob" => "robert", "rob" => "robert", "bill" => "william",
              "will" => "william", "liz" => "elizabeth", "beth" => "elizabeth" }.freeze
```

---

## Interviewer notes (read after solving)

- Part 2 is union-find, but in an interview a simple "build an adjacency hash keyed by match key, then BFS/DFS" is perfectly fine. Name the tradeoff and pick one.
- Bucketing by match key (`Hash.new { |h, k| h[k] = [] }`) avoids an O(n²) pairwise comparison. Say so.
- Follow-up: false merges are dangerous in healthcare (one person's chart attached to another). Would you auto-merge, or queue for human review?
