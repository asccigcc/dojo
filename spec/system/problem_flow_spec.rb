require "rails_helper"

RSpec.describe "Working through a multi-part problem" do
  let!(:problem) { create(:exercise, :problem, parts_count: 3, title: "Counter") }

  before do
    script_runner
    sign_in_as("Ana")
    visit exercise_path(problem)
    wait_for_stream_connection
    mark_page
  end

  it "shows a failing run's status and message live, without a reload" do
    type_code("not yet")
    click_on "Run"

    within("#results") do
      expect(page).to have_text("Failed")
      expect(page).to have_text("test_part1")
      expect(page).to have_text("Expected: 1")
    end
    expect(page_not_reloaded?).to be(true)
  end

  it "unlocks part 2 live after part 1 passes, keeping part 1 and hiding part 3" do
    expect(page).to have_text("Part 1 text")
    expect(page).to have_no_text("Part 2 text")

    type_code("# solved part 1")
    click_on "Run"

    expect(page).to have_css("#parts", text: /part 2 of 3/i)
    expect(page).to have_css("#parts", text: "Part 1 text")
    expect(page).to have_css("#parts", text: "Part 2 text")
    expect(page).to have_no_text("Part 3 text")
    expect(page).to have_css("#run_scope", text: "Run checks parts 1 to 2.")
    expect(page_not_reloaded?).to be(true)
  end

  it "adds each run to the history live" do
    expect(page).to have_css("#history", text: "No runs yet.")

    type_code("first try")
    click_on "Run"
    expect(page).to have_css("#history li", count: 1)

    type_code("# solved now")
    click_on "Run"

    expect(page).to have_css("#history li", count: 2)
    expect(find("#history li", match: :first)).to have_text("Passed")
    expect(page_not_reloaded?).to be(true)
  end
end
