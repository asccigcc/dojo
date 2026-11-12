require "rails_helper"

RSpec.describe Progress do
  it "is due once the review date has passed" do
    progress = build(:progress, next_review_at: 1.minute.ago)

    expect(progress).to be_due
  end

  it "is not due when never scheduled" do
    expect(build(:progress, next_review_at: nil)).not_to be_due
  end

  it "is unique per user and exercise" do
    existing = create(:progress)

    expect(build(:progress, user: existing.user, exercise: existing.exercise)).not_to be_valid
  end
end
