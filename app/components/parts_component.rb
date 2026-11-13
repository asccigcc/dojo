# The unlocked parts of a problem (all of them for a warm-up's single prompt).
class PartsComponent < ApplicationComponent
  # @param page [ExercisePage]
  def initialize(page:)
    @page = page
  end

  private

  attr_reader :page

  def version = page.latest_submission&.stream_version || 0

  def current?(part) = part.number == page.current_part

  def all_done? = page.completed? && page.locked_parts_count.zero?
end
