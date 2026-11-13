require "rails_helper"

# Proves Turbo Streams reach an open page over Action Cable: the run is
# executed from the test process (as a Solid Queue worker would), not by any
# request from the page.
RSpec.describe "Live updates from a background run" do
  let(:user) { create(:user, name: "Ana") }
  let!(:problem) { create(:exercise, :problem, parts_count: 2) }

  it "updates results, parts and history on the open page without any request from it" do
    sign_in_as(user.name)
    visit exercise_path(problem)
    wait_for_stream_connection
    mark_page

    submission = create(:submission, user:, exercise: problem, code: "# solved", part_number: 1)
    SubmissionRun.new(submission, client: FakeRunnerClient.new(passed_result)).call

    expect(page).to have_css("#results", text: "Passed")
    expect(page).to have_css("#parts", text: /part 2 of 2/i)
    expect(page).to have_css("#history li", count: 1)
    expect(page_not_reloaded?).to be(true)
  end
end
