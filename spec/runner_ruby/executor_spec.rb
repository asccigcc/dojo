require_relative "runner_helper"

RSpec.describe DojoRunner::Executor do
  describe "minitest mode" do
    let(:solution) { "class Counter\n  attr_reader :value\n  def initialize = @value = 0\n  def increment = @value += 1\nend\n" }

    it "passes and reports counts from the JSON reporter" do
      result = run_payload(minitest_payload(solution, part: "2"))

      expect(result).to include(status: "passed", tests: include("runs" => 2, "failures" => 0, "skips" => 0))
    end

    it "skips locked parts, so part 1 passes on its own" do
      result = run_payload(minitest_payload("class Counter\n  def value = 0\nend\n", part: "1"))

      expect(result).to include(status: "passed", tests: include("skips" => 1))
    end

    it "fails with the test name and message" do
      result = run_payload(minitest_payload("class Counter\n  def value = 7\nend\n"))

      expect(result[:status]).to eq("failed")
      expect(result[:failures].first).to include("name" => "test_part1_starts_at_zero", "message" => /Expected: 0/)
    end

    it "reports a syntax error as an error with stderr" do
      result = run_payload(minitest_payload("class Counter\n  def value(\nend\n"))

      expect(result).to include(status: "error", stderr: /syntax/i)
    end
  end

  describe "expression mode" do
    it "passes when the last expression equals the expected value" do
      expect(run_payload(expression_payload("NUMS.sort"))[:status]).to eq("passed")
    end

    it "fails with expected and actual shown" do
      result = run_payload(expression_payload("NUMS"))

      expect(result[:status]).to eq("failed")
      expect(result[:failures].first["message"]).to eq("Expected: [1, 2]\n  Actual: [2, 1]")
    end

    it "reports exceptions as errors" do
      result = run_payload(expression_payload("NUMS.fetch(9)"))

      expect(result).to include(status: "error", failures: [ include("message" => /IndexError/) ])
    end

    it "keeps user locals from clobbering the harness" do
      expect(run_payload(expression_payload("show = write = 1\nNUMS.sort"))[:status]).to eq("passed")
    end
  end

  describe "limits" do
    it "kills an infinite loop at the wall-clock timeout" do
      result = run_payload(expression_payload("loop {}", timeout_s: 1))

      expect(result[:status]).to eq("timeout")
      expect(result[:duration_ms]).to be < 3_000
    end

    it "truncates a giant puts to 64 KB" do
      result = run_payload(expression_payload("puts 'x' * 1_000_000\nNUMS.sort"))

      expect(result[:stdout].bytesize).to be < 66 * 1024
      expect(result[:stdout]).to include("output truncated")
    end

    it "kills processes the program forked into its group" do
      result = run_payload(expression_payload("pid = fork { sleep 30 }\nputs pid\n$stdout.flush\nsleep 30", timeout_s: 1))
      child = Integer(result[:stdout].lines.first)

      expect { Process.kill(0, child) }.to raise_error(Errno::ESRCH)
    end

    it "does not pass the parent environment through" do
      ENV["DOJO_SECRET_PROBE"] = "leak"
      result = run_payload(expression_payload("puts ENV.keys.sort.join(',')\nNUMS.sort"))

      expect(result[:stdout]).not_to include("DOJO_SECRET_PROBE")
    ensure
      ENV.delete("DOJO_SECRET_PROBE")
    end

    it "removes the workspace afterwards" do
      result = run_payload(expression_payload("puts Dir.pwd\nNUMS.sort"))

      expect(File.exist?(result[:stdout].strip)).to be(false)
    end
  end
end
