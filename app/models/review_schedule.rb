# Value object for the spaced-repetition ladder. A rung is an index into
# LADDER_DAYS; nil means "not on the ladder yet" (never passed, or just failed),
# which still schedules the next review one day out.
class ReviewSchedule
  LADDER_DAYS = [ 1, 3, 7, 14, 30 ].freeze

  attr_reader :interval_index

  # @param interval_index [Integer, nil] current rung, nil when off the ladder
  def initialize(interval_index)
    @interval_index = interval_index
  end

  # @return [ReviewSchedule] one rung up, capped at the top of the ladder
  def after_pass
    self.class.new(interval_index.nil? ? 0 : [ interval_index + 1, LADDER_DAYS.size - 1 ].min)
  end

  # @return [ReviewSchedule] back to the start of the ladder
  def after_fail = self.class.new(nil)

  # @return [Integer] days until the next review
  def days = LADDER_DAYS.fetch(interval_index || 0)

  # @param from [Time]
  # @return [Time] when the next review falls due
  def due_at(from) = from + days.days
end
