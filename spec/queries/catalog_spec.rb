require "rails_helper"

RSpec.describe Catalog do
  let(:user) { create(:user) }

  it "groups exercises by kind and category in catalog order, with the learner's progress" do
    sorting = create(:exercise, category: "sorting", position: 11)
    hashes = create(:exercise, category: "hashes", position: 1)
    problem = create(:exercise, :problem, category: "intervals")
    create(:progress, user:, exercise: hashes, last_result: "passed")

    sections = described_class.new(user).sections

    expect(sections.map(&:kind)).to eq(%w[warmup problem])
    expect(sections.first.groups.keys).to eq(%w[hashes sorting])
    expect(sections.first.groups["hashes"].first.progress.last_result).to eq("passed")
    expect(sections.first.groups["sorting"].first.exercise).to eq(sorting)
    expect(sections.last.groups["intervals"].map(&:exercise)).to eq([ problem ])
  end
end
