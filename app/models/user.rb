# The single learner using this Dojo. Identified by name only: there are no
# passwords because the app runs on 127.0.0.1 for one person.
class User < ApplicationRecord
  NAME_FORMAT = /\A[\p{L}\p{N} ._-]+\z/

  has_many :submissions, dependent: :destroy
  has_many :progresses, dependent: :destroy

  normalizes :name, with: ->(name) { name.to_s.squish }

  validates :name, presence: true, length: { maximum: 40 },
    format: { with: NAME_FORMAT, allow_blank: true },
    uniqueness: { case_sensitive: false }

  # Finds the user by name (case-insensitively) or creates one.
  #
  # @param name [String] the username typed on the sign-in form
  # @return [User] persisted on success; unsaved with errors when invalid
  def self.sign_in(name)
    normalized = normalize_value_for(:name, name)
    where("lower(name) = ?", normalized.downcase).first || create(name: normalized)
  end
end
