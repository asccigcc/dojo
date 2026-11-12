# Picks the next unseen warm-up so practice rotates across categories
# (Set A, then B, ... then back to A) instead of draining one set first.
class WarmupRotation
  # @param candidates [Array<Exercise>] unseen warm-ups in catalog order
  # @param order [Array<String>] every warm-up category in catalog order
  # @param after [String, nil] category of the most recently practiced warm-up
  def initialize(candidates, order:, after:)
    @candidates = candidates
    @order = order
    @after = after
  end

  # @return [Exercise, nil]
  def next
    rotated_order.each do |category|
      found = @candidates.find { |exercise| exercise.category == category }
      return found if found
    end
    nil
  end

  private

  def rotated_order
    index = @order.index(@after)
    index ? @order.rotate(index + 1) : @order
  end
end
