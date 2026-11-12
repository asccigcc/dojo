FactoryBot.define do
  factory :part do
    exercise factory: %i[exercise problem]
    sequence(:number) { |n| n + 10 }
    description_md { "Do the thing." }
  end
end
