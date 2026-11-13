require "rails_helper"

RSpec.describe SubmissionRun do
  let(:user) { create(:user) }
  let(:exercise) { create(:exercise) }
  let(:submission) { create(:submission, user:, exercise:, code: "WORDS.tally") }

  it "sends the check payload for the submission's code" do
    fake = FakeRunnerClient.new(passed_result)

    described_class.new(submission, client: fake).call

    expect(fake.payloads.first).to include(mode: "expression", files: include("answer.rb" => "WORDS.tally"))
  end

  it "records the verdict and updates progress" do
    described_class.new(submission, client: FakeRunnerClient.new(failed_result)).call

    expect(submission.reload).to have_attributes(status: "failed", runs: 2, failures_count: 1)
    expect(user.progresses.find_by!(exercise:).last_result).to eq("failed")
  end

  it "does not touch progress when the runner is unavailable" do
    described_class.new(submission, client: FakeRunnerClient.new(RunResult.unavailable("down"))).call

    expect(submission.reload.status).to eq("error")
    expect(Progress.where(user:)).to be_empty
  end

  it "streams the running state and then the result to the exercise page" do
    described_class.new(submission, client: FakeRunnerClient.new(passed_result)).call

    targets = turbo_stream_targets(user, exercise)
    expect(targets.first).to eq("results")
    expect(targets).to include("parts", "run_scope", "solution_gate", "history")
  end
end
