# Runs a learner's submission in the language runner, off the request thread.
class RunSubmissionJob < ApplicationJob
  queue_as :default
  discard_on ActiveJob::DeserializationError

  # @param submission [Submission]
  # @return [void]
  def perform(submission)
    SubmissionRun.new(submission).call
  end
end
