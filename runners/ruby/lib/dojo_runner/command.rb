module DojoRunner
  # Builds the argv for a run mode. The harness files are required before any
  # user code so they can capture the result path first.
  module Command
    # @param request [RunRequest]
    # @param ruby [String] absolute path to the interpreter
    # @return [Array<String>]
    def self.for(request, ruby: RbConfig.ruby)
      case request.mode
      when "minitest" then [ ruby, "-I", HARNESS_DIR, "-r", "dojo_minitest", request.entry ]
      when "expression" then [ ruby, File.join(HARNESS_DIR, "dojo_expression.rb") ]
      end
    end
  end
end
