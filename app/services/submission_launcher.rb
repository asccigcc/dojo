# Creates a pending submission for the learner's current part and queues it.
class SubmissionLauncher
  # @param user [User]
  # @param exercise [Exercise]
  # @param code [String]
  def initialize(user, exercise, code)
    @user = user
    @exercise = exercise
    @code = code.to_s
  end

  # @return [Submission] persisted and queued, or unsaved with errors
  def call
    submission = @user.submissions.create(exercise: @exercise, code: @code, part_number: current_part)
    RunSubmissionJob.perform_later(submission) if submission.persisted?
    submission
  end

  private

  # The server, not the form, decides which part runs, so parts cannot be skipped.
  def current_part
    unlocked = @user.progresses.find_by(exercise: @exercise)&.unlocked_part || 1
    [ unlocked, @exercise.parts_count ].min
  end
end
