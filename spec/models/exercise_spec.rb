require "rails_helper"

RSpec.describe Exercise do
  it "uses the slug as its URL param" do
    expect(build(:exercise, slug: "warmup-a01").to_param).to eq("warmup-a01")
  end

  it "rejects unknown kinds" do
    expect(build(:exercise, kind: "quiz")).not_to be_valid
  end

  it "rejects slugs that are not URL-safe" do
    expect(build(:exercise, slug: "A 1")).not_to be_valid
  end

  it "knows its final part" do
    exercise = build(:exercise, :problem, parts_count: 4)

    expect([ exercise.final_part?(3), exercise.final_part?(4) ]).to eq([ false, true ])
  end

  it "orders parts by number" do
    exercise = create(:exercise, :problem, parts_count: 3)

    expect(exercise.parts.map(&:number)).to eq([ 1, 2, 3 ])
  end
end
