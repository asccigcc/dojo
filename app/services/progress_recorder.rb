# Applies one finished submission to the learner's progress: unlocks the next
# part and moves the spaced-repetition schedule.
class ProgressRecorder
  # @param submission [Submission] a finished submission
  # @param now [Time]
  def initialize(submission, now: Time.current)
    @submission = submission
    @exercise = submission.exercise
    @now = now
  end

  # @return [Progress] the saved progress
  def call
    progress.assign_attributes(last_result: @submission.status, last_attempted_at: @now)
    @submission.passed? ? record_pass : reschedule(progress.schedule.after_fail)
    progress.tap(&:save!)
  end

  private

  def progress
    @progress ||= Progress.find_or_initialize_by(user: @submission.user, exercise: @exercise)
  end

  def record_pass
    return keep_going if !@exercise.final_part?(part) && unlock_next_part

    progress.passes_count += 1
    reschedule(progress.schedule.after_pass)
  end

  # Re-runs of an earlier part (or of a finished exercise) never re-lock anything.
  def unlock_next_part
    progress.unlocked_part = [ progress.unlocked_part, part + 1 ].max
  end

  # A mid-problem pass keeps the problem due so it stays on Today until finished.
  def keep_going = progress.next_review_at = @now

  def reschedule(schedule)
    progress.interval_index = schedule.interval_index
    progress.next_review_at = schedule.due_at(@now)
  end

  def part = @submission.part_number
end
