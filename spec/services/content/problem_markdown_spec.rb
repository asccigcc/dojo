require "rails_helper"

RSpec.describe Content::ProblemMarkdown do
  subject(:markdown) { described_class.new(<<~MD) }
    # 01 · Thing Tracker (warm-up)

    Intro text.

    ---

    ## Part 1: first

    Do one.

    ---

    ## Part 2: second

    Do two.

    ---

    ## Interviewer notes (read after solving)

    - Ask questions.
  MD

  it "keeps the intro without the H1 or trailing rule" do
    expect(markdown.intro).to eq("Intro text.")
  end

  it "splits the parts by number, keeping each heading" do
    expect(markdown.parts).to eq({ 1 => "## Part 1: first\n\nDo one.", 2 => "## Part 2: second\n\nDo two." })
  end

  it "separates the interviewer notes" do
    expect(markdown.notes).to eq("- Ask questions.")
  end
end
