require_relative "runner_helper"

RSpec.describe DojoRunner::Report do
  def outcome(timed_out: false)
    DojoRunner::Sandbox::Outcome.new(exit_status: 0, timed_out:, stdout: "", stderr: "", duration_ms: 3)
  end

  def tests(**counts) = { "tests" => { "runs" => 2, "skips" => 0, "failures" => 0, "errors" => 0 }.merge(counts.transform_keys(&:to_s)) }

  it "reports timeout first" do
    expect(described_class.new(outcome(timed_out: true), tests).status).to eq("timeout")
  end

  it "reports error when the harness never wrote a verdict" do
    expect(described_class.new(outcome, nil).status).to eq("error")
  end

  it "reports passed when nothing failed and something ran" do
    expect(described_class.new(outcome, tests).status).to eq("passed")
  end

  it "reports failed on failures or errors" do
    expect(described_class.new(outcome, tests(failures: 1)).status).to eq("failed")
    expect(described_class.new(outcome, tests(errors: 1)).status).to eq("failed")
  end

  it "does not count an all-skipped run as a pass" do
    expect(described_class.new(outcome, tests(skips: 2)).status).to eq("failed")
  end
end
