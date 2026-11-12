# A Today's-practice card linking to one exercise.
class ExerciseCardComponent < ApplicationComponent
  # @param pick [TodaysPractice::Pick, nil]
  # @param kind [String] "warmup" or "problem", for the heading
  def initialize(pick:, kind:)
    @pick = pick
    @kind = kind
  end

  private

  attr_reader :pick, :kind

  def exercise = pick.exercise
end
