module DojoRunner
  # Spawns one command in its own process group under rlimits, enforces a
  # hard wall-clock timeout by SIGKILLing the whole group, and captures
  # bounded stdout/stderr.
  class Sandbox
    OUTPUT_LIMIT = 64 * 1024
    BASE_PATH = "/usr/local/bin:/usr/bin:/bin".freeze

    Outcome = Data.define(:exit_status, :timed_out, :stdout, :stderr, :duration_ms)

    # @param limits [Limits]
    # @param output_limit [Integer] bytes kept per stream
    def initialize(limits: Limits.new, output_limit: OUTPUT_LIMIT)
      @limits = limits
      @output_limit = output_limit
    end

    # @param command [Array<String>] argv
    # @param dir [String] working directory
    # @param env [Hash{String=>String}] the child's entire environment
    # @param timeout_s [Integer]
    # @return [Outcome]
    def run(command, dir:, env:, timeout_s:)
      started = clock
      out, err = IO.pipe, IO.pipe
      pid = spawn(command, dir, env, timeout_s, out.last, err.last)
      finish(pid, timeout_s, [ reader(*out), reader(*err) ], started)
    end

    private

    def spawn(command, dir, env, timeout_s, out, err)
      Process.spawn(env, *command, chdir: dir, pgroup: true, unsetenv_others: true,
        in: File::NULL, out:, err:, close_others: true, **@limits.spawn_options(timeout_s))
    end

    def reader(read, write)
      write.close
      BoundedReader.new(read, @output_limit).start
    end

    def finish(pid, timeout_s, readers, started)
      status, timed_out = wait_for(pid, timeout_s)
      kill_group(pid)
      Outcome.new(exit_status: status&.exitstatus, timed_out:, stdout: readers[0].value,
        stderr: readers[1].value, duration_ms: ((clock - started) * 1000).round)
    end

    def wait_for(pid, timeout_s)
      waiter = Process.detach(pid)
      return [ waiter.value, false ] if waiter.join(timeout_s)

      kill_group(pid)
      [ waiter.value, true ]
    end

    # Also reaps anything the program forked into its group.
    def kill_group(pid)
      Process.kill(:KILL, -pid)
    rescue Errno::ESRCH, Errno::EPERM
      nil
    end

    def clock = Process.clock_gettime(Process::CLOCK_MONOTONIC)
  end
end
