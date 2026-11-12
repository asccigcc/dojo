require "rails_helper"

RSpec.describe "Today" do
  it "shows one warm-up and one problem" do
    create(:exercise, title: "A1 · Count words")
    create(:exercise, :problem, title: "Refill Tracker")
    sign_in(create(:user))

    get root_path

    expect(response.body).to include("A1 · Count words", "Refill Tracker")
  end

  it "says so when there is nothing to practice" do
    sign_in(create(:user))

    get root_path

    expect(response.body).to include(I18n.t("home.show.nothing_due"))
  end
end
