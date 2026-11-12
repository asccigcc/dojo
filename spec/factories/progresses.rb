FactoryBot.define do
  factory :progress do
    user
    exercise
    unlocked_part { 1 }
  end
end
