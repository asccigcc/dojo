require "rails_helper"

RSpec.describe RunResult do
  it "maps runner counts onto submission columns" do
    result = described_class.from_response("status" => "failed", "tests" => { "runs" => 3, "failures" => 1, "errors" => 2 })

    expect(result.submission_attributes).to include(status: "failed", runs: 3, failures_count: 1, errors_count: 2, skips: 0)
  end

  it "treats an unknown status as an error" do
    expect(described_class.from_response("status" => "hacked").status).to eq("error")
  end

  it "keeps the runner's truncation marker in the stored output" do
    stdout = "#{'x' * 64.kilobytes}\n...[output truncated: 9 more bytes]"

    expect(described_class.new(status: "failed", stdout:).submission_attributes[:output]).to end_with("9 more bytes]")
  end
end
