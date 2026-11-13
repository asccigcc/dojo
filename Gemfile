source "https://rubygems.org"

gem "rails", "~> 8.1.4", ">= 8.1.4.1"
gem "sqlite3", ">= 2.1"
gem "puma", ">= 5.0"
gem "bootsnap", require: false
gem "tzinfo-data", platforms: %i[ windows jruby ]

# Jobs and Turbo Stream broadcasts backed by SQLite (no Redis).
gem "solid_queue"
gem "solid_cable"

# Frontend: Vite Ruby bundles Tailwind v4, Turbo, Stimulus and CodeMirror from npm.
gem "vite_rails"
gem "turbo-rails"
gem "view_component"

# Markdown for exercise descriptions.
gem "redcarpet"

group :development, :test do
  gem "debug", platforms: %i[ mri windows ], require: "debug/prelude"
  gem "bundler-audit", require: false
  gem "brakeman", require: false
  gem "rubocop-rails-omakase", require: false
  gem "rspec-rails"
  gem "factory_bot_rails"
end

group :development do
  gem "web-console"
end

group :test do
  gem "webmock"
  # System specs drive the installed Google Chrome over CDP (no chromedriver).
  gem "capybara"
  gem "cuprite"
end
