require "rails_helper"

RSpec.describe TodaysPractice do
  let(:user) { create(:user) }
  let(:now) { Time.zone.local(2026, 11, 11, 12) }
  let!(:a1) { create(:exercise, slug: "warmup-a01", category: "hashes", position: 1) }
  let!(:a2) { create(:exercise, slug: "warmup-a02", category: "hashes", position: 2) }
  let!(:b1) { create(:exercise, slug: "warmup-b01", category: "sorting", position: 11) }
  let!(:p1) { create(:exercise, :problem, slug: "01-first", position: 1) }
  let!(:p2) { create(:exercise, :problem, slug: "02-second", position: 2) }

  subject(:today) { described_class.new(user, now:) }

  def progress(exercise, **attrs) = create(:progress, user:, exercise:, **attrs)

  it "serves the first unseen warm-up and problem to a new learner" do
    expect([ today.warmup.exercise, today.problem.exercise ]).to eq([ a1, p1 ])
    expect(today.warmup.reason).to eq(:new)
  end

  it "puts the most overdue item first" do
    progress(p1, next_review_at: now - 1.day, last_attempted_at: now - 4.days, last_result: "passed")
    progress(p2, next_review_at: now - 3.days, last_attempted_at: now - 6.days, last_result: "passed")

    expect(today.problem).to have_attributes(exercise: p2, reason: :due)
  end

  it "ignores items scheduled in the future" do
    progress(p1, next_review_at: now + 2.days, last_attempted_at: now - 1.day, last_result: "passed")

    expect(today.problem.exercise).to eq(p2)
  end

  it "keeps an item attempted today on Today until it is passed" do
    progress(p2, next_review_at: now + 1.day, last_attempted_at: now - 1.hour, last_result: "failed")
    progress(p1, next_review_at: now - 1.day, last_attempted_at: now - 5.days, last_result: "passed")

    expect(today.problem).to have_attributes(exercise: p2, reason: :in_progress)
  end

  it "rotates warm-ups to the next category after the last one practiced" do
    progress(a1, next_review_at: now + 1.day, last_attempted_at: now - 1.day, last_result: "passed")

    expect(today.warmup.exercise).to eq(b1)
  end

  it "lists what was finished today" do
    progress(a1, next_review_at: now + 1.day, last_attempted_at: now - 1.hour, last_result: "passed")

    expect(today.done_today.map(&:exercise)).to eq([ a1 ])
  end

  it "returns nil when everything is done and nothing is due" do
    [ p1, p2 ].each { |exercise| progress(exercise, next_review_at: now + 3.days, last_attempted_at: now - 2.days, last_result: "passed") }

    expect(today.problem).to be_nil
  end
end
