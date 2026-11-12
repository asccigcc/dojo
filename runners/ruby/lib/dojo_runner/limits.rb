module DojoRunner
  # rlimit options for Process.spawn. Memory and process-count caps are only
  # applied on Linux: macOS counts every process of the user against
  # RLIMIT_NPROC and handles RLIMIT_AS poorly, so the dev-only local runner
  # skips them (it is loudly labeled NOT SANDBOXED anyway).
  class Limits
    MB = 1024 * 1024

    # @param linux [Boolean] whether the host kernel is Linux
    def initialize(linux: RUBY_PLATFORM.include?("linux"))
      @linux = linux
    end

    # @param timeout_s [Integer] the wall-clock budget; CPU gets one extra second
    # @return [Hash] options for Process.spawn
    def spawn_options(timeout_s)
      base = { rlimit_cpu: timeout_s + 1, rlimit_fsize: MB, rlimit_nofile: 256, rlimit_core: 0 }
      @linux ? base.merge(linux_only) : base
    end

    private

    def linux_only
      { rlimit_as: env_int("DOJO_MAX_MEMORY_MB", 768) * MB, rlimit_nproc: env_int("DOJO_MAX_PROCS", 64) }
    end

    def env_int(name, default) = Integer(ENV.fetch(name, default))
  end
end
