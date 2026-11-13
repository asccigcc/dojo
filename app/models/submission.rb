# One press of Run: the code, which part it targeted, and the runner's verdict.
class Submission < ApplicationRecord
  MAX_CODE_LENGTH = 100_000

  enum :status, %w[pending running passed failed error timeout].index_by(&:itself),
    default: :pending, validate: true

  belongs_to :user
  belongs_to :exercise

  validates :code, length: { maximum: MAX_CODE_LENGTH }
  validates :part_number, numericality: { greater_than: 0 }

  scope :recent_first, -> { order(created_at: :desc, id: :desc) }

  # @return [Boolean] true once the runner has produced a verdict
  def finished? = !(pending? || running?)

  # Monotonic version for live page fragments: newer submissions outrank
  # older ones, and within one submission pending < running < finished. The
  # browser drops Turbo Stream replacements older than what it shows, because
  # Action Cable may deliver broadcasts (and the HTTP response) out of order.
  #
  # @return [Integer]
  def stream_version
    rank = finished? ? 2 : (running? ? 1 : 0)
    (id * 10) + rank
  end

  # Stores a runner verdict on this submission.
  #
  # @param result [RunResult]
  # @return [true]
  def record!(result)
    update!(result.submission_attributes)
  end
end
