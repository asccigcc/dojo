require "rails_helper"

RSpec.describe "Solution and interviewer notes gate" do
  let!(:problem) do
    create(:exercise, :problem, solution_code: "class Counter\n  REFERENCE = true\nend\n", notes_md: "Ask about edge cases.")
  end

  before do
    script_runner
    sign_in_as("Ana")
    visit exercise_path(problem)
    wait_for_stream_connection
  end

  it "keeps the solution locked before an attempt and reveals it after one" do
    expect(page).to have_button("Reveal solution", disabled: true)
    expect(page).to have_no_text("REFERENCE = true")
    expect(page).to have_no_text("Ask about edge cases.")

    type_code("an honest attempt")
    click_on "Run"
    expect(page).to have_css("#results", text: "Failed")

    click_on "Reveal solution"

    expect(page).to have_css("#solution", text: "REFERENCE = true")
    expect(page).to have_css("#solution", text: "Ask about edge cases.")
  end
end
