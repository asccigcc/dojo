require "rails_helper"

RSpec.describe Submission do
  it "starts pending" do
    expect(described_class.new.status).to eq("pending")
  end

  it "is finished only after a verdict" do
    expect(build(:submission, status: "running")).not_to be_finished
    expect(build(:submission, status: "timeout")).to be_finished
  end

  it "rejects oversized code" do
    expect(build(:submission, code: "x" * 100_001)).not_to be_valid
  end
end
