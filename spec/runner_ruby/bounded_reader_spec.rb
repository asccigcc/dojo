require_relative "runner_helper"

RSpec.describe DojoRunner::BoundedReader do
  it "keeps the first bytes and notes how many were dropped" do
    read, write = IO.pipe
    reader = described_class.new(read, 10).start
    write.write("a" * 25)
    write.close

    expect(reader.value).to eq("#{'a' * 10}\n...[output truncated: 15 more bytes]")
  end
end
