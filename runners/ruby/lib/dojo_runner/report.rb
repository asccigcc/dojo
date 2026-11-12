module DojoRunner
  # Turns a sandbox outcome plus the harness verdict into the /run response.
  class Report
    EMPTY_TESTS = { "runs" => 0, "assertions" => 0, "failures" => 0, "errors" => 0, "skips" => 0 }.freeze

    # @param outcome [Sandbox::Outcome]
    # @param verdict [Hash, nil] what the harness wrote, nil if it never finished
    def initialize(outcome, verdict)
      @outcome = outcome
      @verdict = verdict || {}
    end

    # @return [Hash] the JSON-ready response body
    def to_h
      { status:, stdout: @outcome.stdout, stderr: @outcome.stderr, duration_ms: @outcome.duration_ms,
        tests:, failures: @verdict.fetch("failures", []) }
    end

    # @return [String] passed | failed | error | timeout
    def status
      return "timeout" if @outcome.timed_out
      return "error" if @verdict.empty? || @verdict["error"]

      green? ? "passed" : "failed"
    end

    private

    def tests = EMPTY_TESTS.merge(@verdict.fetch("tests", {}))

    def green?
      tests["failures"].zero? && tests["errors"].zero? && tests["runs"] > tests["skips"]
    end
  end
end
