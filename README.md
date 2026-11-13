# Dojo

A personal coding dojo: a tiny HackerRank/LeetCode for one person, run locally
with Docker. Each day it serves **one warm-up rep and one multi-part problem**,
checks your code in a sandboxed runner container, and brings items back on a
spaced-repetition schedule (1, 3, 7, 14, 30 days).

- Rails 8.1, Ruby 3.4.7, SQLite (app data, Solid Queue jobs, Solid Cable broadcasts)
- Hotwire (Turbo + Stimulus), Vite Ruby, Tailwind v4, CodeMirror 6, ViewComponent
- A separate, hardened **runner container per language** (Ruby today) behind one HTTP API

## Start it

```sh
docker compose up --build
```

Then open <http://127.0.0.1:3000>, type a username (no password), and start
on **Today's practice**. On every boot the web container runs `db:prepare` and
`dojo:import`, so content is always loaded. Data lives in the `dojo_storage`
volume. `docker compose down -v` wipes it.

### Local development (no Docker)

```sh
bundle install && npm install
bin/rails db:prepare dojo:import
bin/dev            # Vite + Rails (Solid Queue in Puma) + Ruby runner on :9292
```

`bin/dev` starts the runner in **NOT SANDBOXED dev mode**: your code runs as
your own user with only rlimits and a timeout. There is no read-only
filesystem and no network isolation. It prints a warning to say so.

### Tests and lint

```sh
bundle exec rspec        # app, runner library, and every reference answer vs its own check
bin/rubocop
ruby script/smoke_test.rb http://127.0.0.1:3000   # end-to-end against a running app, incl. hostile snippets
```

## How practice works

- **Warm-ups** (70 reps, Sets A to G): your code runs after the shared data
  (`content/ruby/warmups/data.rb`). The **value of your last expression** is
  the answer, compared with `==` to the expected value. Reps with several
  results say which array shape to return. For reps that expect an
  exception, return its class (`(expr rescue $!.class)`).
- **Problems** (9, four parts each): you see one part at a time. Run checks
  parts 1..N with the problem's minitest file (`PART=N`). Part N+1 unlocks
  when part N passes.
- **Solution and interviewer notes** stay locked until you have submitted at
  least once (enforced server-side too).
- **Review ladder:** a full pass (all parts, for problems) moves an item up one
  rung: 1, 3, 7, 14, 30 days. A fail sends it back to the start (due tomorrow).
  Today picks, per kind: what you started today and have not passed, then the
  most overdue review, then the next unseen item. Unseen warm-ups rotate
  across sets.

## Adding exercises

Content is versioned under `content/<language>/` and loaded by
`bin/rails dojo:import`. The import is an idempotent upsert by slug, and it
also runs from `db:seed` and on every container boot. It never deletes
exercises, because that would delete your history.

**A warm-up rep:** `content/ruby/warmups/<set>-<category>/<rep>.yml`

```yaml
slug: warmup-a11            # unique, URL-safe
rep: A11
set: A
category: hashes            # new categories need a label under `categories:` in config/locales/en.yml
position: 11                # catalog order
title: "A11 · Invert a hash"
prompt: "Invert `{ a: 1, b: 2 }`."
returns: "Return the inverted hash."   # optional: exact shape to return
setup: "h = { a: 1, b: 2 }"            # optional: extra prelude after data.rb
note: "Optional explanation, shown with the solution."
expected: "{ 1 => :a, 2 => :b }"       # a Ruby expression
answer: "{ a: 1, b: 2 }.invert"        # reference answer
```

**A problem:** `content/ruby/problems/NN-slug/`

| File | Purpose |
|---|---|
| `meta.yml` | `slug`, `title`, `category`, `position`, `code_path` (e.g. `work/10_foo.rb`), `test_path` (e.g. `tests/10_foo_test.rb`) |
| `problem.md` | `# Title`, intro, `## Part 1 ...` to `## Part N ...`, then `## Interviewer notes ...` |
| `test.rb` | minitest. Starts with `require_relative "test_helper"` and `load_target "10_foo"`, and later-part tests call `part n` |
| `solution.rb` | reference solution (must pass every part) |
| `starter.rb` | what the editor starts with |

`spec/content/reference_solutions_spec.rb` runs every reference answer and
solution through the real runner harness. It also checks that every starter
loads and fails part 1. Run `bundle exec rspec spec/content` after adding content.

## Adding a language runner

The web app never runs learner code. It posts to the runner at
`RUNNER_<LANGUAGE>_URL` (see `config/runners.yml`), and every runner speaks the same API:

```
POST /run   {"mode": "minitest"|"expression", "files": {"path.rb": "..."}, "entry": "tests/x_test.rb",
             "env": {"PART": "2"}, "timeout_s": 5}
200         {"status": "passed"|"failed"|"error"|"timeout", "stdout", "stderr", "duration_ms",
             "tests": {"runs", "assertions", "failures", "errors", "skips"}, "failures": [{"name", "message"}]}
GET /health {"status": "ok", "language": "ruby", "sandboxed": true}
```

To add Python:

1. Create `runners/python/` with a server for that API (for example pytest
   with a JSON report for test mode, and an evaluation of the last expression
   for `expression` mode). Reuse the process model in
   `runners/ruby/lib/dojo_runner/sandbox.rb`.
2. Add a `runner-python` service to `compose.yaml` by copying `runner-ruby`'s
   hardening block, and set `RUNNER_PYTHON_URL` on `web`.
3. Add `python:` to `config/runners.yml`.
4. If the file layout differs, add `Checks` payload builders, then add content
   under `content/python/` with `language: python`.

## Security model, and its limits

Learner code runs only in `runner-ruby`, never in the Rails process. Each run:

- gets a fresh temp dir on a size-capped tmpfs, deleted afterwards;
- is spawned in its own **process group** with a scrubbed environment (only
  `PART`, `PATH`, `HOME`, `TMPDIR`, `LANG`, and the result path);
- has rlimits: CPU seconds, file size (1 MB), open files, no core dumps, and
  on Linux also address space (`DOJO_MAX_MEMORY_MB`) and process count (`DOJO_MAX_PROCS`);
- is **SIGKILLed as a whole group** at the wall-clock timeout (default 5 s,
  max 10 s), which gives `status: "timeout"`;
- has stdout and stderr capped at 64 KB each, with a truncation marker.

The container adds:

- a non-root user (uid 10001);
- a `read_only: true` root FS with a noexec tmpfs at `/tmp`;
- `cap_drop: [ALL]` and `no-new-privileges`;
- `mem_limit` 512m, `cpus: 1`, and `pids_limit: 128`;
- `init: true`, which reaps orphaned processes;
- no published ports, and an `internal: true` network shared only with `web`,
  so it has no internet access.

**Limits, read these:**

- This is container isolation, not a VM: it shares the kernel of Docker's
  Linux VM. That is fine for your own practice code. Do not use it to host
  strangers' code.
- All runs share one container and one uid. A program can signal other
  in-flight runs. It can also escape its process group with `setsid` and
  outlive the timeout, bounded by the CPU rlimit, `pids_limit`, and the memory
  cap. It can even forge its own verdict by writing the result file, but that
  only cheats yourself.
- `RLIMIT_NPROC` counts every process of the runner uid, including Puma's
  threads, so a fork bomb in one run can briefly make a concurrent run fail.
- `bin/dev` (dev mode) has **none** of the container protections.
- There are no passwords, by design. Anyone who can reach 127.0.0.1:3000 can
  sign in under any name. The port is bound to localhost only.

## Layout

```
app/
  controllers/   sessions, home (Today), exercises, submissions, solutions
  services/      SubmissionLauncher, SubmissionRun, ProgressRecorder, SubmissionBroadcaster,
                 RunnerClient, Checks::{Warmup,Problem}, Content::{Importer,...}, MarkdownRenderer
  queries/       TodaysPractice, WarmupRotation, Catalog
  facades/       ExercisePage
  components/    ResultsPanel, Parts, SolutionGate, SubmissionHistory, ExerciseCard, StatusBadge
  frontend/      Vite entrypoint, Tailwind, Stimulus (editor_controller.js mounts CodeMirror)
content/ruby/    versioned exercises (converted from the practice kit)
runners/ruby/    the sandboxed runner (Rack + Puma, no Rails)
spec/            RSpec, including spec/runner_ruby and spec/content
```
