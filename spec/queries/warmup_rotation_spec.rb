require "rails_helper"

RSpec.describe WarmupRotation do
  let(:order) { %w[hashes sorting sets] }

  def rep(slug, category) = build(:exercise, slug:, category:)

  it "starts with the first category when nothing was practiced" do
    candidates = [ rep("a1", "hashes"), rep("b1", "sorting") ]

    expect(described_class.new(candidates, order:, after: nil).next.slug).to eq("a1")
  end

  it "moves to the category after the last one practiced" do
    candidates = [ rep("a2", "hashes"), rep("b1", "sorting"), rep("f1", "sets") ]

    expect(described_class.new(candidates, order:, after: "hashes").next.slug).to eq("b1")
  end

  it "wraps around and skips categories with nothing left" do
    candidates = [ rep("a2", "hashes") ]

    expect(described_class.new(candidates, order:, after: "sorting").next.slug).to eq("a2")
  end

  it "returns nil when nothing is left" do
    expect(described_class.new([], order:, after: "hashes").next).to be_nil
  end
end
