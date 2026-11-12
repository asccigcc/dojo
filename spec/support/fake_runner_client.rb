# Same interface as RunnerClient (#run(payload) -> RunResult), with canned
# results. Records payloads so specs can assert what would have been sent.
class FakeRunnerClient
  attr_reader :payloads

  def initialize(*results)
    @results = results
    @payloads = []
  end

  def run(payload)
    @payloads << payload
    @results.shift || RunResult.new(status: "passed", tests: { "runs" => 1, "assertions" => 1 })
  end
end

module FakeRunnerHelper
  def stub_runner(*results)
    FakeRunnerClient.new(*results).tap { |fake| allow(RunnerClient).to receive(:for).and_return(fake) }
  end

  def passed_result = RunResult.new(status: "passed", tests: { "runs" => 2, "assertions" => 3 })

  def failed_result
    RunResult.new(status: "failed", tests: { "runs" => 2, "failures" => 1 },
      failures: [ { "name" => "test_part1", "message" => "Expected: 1\n  Actual: 2" } ])
  end
end

RSpec.configure { |config| config.include FakeRunnerHelper }
