require_relative "runner_helper"

RSpec.describe DojoRunner::App do
  let(:app) { Rack::MockRequest.new(described_class.new) }

  it "answers health checks with its language and sandbox flag" do
    body = JSON.parse(app.get("/health").body)

    expect(body).to include("status" => "ok", "language" => "ruby", "sandboxed" => false)
  end

  it "runs a payload over HTTP" do
    response = app.post("/run", input: JSON.generate(expression_payload("NUMS.sort")))

    expect(JSON.parse(response.body)).to include("status" => "passed")
  end

  it "returns 422 for invalid payloads" do
    expect(app.post("/run", input: "{}").status).to eq(422)
  end

  it "returns 404 for anything else" do
    expect(app.get("/run").status).to eq(404)
  end
end
