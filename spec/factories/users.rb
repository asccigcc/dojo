FactoryBot.define do
  factory :user do
    sequence(:name) { |n| "learner#{n}" }
  end
end
