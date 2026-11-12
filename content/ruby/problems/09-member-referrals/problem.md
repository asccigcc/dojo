# 09 · Member Referral Network (sets everywhere)

Enrolled members can refer friends and family who might need cancer support. Track enrollment and referrals. Every part has a "have I seen this before?" question, so this is the place to practice reaching for a `Set`.

---

## Part 1: enrollment

```ruby
r = Referrals.new
r.enroll("ana")     # => true   (newly enrolled)
r.enroll("ana")     # => false  (already enrolled)
r.enrolled?("ana")  # => true
r.count             # => 1
```

---

## Part 2: referrals

- `refer(from, to)` records that `from` referred `to`. It returns:
  - `:unknown_referrer` if `from` is not enrolled,
  - `:already_enrolled` if `to` is already enrolled,
  - `:duplicate` if `from` already referred `to`,
  - `:ok` otherwise.
- Checks happen in that order. Referring someone does NOT enroll them.
- `unique_referrals(from)` returns the distinct people `from` referred, sorted.

---

## Part 3: a member's network

People who were referred can enroll later and refer others.

- `network(member)` returns everyone reachable downstream (the people `member` referred, the people THEY referred, and so on), sorted, NOT including `member`.

---

## Part 4: messy legacy data

A partner's old system is being imported, and its data skips every rule.

- `import(from, to)` records a referral with NO checks (nobody needs to be enrolled, and self-referrals and loops are possible).
- `network` must still finish and must never include the member themselves, even when loops exist.
- `common_referrers(a, b)` returns everyone who referred BOTH `a` and `b`, sorted.

---

## Interviewer notes (read after solving)

- Part 1: `Set#add?` answers "was it new?" and adds in one step.
- Part 2: a hash of sets (`from => Set of to`) makes `:duplicate` a one-line `add?` check.
- Part 3: breadth-first search (a queue) or depth-first (a stack), with a `visited` Set. Say: "the visited set guarantees each person is processed once, so this is O(people + referrals)."
- Part 4: if your Part 3 already used a visited set, loops cost nothing. That's the payoff for writing it carefully in Part 3. Watch out: `Hash.new { ... }` with a default block CREATES keys when you read them; use `fetch(key, Set.new)` for reads.
