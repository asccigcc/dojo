class Ledger
  Charge = Struct.new(:claim_id, :patient, :day, :seq, :remaining)
  BUCKETS = { "0-30" => 0..30, "31-60" => 31..60, "61-90" => 61..90, "90+" => 91.. }.freeze

  def initialize
    @charges = {}
    @credit = Hash.new(0)
  end

  def charge(patient, claim_id, amount, day)
    @charges[claim_id] = Charge.new(claim_id, patient, day, @charges.size, amount)
    apply_credit(patient)
  end

  def balance(patient) = open_for(patient).sum(&:remaining) - @credit[patient]

  def pay(patient, amount, _day)
    @credit[patient] += amount
    apply_credit(patient)
  end

  def open_charges(patient) = open_for(patient).map { |c| [c.claim_id, c.remaining] }

  def adjust(claim_id, amount)
    charge = @charges[claim_id] or return 0
    applied = [amount, charge.remaining].min
    charge.remaining -= applied
    applied
  end

  def aging(patient, today)
    BUCKETS.transform_values do |range|
      open_for(patient).select { |c| range.cover?(today - c.day) }.sum(&:remaining)
    end
  end

  private

  def open_for(patient)
    @charges.values.select { |c| c.patient == patient && c.remaining.positive? }.sort_by { |c| [c.day, c.seq] }
  end

  # Payments and credit are the same thing: money waiting to be applied oldest-first.
  def apply_credit(patient)
    open_for(patient).each do |charge|
      applied = [@credit[patient], charge.remaining].min
      charge.remaining -= applied
      @credit[patient] -= applied
    end
  end
end
