require "rails_helper"

RSpec.describe ProgressRecorder do
  let(:user) { create(:user) }
  let(:problem) { create(:exercise, :problem, parts_count: 2) }
  let(:now) { Time.zone.local(2026, 11, 11, 9) }

  def record(status, exercise: problem, part: 1)
    submission = create(:submission, user:, exercise:, part_number: part, status:)
    described_class.new(submission, now:).call
  end

  def progress(exercise = problem) = user.progresses.find_by!(exercise:)

  it "unlocks the next part after a pass and keeps the problem due" do
    record("passed")

    expect(progress).to have_attributes(unlocked_part: 2, next_review_at: now, interval_index: nil, last_result: "passed")
  end

  it "moves one rung up the ladder on a full pass" do
    record("passed")
    record("passed", part: 2)

    expect(progress).to have_attributes(unlocked_part: 2, interval_index: 0, next_review_at: now + 1.day, passes_count: 1)
  end

  it "climbs again on the next full pass" do
    create(:progress, user:, exercise: problem, unlocked_part: 2, interval_index: 0)
    record("passed", part: 2)

    expect(progress).to have_attributes(interval_index: 1, next_review_at: now + 3.days)
  end

  it "resets to one day on a fail" do
    create(:progress, user:, exercise: problem, unlocked_part: 2, interval_index: 3)
    record("timeout", part: 2)

    expect(progress).to have_attributes(interval_index: nil, next_review_at: now + 1.day, last_result: "timeout")
  end

  it "treats a warm-up pass as a full pass" do
    warmup = create(:exercise)
    record("passed", exercise: warmup)

    expect(progress(warmup)).to have_attributes(unlocked_part: 1, interval_index: 0, passes_count: 1)
  end

  it "never re-locks a part when an earlier part is re-run" do
    create(:progress, user:, exercise: problem, unlocked_part: 2)
    record("passed", part: 1)

    expect(progress.unlocked_part).to eq(2)
  end
end
