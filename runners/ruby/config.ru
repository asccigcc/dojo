require "rack"
require_relative "lib/dojo_runner"

unless DojoRunner.sandboxed?
  warn <<~BANNER
    #{'!' * 72}
    !! DOJO RUBY RUNNER: NOT SANDBOXED (dev only)
    !! Code runs as YOUR user on THIS machine with only rlimits and a
    !! timeout. No read-only filesystem, no network isolation. Use
    !! `docker compose up` for the hardened runner.
    #{'!' * 72}
  BANNER
end

run DojoRunner::App.new
