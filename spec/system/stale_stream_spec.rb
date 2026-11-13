require "rails_helper"

# Regression: Action Cable may deliver a run's broadcasts out of order, and
# the Run request's own response can arrive after the final broadcast. An
# older fragment must never overwrite a newer one on the page.
RSpec.describe "Stale Turbo Streams" do
  let(:user) { create(:user, name: "Ana") }
  let!(:problem) { create(:exercise, :problem, parts_count: 2) }

  def stream(target, component)
    html = ApplicationController.render(component, layout: false)
    %(<turbo-stream action="replace" target="#{target}"><template>#{html}</template></turbo-stream>)
  end

  def deliver(markup) = page.execute_script("Turbo.renderStreamMessage(arguments[0])", markup)

  before do
    script_runner
    sign_in_as(user.name)
    visit exercise_path(problem)
    wait_for_stream_connection
  end

  it "keeps the final verdict when a late 'queued' or 'running' panel for the same run arrives" do
    type_code("not yet")
    click_on "Run"
    expect(page).to have_css("#results", text: "Failed")
    submission = user.submissions.last

    %w[pending running].each do |status|
      deliver(stream("results", ResultsPanelComponent.new(submission: Submission.instantiate(submission.attributes.merge("status" => status)))))
    end

    expect(page).to have_no_css("#results", text: /Running|Queued/, wait: 1)
    expect(page).to have_css("#results", text: "Failed")
  end

  it "still applies a newer run's panel" do
    type_code("not yet")
    click_on "Run"
    expect(page).to have_css("#results", text: "Failed")

    type_code("# solved")
    click_on "Run"

    expect(page).to have_css("#results", text: "Passed")
  end

  it "keeps unlocked parts when an older run's parts fragment arrives late" do
    type_code("# solved")
    click_on "Run"
    expect(page).to have_css("#parts", text: "Part 2 text")

    stale_page = ExercisePage.new(user, problem).tap { |page_data| page_data.progress.unlocked_part = 1 }
    allow(stale_page).to receive(:latest_submission).and_return(Submission.new(id: 0, status: "failed"))
    deliver(stream("parts", PartsComponent.new(page: stale_page)))

    expect(page).to have_css("#parts", text: "Part 2 text", wait: 1)
  end
end
