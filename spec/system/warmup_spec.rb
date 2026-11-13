require "rails_helper"

RSpec.describe "Warm-up round trip" do
  let!(:warmup) { create(:exercise, title: "A1 · Count words", prelude_code: "WORDS = %w[a b a].freeze\n") }

  before do
    script_runner
    sign_in_as("Ana")
    visit exercise_path(warmup)
    wait_for_stream_connection
    mark_page
  end

  it "fails, then passes, on the same open page" do
    expect(page).to have_css(".cm-editor")
    find("summary", text: "Data available to your code").click
    expect(page).to have_text("WORDS = %w[a b a].freeze")

    type_code("WORDS.size")
    click_on "Run"
    expect(page).to have_css("#results", text: "Failed")

    type_code("WORDS.tally")
    click_on "Run"

    expect(page).to have_css("#results", text: "Passed")
    expect(page).to have_css("#parts", text: "Passed. This rep comes back on your review schedule.")
    expect(page_not_reloaded?).to be(true)
  end
end
