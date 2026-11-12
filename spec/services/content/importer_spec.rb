require "rails_helper"

RSpec.describe Content::Importer do
  subject(:import) { described_class.new.call }

  it "loads all 9 problems with their parts and all 70 warm-up reps" do
    expect(import).to eq(problems: 9, warmups: 70)
    expect(Exercise.problem.count).to eq(9)
    expect(Exercise.warmup.count).to eq(70)
    expect(Part.count).to eq(Exercise.problem.sum(:parts_count))
  end

  it "is idempotent" do
    described_class.new.call

    expect { described_class.new.call }.not_to change { [ Exercise.count, Part.count, Exercise.maximum(:updated_at) ] }
  end

  it "updates an existing exercise in place, keeping its id" do
    import
    exercise = Exercise.find_by!(slug: "warmup-a01")
    exercise.update!(title: "stale")

    described_class.new.call

    expect(exercise.reload.title).to start_with("A1 ·")
  end

  it "imports a problem's parts, notes, files and paths" do
    import
    problem = Exercise.find_by!(slug: "01-refill-tracker")

    expect(problem).to have_attributes(title: "Medication Refill Tracker", parts_count: 4,
      code_path: "work/01_refill_tracker.rb", test_path: "tests/01_refill_tracker_test.rb")
    expect(problem.parts.first.description_md).to start_with("## Part 1")
    expect(problem.notes_md).to include("clarifying questions")
    expect(problem.prelude_code).to include("def part(number)")
  end

  it "builds warm-up descriptions with the return shape and expected value" do
    import
    rep = Exercise.find_by!(slug: "warmup-b01")

    expect(rep.description_md).to include("Return `[ascending, descending]`.", "[[1, 2, 3, 5, 8, 9], [9, 8, 5, 3, 2, 1]]")
    expect(rep.prelude_code).to include("NUMS = [5, 3, 8, 1, 9, 2].freeze")
  end

  it "adds per-rep setup after the shared data" do
    import

    expect(Exercise.find_by!(slug: "warmup-a07").prelude_code).to end_with("totals = FILLS.each_with_object(Hash.new(0)) { |f, h| h[f[:patient]] += f[:cents] }\n")
  end

  it "rotates categories in catalog order" do
    import

    expect(Exercise.warmup.in_catalog_order.distinct.pluck(:category)).to eq(
      %w[hashes sorting enumerables strings structs-and-patterns sets lists-and-hashes]
    )
  end
end
