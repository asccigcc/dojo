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

  describe "#stream_version" do
    it "orders states of one submission: pending < running < finished" do
      submission = create(:submission)
      versions = %w[pending running failed].map { |status| submission.tap { _1.status = status }.stream_version }

      expect(versions).to eq(versions.sort).and(eq(versions.uniq))
    end

    it "ranks any state of a newer submission above every state of an older one" do
      older, newer = create_list(:submission, 2)

      expect(newer.tap { _1.status = "pending" }.stream_version).to be > older.tap { _1.status = "passed" }.stream_version
    end
  end
end
