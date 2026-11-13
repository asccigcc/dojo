require "capybara/rspec"
require "capybara/cuprite"

# Headless Chrome via CDP. Ferrum finds the installed Google Chrome; set
# BROWSER_PATH to point at another Chrome/Chromium binary.
Capybara.register_driver(:cuprite) do |app|
  Capybara::Cuprite::Driver.new(app, window_size: [ 1400, 1000 ], headless: ENV["HEADFUL"].blank?,
    process_timeout: 30, timeout: 15, js_errors: true, browser_options: { "no-sandbox" => nil })
end
Capybara.default_max_wait_time = 5
Capybara.server = :puma, { Silent: true }

RSpec.configure do |config|
  config.before(:each, type: :system) { driven_by :cuprite }

  # The `test` cable adapter only records broadcasts. System specs need them
  # delivered to the open page, so they swap in the in-process async adapter.
  config.around(:each, type: :system) do |example|
    ActionCable.server.config.cable = { "adapter" => "async" }
    ActionCable.server.restart
    example.run
  ensure
    ActionCable.server.config.cable = { "adapter" => "test" }
    ActionCable.server.restart
  end
end

# Capybara's server and Chrome's DevTools socket are local; everything else stays blocked.
WebMock.disable_net_connect!(allow_localhost: true)
