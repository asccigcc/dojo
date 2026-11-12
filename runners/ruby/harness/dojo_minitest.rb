# Loaded with `ruby -r dojo_minitest` before the exercise's test file. It adds
# a reporter that writes the run's verdict as JSON, so the runner never has
# to scrape minitest's human-readable output.
require "json"
require "minitest"

module DojoMinitest
  RESULT_PATH = ENV.delete("DOJO_RESULT_PATH").freeze
  MESSAGE_LIMIT = 2_000

  # Collects results and writes the summary JSON at the end of the run.
  class JsonReporter < Minitest::AbstractReporter
    def initialize
      super
      @results = []
    end

    def record(result) = @results << result

    def passed? = true

    def report
      File.write(RESULT_PATH, JSON.generate(tests: counts, failures: failures))
    end

    private

    def counts
      { runs: @results.size, assertions: @results.sum(&:assertions),
        failures: @results.count { |r| r.failure && !r.skipped? && !r.error? },
        errors: @results.count(&:error?), skips: @results.count(&:skipped?) }
    end

    def failures
      @results.reject { |r| r.passed? || r.skipped? }.map { |r| failure_entry(r) }
    end

    def failure_entry(result)
      { name: result.name, kind: result.error? ? "error" : "failure",
        message: result.failure.message.to_s[0, MESSAGE_LIMIT], location: result.failure.location }
    end
  end
end

module Minitest
  def self.plugin_dojo_json_init(_options)
    reporter << DojoMinitest::JsonReporter.new
  end
end

Minitest.extensions << "dojo_json"
