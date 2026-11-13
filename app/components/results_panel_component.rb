# The live results panel. Replaced over Turbo Streams as a run progresses.
class ResultsPanelComponent < ApplicationComponent
  # @param submission [Submission, nil] nil before the first run
  def initialize(submission:)
    @submission = submission
  end

  private

  attr_reader :submission

  def in_flight? = submission && !submission.finished?

  def counts
    t(".counts", runs: submission.runs, assertions: submission.assertions,
      failures: submission.failures_count, errors: submission.errors_count, skips: submission.skips)
  end

  def failures = Array(submission&.failure_details)

  def invalid? = submission && !submission.persisted?

  def version = submission&.persisted? ? submission.stream_version : 0
end
