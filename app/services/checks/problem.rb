module Checks
  # Problem check: the kit's minitest file with PART=n, with the learner's
  # code in place of the kit's work/ file.
  class Problem
    # @param exercise [Exercise] a problem
    # @param code [String]
    # @param part [Integer]
    def initialize(exercise, code, part:)
      @exercise = exercise
      @code = code
      @part = part
    end

    # @return [Hash]
    def payload
      { mode: "minitest", entry: @exercise.test_path, env: { "PART" => @part.to_s }, timeout_s: TIMEOUT_S, files: }
    end

    private

    def files
      { helper_path => @exercise.prelude_code, @exercise.test_path => @exercise.test_code, @exercise.code_path => @code }
    end

    def helper_path = File.join(File.dirname(@exercise.test_path), "test_helper.rb")
  end
end
