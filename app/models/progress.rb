# A user's standing on one exercise: which part is unlocked and when it is due
# for spaced review.
class Progress < ApplicationRecord
  belongs_to :user
  belongs_to :exercise

  validates :exercise_id, uniqueness: { scope: :user_id }

  scope :due, ->(now) { where(next_review_at: ..now) }

  # @param now [Time]
  # @return [Boolean] whether the exercise is waiting for review
  def due?(now = Time.current) = next_review_at.present? && next_review_at <= now

  # @return [ReviewSchedule] the current rung on the review ladder
  def schedule = ReviewSchedule.new(interval_index)
end
