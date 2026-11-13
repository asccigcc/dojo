require "rails_helper"

RSpec.describe "Code editor" do
  let!(:problem) { create(:exercise, :problem, parts_count: 2, title: "Counter", starter_code: "class Counter\nend\n") }
  let!(:runner) { script_runner }

  before do
    sign_in_as("Ana")
    visit exercise_path(problem)
    wait_for_stream_connection
  end

  it "mounts CodeMirror with the starter code and hides the plain textarea" do
    expect(page).to have_css(".cm-editor .cm-content", text: "class Counter")
    expect(page).to have_css(".cm-lineNumbers")
    expect(page).to have_no_field("submission[code]")
  end

  it "submits what was typed into the editor when Run is clicked" do
    type_code("typed by hand")
    click_on "Run"

    expect(page).to have_css("#results", text: "Failed")
    expect(runner.payloads.map { |payload| payload[:files]["work/counter.rb"] }).to eq([ "typed by hand" ])
  end

  it "submits with Cmd/Ctrl+Enter from inside the editor" do
    type_code("via shortcut")
    find(".cm-content").send_keys([ mod_key, :enter ])

    expect(page).to have_css("#results", text: "Failed")
    expect(runner.payloads.size).to eq(1)
    expect(runner.payloads.first[:files]["work/counter.rb"]).to eq("via shortcut")
  end

  it "restores the starter code with Reset" do
    type_code("scratch")
    click_on "Reset to starter"

    expect(page).to have_css(".cm-content", text: "class Counter")
  end
end
