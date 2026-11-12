FactoryBot.define do
  factory :submission do
    user
    exercise
    part_number { 1 }
    code { "WORDS.tally" }
    status { "pending" }
  end
end
