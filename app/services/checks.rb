# Builds the runner payload that checks a learner's code for an exercise.
module Checks
  TIMEOUT_S = 5

  # @param exercise [Exercise]
  # @param code [String] the learner's code
  # @param part [Integer] for problems, run parts 1..part
  # @return [Hash] JSON-ready body for POST /run
  def self.payload_for(exercise, code, part:)
    exercise.warmup? ? Warmup.new(exercise, code).payload : Problem.new(exercise, code, part:).payload
  end
end
