module Checks
  # Warm-up check: the value of the code's last expression, after the shared
  # data prelude, must `==` the rep's expected Ruby expression.
  class Warmup
    # @param exercise [Exercise] a warm-up
    # @param code [String]
    def initialize(exercise, code)
      @exercise = exercise
      @code = code
    end

    # @return [Hash]
    def payload
      { mode: "expression", timeout_s: TIMEOUT_S,
        files: { "prelude.rb" => @exercise.prelude_code, "answer.rb" => @code, "expected.rb" => @exercise.expected_code } }
    end
  end
end
