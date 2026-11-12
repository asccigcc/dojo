# 02 · Member Attribute Store with Transactions (classic)

An in-memory key-value store for member attributes (e.g. `"m1:risk" => "high"`). This is the most commonly reported problem of this interview style, so it's worth knowing cold.

---

## Part 1: basic operations

```ruby
store = Store.new
store.set("m1:risk", "high")
store.get("m1:risk")     # => "high"
store.get("missing")     # => nil
store.delete("m1:risk")  # => true  (false if the key did not exist)
```

---

## Part 2: count by value

- `count(value)` returns how many keys currently hold `value`.
- The interviewer will ask: can you make `count` O(1)? (Hint: maintain a second hash.)

---

## Part 3: nested transactions

- `begin_tx` opens a transaction. Transactions can nest.
- `rollback` undoes every change since the most recent `begin_tx` and closes it. Returns `false` if no transaction is open.
- `commit` makes ALL open transactions permanent and closes them. Returns `false` if none are open.
- `get` and `count` always reflect the current (uncommitted) state.

```ruby
store.set("a", 10)
store.begin_tx
store.set("a", 20)
store.begin_tx
store.delete("a")
store.rollback   # a == 20
store.rollback   # a == 10
```

---

## Part 4: prefix scan

- `keys_with_prefix(prefix)` returns matching keys, sorted ascending. It must respect the current transaction state.

---

## Interviewer notes (read after solving)

- Two classic designs for Part 3: (a) a stack of full snapshots (simple, O(n) per `begin_tx`), or (b) a stack of undo logs storing each key's previous value (O(changes)). Saying out loud why you choose one is exactly what they want to hear.
- Watch for: undoing a `delete`, setting the same key twice in one transaction (only the first previous value matters), and keeping `count` correct during a rollback.
