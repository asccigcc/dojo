# A practice item: a one-shot warm-up rep or a multi-part problem. Content is
# imported from versioned files under content/ (see Content::Importer).
class Exercise < ApplicationRecord
  SLUG_FORMAT = /\A[a-z0-9][a-z0-9-]*\z/

  enum :kind, { warmup: "warmup", problem: "problem" }, validate: true

  has_many :parts, -> { order(:number) }, dependent: :delete_all, inverse_of: :exercise
  has_many :submissions, dependent: :delete_all
  has_many :progresses, dependent: :delete_all

  validates :slug, presence: true, uniqueness: true, format: { with: SLUG_FORMAT }
  validates :title, :category, :language, :position, presence: true
  validates :parts_count, numericality: { greater_than: 0 }

  scope :in_catalog_order, -> { order(:position) }

  # @return [String] the slug, so routes read /exercises/warmup-a01
  def to_param = slug

  # @param number [Integer] a part number
  # @return [Boolean] whether passing this part completes the exercise
  def final_part?(number) = number >= parts_count
end
