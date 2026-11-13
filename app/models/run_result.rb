# Value object for one runner verdict, whatever the language.
class RunResult
  # Above the runner's 64 KB-per-stream cap so its truncation marker survives.
  OUTPUT_LIMIT = 160.kilobytes
  COUNT_KEYS = { runs: "runs", assertions: "assertions", failures_count: "failures",
                 errors_count: "errors", skips: "skips" }.freeze

  attr_reader :status, :stdout, :stderr, :duration_ms, :tests, :failures

  # @param body [Hash] decoded JSON from POST /run
  # @return [RunResult]
  def self.from_response(body)
    status = Submission.statuses.key?(body["status"]) ? body["status"] : "error"
    new(status:, stdout: body["stdout"].to_s, stderr: body["stderr"].to_s, duration_ms: body["duration_ms"],
      tests: body["tests"] || {}, failures: Array(body["failures"]))
  end

  # @param message [String] why the runner could not be reached
  # @return [RunResult] an error result that must not count against progress
  def self.unavailable(message) = new(status: "error", stderr: message, unavailable: true)

  def initialize(status:, stdout: "", stderr: "", duration_ms: nil, tests: {}, failures: [], unavailable: false)
    @status, @stdout, @stderr, @duration_ms = status, stdout, stderr, duration_ms
    @tests, @failures, @unavailable = tests, failures, unavailable
  end

  # @return [Boolean]
  def passed? = status == "passed"

  # @return [Boolean] true when the runner itself failed, not the learner's code
  def unavailable? = @unavailable

  # @return [Hash] attributes for Submission#update!
  def submission_attributes
    counts = COUNT_KEYS.transform_values { |key| tests.fetch(key, 0).to_i }
    { status:, output:, failure_details: failures, duration_ms: }.merge(counts)
  end

  private

  def output = [ stdout, stderr ].compact_blank.join("\n").first(OUTPUT_LIMIT)
end
