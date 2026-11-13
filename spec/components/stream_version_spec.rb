require "rails_helper"

# Every fragment that Turbo Streams replace carries the version the browser's
# stale-stream guard compares (see app/frontend/streams/stale_stream_guard.js).
RSpec.describe "Stream versions on live fragments", type: :component do
  let(:user) { create(:user) }
  let(:problem) { create(:exercise, :problem) }
  let!(:submission) { create(:submission, user:, exercise: problem, status: "failed") }
  let(:page_data) { ExercisePage.new(user, problem) }

  def version_in(html) = html[/data-stream-version="(\d+)"/, 1]&.to_i

  it "stamps the results panel with its submission's version" do
    html = render_inline(ResultsPanelComponent.new(submission:)).to_html

    expect(version_in(html)).to eq(submission.stream_version)
  end

  it "stamps the parts, solution gate and history with the latest submission's version" do
    [ PartsComponent.new(page: page_data), SolutionGateComponent.new(page: page_data),
      SubmissionHistoryComponent.new(submissions: page_data.submissions) ].each do |component|
      expect(version_in(render_inline(component).to_html)).to eq(submission.stream_version)
    end
  end

  it "leaves an unsaved (invalid) submission unversioned so its errors always show" do
    html = render_inline(ResultsPanelComponent.new(submission: Submission.new(code: "x" * 100_001).tap(&:validate))).to_html

    expect(version_in(html)).to be_nil
  end
end
