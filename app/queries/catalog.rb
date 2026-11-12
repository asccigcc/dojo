# The full exercise list grouped by kind, then category, with the learner's
# progress attached in a single extra query.
class Catalog
  KIND_ORDER = %w[warmup problem].freeze

  Item = Data.define(:exercise, :progress)
  Section = Data.define(:kind, :groups)

  # @param user [User]
  def initialize(user)
    @user = user
  end

  # @return [Array<Section>] each with groups: { category => [Item] }
  def sections
    by_kind = items.group_by { |item| item.exercise.kind }
    KIND_ORDER.filter_map do |kind|
      Section.new(kind, by_kind[kind].group_by { |item| item.exercise.category }) if by_kind[kind]
    end
  end

  private

  def items
    progress = @user.progresses.index_by(&:exercise_id)
    Exercise.in_catalog_order.map { |exercise| Item.new(exercise, progress[exercise.id]) }
  end
end
