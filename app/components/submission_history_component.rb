# The learner's recent runs on this exercise.
class SubmissionHistoryComponent < ApplicationComponent
  # @param submissions [Array<Submission>] newest first, already loaded
  def initialize(submissions:)
    @submissions = submissions
  end

  private

  attr_reader :submissions

  def version = submissions.first&.stream_version || 0
end
