require "rails_helper"

RSpec.describe ReviewSchedule do
  it "climbs the ladder 1, 3, 7, 14, 30 days and stays at the top" do
    schedule = described_class.new(nil)
    days = Array.new(6) { schedule = schedule.after_pass; schedule.days }

    expect(days).to eq([ 1, 3, 7, 14, 30, 30 ])
  end

  it "drops back to the start of the ladder on a fail" do
    failed = described_class.new(3).after_fail

    expect([ failed.interval_index, failed.days, failed.after_pass.days ]).to eq([ nil, 1, 1 ])
  end

  it "computes the due date" do
    from = Time.zone.local(2026, 11, 11, 9)

    expect(described_class.new(2).due_at(from)).to eq(Time.zone.local(2026, 11, 18, 9))
  end
end
