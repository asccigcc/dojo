# Pushes a submission's state to the exercise page over Turbo Streams. While
# it runs only the results panel changes; once finished the parts, solution
# gate and history are refreshed too (a pass may unlock the next part).
class SubmissionBroadcaster
  # @param submission [Submission]
  def initialize(submission)
    @submission = submission
  end

  # @return [void]
  def call
    replace("results", ResultsPanelComponent.new(submission: @submission))
    return unless @submission.finished?

    page = ExercisePage.new(@submission.user, @submission.exercise)
    replace("parts", PartsComponent.new(page:))
    replace("solution_gate", SolutionGateComponent.new(page:))
    replace("history", SubmissionHistoryComponent.new(submissions: page.submissions))
  end

  private

  def replace(target, component)
    Turbo::StreamsChannel.broadcast_replace_to([ @submission.user, @submission.exercise ],
      target:, html: ApplicationController.render(component, layout: false))
  end
end
