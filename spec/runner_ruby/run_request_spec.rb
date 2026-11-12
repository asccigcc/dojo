require_relative "runner_helper"

RSpec.describe DojoRunner::RunRequest do
  let(:valid) { expression_payload("NUMS.sort") }

  it "accepts a valid expression payload" do
    expect(described_class.new(valid).mode).to eq("expression")
  end

  it "rejects unknown modes" do
    expect { described_class.new(valid.merge("mode" => "shell")) }.to raise_error(DojoRunner::InvalidRequest, /mode/)
  end

  it "rejects paths that escape the workspace or are absolute" do
    [ "../evil.rb", "/etc/evil.rb", "a/../../b.rb", "x.sh" ].each do |path|
      payload = valid.merge("files" => valid["files"].merge(path => "1"))

      expect { described_class.new(payload) }.to raise_error(DojoRunner::InvalidRequest, /path/)
    end
  end

  it "only allows whitelisted environment variables" do
    payload = valid.merge("env" => { "RUBYOPT" => "-rsocket" })

    expect { described_class.new(payload) }.to raise_error(DojoRunner::InvalidRequest, /RUBYOPT/)
  end

  it "clamps the timeout into 1..10 seconds" do
    expect(described_class.new(valid.merge("timeout_s" => 999)).timeout_s).to eq(10)
    expect(described_class.new(valid.merge("timeout_s" => 0)).timeout_s).to eq(1)
  end

  it "requires minitest runs to name an entry file that exists" do
    payload = minitest_payload("").merge("entry" => "tests/missing_test.rb")

    expect { described_class.new(payload) }.to raise_error(DojoRunner::InvalidRequest, /entry/)
  end

  it "requires the expression files" do
    payload = valid.merge("files" => { "answer.rb" => "1" })

    expect { described_class.new(payload) }.to raise_error(DojoRunner::InvalidRequest, /expected\.rb/)
  end

  it "rejects malformed JSON" do
    expect { described_class.parse("{nope") }.to raise_error(DojoRunner::InvalidRequest, /JSON/)
  end
end
