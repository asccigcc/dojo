# Reads Turbo Stream broadcasts from the test cable adapter without the
# minitest-only assertion helpers that ship with turbo-rails.
module TurboStreamHelper
  def turbo_stream_targets(*streamables)
    name = streamables.map(&:to_gid_param).join(":")
    ActionCable.server.pubsub.broadcasts(name).map { |message| JSON.parse(message)[/target="([^"]+)"/, 1] }
  end
end

RSpec.configure do |config|
  config.include TurboStreamHelper
  config.before { ActionCable.server.pubsub.clear }
end
