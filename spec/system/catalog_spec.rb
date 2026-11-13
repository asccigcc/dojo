require "rails_helper"

RSpec.describe "Catalog" do
  before do
    create(:exercise, title: "A1 · Count words", category: "hashes", position: 1)
    create(:exercise, title: "B1 · Sort numbers", category: "sorting", position: 11)
    create(:exercise, :problem, title: "Coverage Windows", category: "intervals")
    sign_in_as("Ana")
  end

  it "groups exercises by kind and category and links to each one" do
    click_on "Catalog"

    warmups = find("section", text: /\AWarm-ups/)
    expect(warmups).to have_css("h3", text: /set a: hashes and counting/i)
    expect(warmups).to have_css("h3", text: /set b: sorting/i)
    expect(find("section", text: /\AProblems/)).to have_css("h3", text: /intervals/i)

    click_on "Coverage Windows"

    expect(page).to have_css("h1", text: "Coverage Windows")
  end
end
