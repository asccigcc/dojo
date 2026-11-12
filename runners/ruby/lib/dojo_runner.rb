require "json"
require "fileutils"
require "tmpdir"
require "rbconfig"

# Executes untrusted Ruby in a throwaway workspace under OS resource limits.
# The HTTP layer (DojoRunner::App) is a thin shell over DojoRunner::Executor.
module DojoRunner
  # Raised when a /run payload is malformed or asks for something unsafe.
  class InvalidRequest < StandardError; end

  HARNESS_DIR = File.expand_path("../harness", __dir__)

  # @return [Boolean] true when running inside the hardened container
  def self.sandboxed? = ENV["DOJO_SANDBOXED"] == "1"
end

require_relative "dojo_runner/run_request"
require_relative "dojo_runner/workspace"
require_relative "dojo_runner/limits"
require_relative "dojo_runner/bounded_reader"
require_relative "dojo_runner/sandbox"
require_relative "dojo_runner/command"
require_relative "dojo_runner/report"
require_relative "dojo_runner/executor"
require_relative "dojo_runner/app"
