# 04 · Care Team Task Assignment (round-robin + queues)

Thyme Care's 600+ person care team works out of an internal platform (Thyme Box). Build the piece that assigns incoming member tasks to nurses. This one is deliberately ambiguous, so ask questions before coding.

---

## Part 1: round-robin

```ruby
a = Assigner.new
a.add_nurse("ana"); a.add_nurse("ben"); a.add_nurse("cy")
a.assign("t1")  # => "ana"
a.assign("t2")  # => "ben"
a.assign("t3")  # => "cy"
a.assign("t4")  # => "ana"
a.tasks_for("ana")  # => ["t1", "t4"]  (open tasks, in assignment order)
```

---

## Part 2: capacity and a waiting queue

- `add_nurse(name, capacity: n)` limits open tasks (default: unlimited).
- `assign` skips full nurses but keeps the rotation going. If everyone is full, the task goes to a waiting queue and `assign` returns `nil`.
- `waiting` returns the queued task ids.
- `complete(task_id)` closes the task (returns `true`, or `false` if unknown), then assigns waiting tasks in FIFO order while anyone has room, using the normal rotation.

---

## Part 3: going off shift

- `off_shift(name)` removes the nurse from the rotation. Their open tasks are reassigned one by one, in their original order, through the normal rotation (or to the waiting queue).
- The rotation continues from where it would have been without that nurse.

---

## Part 4: urgent tasks

- `assign(task_id, priority: :urgent)` (default `:routine`).
- Urgent tasks wait ahead of all routine tasks in the queue; FIFO within the same priority.

---

## Interviewer notes (read after solving)

- Ask: "After a nurse goes off shift, who gets the next task?" and "Does completing a task change whose turn it is?" Agree on an answer, write it as a comment, and move on.
- Keep one source of truth for each task's owner (a `task => nurse` hash) plus a per-nurse ordered list. Duplicated state drifts.
- Follow-up: how would you make this survive a restart, or run on two app servers at once? (Persist to Postgres; use row locks or `SELECT ... FOR UPDATE SKIP LOCKED`.)
