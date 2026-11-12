# The reveal button for the reference solution and notes. Disabled until the
# learner has submitted at least once (the server enforces the same rule).
class SolutionGateComponent < ApplicationComponent
  # @param page [ExercisePage]
  def initialize(page:)
    @page = page
  end

  private

  attr_reader :page
end
