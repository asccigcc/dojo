require "rails_helper"

RSpec.describe "Signing in and out" do
  before do
    create(:exercise, title: "A1 · Count words")
    create(:exercise, :problem, title: "Refill Tracker")
  end

  it "signs in with just a username, shows one warm-up and one problem, then signs out" do
    sign_in_as("Ana")

    expect(page).to have_css("h1", text: "Today's practice")
    expect(page).to have_css("article", text: /\Awarm-up/i, count: 1)
    expect(page).to have_css("article", text: /\Aproblem/i, count: 1)
    expect(page).to have_css("article", text: "A1 · Count words")
    expect(page).to have_css("article", text: "Refill Tracker")
    expect(page).to have_link("Start", count: 2)

    click_on "Sign out"

    expect(page).to have_text("Signed out.")
    expect(page).to have_css("h1", text: "Enter the dojo")
  end

  it "rejects an invalid username" do
    visit new_session_path
    fill_in "Username", with: "<bad>"
    click_on "Sign in"

    expect(page).to have_text("Username is invalid")
  end
end
