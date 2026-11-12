FactoryBot.define do
  factory :exercise do
    sequence(:slug) { |n| "warmup-x#{n}" }
    sequence(:position) { |n| n }
    kind { "warmup" }
    language { "ruby" }
    category { "hashes" }
    title { "Count words" }
    description_md { "Count each word in `WORDS`." }
    prelude_code { "WORDS = %w[a b a].freeze" }
    solution_code { "WORDS.tally" }
    expected_code { '{ "a" => 2, "b" => 1 }' }

    trait :problem do
      sequence(:slug) { |n| "problem-#{n}" }
      kind { "problem" }
      category { "intervals" }
      title { "Counter" }
      parts_count { 2 }
      prelude_code { "require \"minitest/autorun\"" }
      starter_code { "class Counter\nend\n" }
      test_code { "require_relative \"test_helper\"\n" }
      solution_code { "class Counter\nend\n" }
      expected_code { nil }
      code_path { "work/counter.rb" }
      test_path { "tests/counter_test.rb" }
      notes_md { "Ask about edge cases." }

      after(:create) do |exercise|
        (1..exercise.parts_count).each do |number|
          exercise.parts.create!(number:, description_md: "Part #{number} text")
        end
      end
    end
  end
end
