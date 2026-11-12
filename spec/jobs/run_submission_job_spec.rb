require "rails_helper"

RSpec.describe RunSubmissionJob do
  it "runs the submission through the runner for its language" do
    fake = stub_runner(passed_result)
    submission = create(:submission)

    described_class.perform_now(submission)

    expect(RunnerClient).to have_received(:for).with("ruby")
    expect([ fake.payloads.size, submission.reload.status ]).to eq([ 1, "passed" ])
  end
end
