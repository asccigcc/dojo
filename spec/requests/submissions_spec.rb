require "rails_helper"

RSpec.describe "Submissions" do
  let(:user) { create(:user) }
  let(:problem) { create(:exercise, :problem, parts_count: 2) }

  before { sign_in(user) }

  def run_code(code, exercise: problem, format: :turbo_stream)
    post exercise_submissions_path(exercise), params: { submission: { code: } }, as: format
  end

  it "runs the code inline in tests and streams back the finished result" do
    stub_runner(failed_result)

    run_code("class Counter; end")

    expect(response.media_type).to eq(Mime[:turbo_stream])
    expect(response.body).to include('target="results"', "Expected: 1")
    expect(user.submissions.last).to have_attributes(status: "failed", part_number: 1, code: "class Counter; end")
  end

  it "targets the highest unlocked part, which the server decides" do
    fake = stub_runner(passed_result, passed_result)

    2.times { run_code("class Counter; end") }

    expect(fake.payloads.map { |payload| payload[:env]["PART"] }).to eq(%w[1 2])
  end

  it "rejects oversized code without running it" do
    fake = stub_runner

    run_code("x" * 100_001)

    expect(response).to have_http_status(:unprocessable_content)
    expect(fake.payloads).to be_empty
  end

  it "redirects HTML submissions back to the exercise" do
    stub_runner

    run_code("1", format: nil)

    expect(response).to redirect_to(exercise_path(problem))
  end

  it "requires sign-in" do
    delete session_path
    run_code("1")

    expect(user.submissions).to be_empty
  end
end
