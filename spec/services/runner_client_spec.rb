require "rails_helper"

RSpec.describe RunnerClient do
  let(:client) { described_class.new("http://runner.test:9292") }
  let(:payload) { { mode: "expression", files: { "answer.rb" => "1" } } }

  it "posts the payload as JSON and wraps the verdict" do
    stub = stub_request(:post, "http://runner.test:9292/run").with(body: payload.to_json)
      .to_return(status: 200, body: { status: "passed", stdout: "hi", tests: { runs: 1 } }.to_json)

    result = client.run(payload)

    expect(stub).to have_been_requested
    expect([ result.status, result.stdout, result.tests["runs"] ]).to eq([ "passed", "hi", 1 ])
  end

  it "reports an unreachable runner as unavailable" do
    stub_request(:post, "http://runner.test:9292/run").to_raise(Errno::ECONNREFUSED)

    expect(client.run(payload)).to have_attributes(status: "error", unavailable?: true)
  end

  it "reports a non-2xx answer as unavailable" do
    stub_request(:post, "http://runner.test:9292/run").to_return(status: 422, body: { error: "bad" }.to_json)

    expect(client.run(payload)).to have_attributes(unavailable?: true, stderr: /422/)
  end

  it "looks up the runner URL by language from config/runners.yml" do
    expect(described_class.for("ruby").url).to eq("http://127.0.0.1:9292")
  end

  it "is unavailable for a language without a runner" do
    expect(described_class.for("python").run(payload)).to have_attributes(unavailable?: true, stderr: /python/)
  end
end
