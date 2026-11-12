# One step of a multi-part problem. Part N+1 unlocks after part N passes.
class Part < ApplicationRecord
  belongs_to :exercise

  validates :number, numericality: { greater_than: 0 }, uniqueness: { scope: :exercise_id }
end
