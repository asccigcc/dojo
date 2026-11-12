# Everything the exercise page shows for one learner, loaded up front so the
# components it feeds never query the database.
class ExercisePage
  HISTORY_LIMIT = 10

  attr_reader :exercise, :progress

  # @param user [User]
  # @param exercise [Exercise]
  def initialize(user, exercise)
    @user = user
    @exercise = exercise
    @progress = Progress.find_or_initialize_by(user:, exercise:)
  end

  # @return [Integer] the part a Run checks (cumulatively, parts 1..n)
  def current_part = [ progress.unlocked_part, exercise.parts_count ].min

  # @return [Array<Part>] only the unlocked parts
  def visible_parts = exercise.parts.select { |part| part.number <= current_part }

  # @return [Integer] parts still hidden
  def locked_parts_count = exercise.problem? ? exercise.parts_count - current_part : 0

  # @return [Array<Submission>] newest first
  def submissions
    @submissions ||= @user.submissions.where(exercise:).recent_first.limit(HISTORY_LIMIT).to_a
  end

  # @return [String] the last submission's code, or the starter
  def editor_code = submissions.first&.code.presence || exercise.starter_code

  # @return [Submission, nil]
  def latest_submission = submissions.first

  # The study rule: no peeking at the solution before a real attempt.
  #
  # @return [Boolean]
  def solution_unlocked? = submissions.any?

  # @return [Boolean] whether every part has been passed at least once
  def completed? = progress.passes_count.positive?
end
