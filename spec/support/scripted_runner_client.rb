# Deterministic RunnerClient double for system specs: the verdict is decided
# by a block over the payload, so a spec controls pass/fail by what it types.
# Thread-safe enough for Capybara's server thread (Array#<< under the GVL).
class ScriptedRunnerClient
  attr_reader :payloads

  def initialize(&verdict)
    @verdict = verdict
    @payloads = []
  end

  def run(payload)
    @payloads << payload
    @verdict.call(payload)
  end

  # @return [String] the learner code a payload carries
  def self.code_of(payload) = payload[:files].fetch(payload[:mode] == "expression" ? "answer.rb" : payload[:files].keys.last)
end

# Helpers shared by the system specs.
module SystemHelpers
  # Passes when the submitted code contains "solved" (problems) or equals
  # "WORDS.tally" (warm-ups); everything else fails with a readable message.
  def script_runner
    ScriptedRunnerClient.new do |payload|
      code = payload[:mode] == "expression" ? payload[:files]["answer.rb"] : payload[:files][payload[:files].keys.last]
      code.include?("solved") || code.strip == "WORDS.tally" ? passed_result : failed_result
    end.tap { |fake| allow(RunnerClient).to receive(:for).and_return(fake) }
  end

  def sign_in_as(name)
    visit new_session_path
    fill_in "Username", with: name
    click_on "Sign in"
    expect(page).to have_text("Welcome, #{name}.")
  end

  # Marks the current document; a full reload or a Turbo Drive visit would
  # replace <body> and lose the mark.
  def mark_page = page.execute_script("document.body.dataset.noReload = 'yes'")

  def page_not_reloaded? = page.evaluate_script("document.body.dataset.noReload") == "yes"

  def wait_for_stream_connection
    expect(page).to have_css("turbo-cable-stream-source[connected]", visible: :all)
  end

  # Replaces the editor content by keyboard, as a learner would.
  def type_code(text)
    editor = find(".cm-content")
    editor.click
    editor.send_keys([ mod_key, "a" ], :backspace, text)
  end

  def mod_key = page.evaluate_script("/Mac/.test(navigator.platform)") ? :meta : :control
end

RSpec.configure { |config| config.include SystemHelpers, type: :system }
