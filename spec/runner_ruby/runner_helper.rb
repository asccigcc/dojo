require "spec_helper"
require "rack"
require "rack/mock"
require_relative "../../runners/ruby/lib/dojo_runner"

# Payload builders shared by the runner specs.
module RunnerPayloads
  TEST_HELPER = <<~RUBY
    require "minitest/autorun"
    PART = Integer(ENV.fetch("PART", "1"))
    class Minitest::Test
      def part(number) = (skip("unlocks at part \#{number}") if PART < number)
    end
  RUBY

  def minitest_payload(code, part: "1", timeout_s: 5)
    test = <<~RUBY
      require_relative "test_helper"
      require_relative "../work/counter"
      class CounterTest < Minitest::Test
        def test_part1_starts_at_zero = assert_equal(0, Counter.new.value)
        def test_part2_increments
          part 2
          assert_equal 1, Counter.new.tap(&:increment).value
        end
      end
    RUBY
    { "mode" => "minitest", "entry" => "tests/counter_test.rb", "env" => { "PART" => part }, "timeout_s" => timeout_s,
      "files" => { "tests/test_helper.rb" => TEST_HELPER, "tests/counter_test.rb" => test, "work/counter.rb" => code } }
  end

  def expression_payload(answer, expected: "[1, 2]", prelude: "NUMS = [2, 1].freeze", timeout_s: 5)
    { "mode" => "expression", "timeout_s" => timeout_s,
      "files" => { "prelude.rb" => prelude, "answer.rb" => answer, "expected.rb" => expected } }
  end

  def run_payload(payload)
    DojoRunner::Executor.new.call(DojoRunner::RunRequest.new(payload))
  end
end

RSpec.configure { |config| config.include RunnerPayloads, file_path: %r{spec/runner_ruby} }
