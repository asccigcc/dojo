# 06 · Patient Balance Ledger (your home turf)

Track what patients owe. Amounts are integer cents; days are integers. This mirrors your patient-responsibility billing and dunning work, so narrate the real-world rules you know.

---

## Part 1: charges and balance

```ruby
l = Ledger.new
l.charge("pat_a", "clm1", 5000, 1)   # patient, claim_id, amount, day
l.charge("pat_a", "clm2", 2000, 10)
l.balance("pat_a")  # => 7000
l.balance("nobody") # => 0
```

---

## Part 2: payments, oldest first

- `pay(patient, amount, day)` pays off open charges oldest-day first (ties: the earlier-added charge).
- Any overpayment becomes a credit: the balance goes negative, and the credit is used up automatically by future charges.
- `open_charges(patient)` returns `[[claim_id, remaining], ...]` for charges with a remaining amount above 0, oldest first.

---

## Part 3: adjustments (write-offs)

- `adjust(claim_id, amount)` reduces that claim's remaining amount, never below 0. It returns the amount actually applied (0 for an unknown claim).

---

## Part 4: aging buckets

- `aging(patient, today)` returns the remaining amounts grouped by age (`today - charge_day`):
  `{ "0-30" => , "31-60" => , "61-90" => , "90+" => }`. All four keys are always present.

---

## Interviewer notes (read after solving)

- Integer cents, never floats. Say it before they ask.
- Mention real-world parallels briefly (do not lecture): idempotent payments, and Stripe/Candid calls you can't roll back. That shows judgment without derailing the exercise.
- Follow-up: how would you audit this? (Append-only entries and a derived balance, not a mutable number.)
