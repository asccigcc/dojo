# The "what does Run check" label next to the Run button. Broadcast with the
# parts, so it stays right when a pass unlocks the next part.
class RunScopeComponent < ApplicationComponent
  # @param page [ExercisePage]
  def initialize(page:)
    @page = page
  end

  def call
    tag.span(label, id: "run_scope", class: "text-xs text-slate-500", data: { stream_version: version })
  end

  private

  def label
    @page.exercise.problem? ? t(".runs_part", number: @page.current_part) : t(".runs_warmup")
  end

  def version = @page.latest_submission&.stream_version || 0
end
