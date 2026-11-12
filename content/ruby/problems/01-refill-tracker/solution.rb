class RefillTracker
  Rx = Struct.new(:id, :patient, :drug, :days_supply, :remaining, :last_fill)

  def initialize
    @rxs = {}
  end

  def add_prescription(id, patient, drug, days_supply, fills)
    @rxs[id] = Rx.new(id, patient, drug, days_supply, fills, nil)
  end

  def fill(id, day)
    rx = @rxs.fetch(id)
    return :no_refills if rx.remaining.zero?
    return :too_early if too_early?(rx, day)

    rx.remaining -= 1
    rx.last_fill = day
    :ok
  end

  def remaining(id) = @rxs.fetch(id).remaining

  def next_due(id) = due_day(@rxs.fetch(id))

  def overdue(today)
    late = @rxs.values.select { |rx| rx.remaining.positive? && due_day(rx)&.<(today) }
    late.sort_by { |rx| [due_day(rx), rx.id] }.map(&:id)
  end

  def patient_summary(patient)
    @rxs.values.select { |rx| rx.patient == patient }.to_h { |rx| [rx.drug, rx.remaining] }
  end

  private

  def due_day(rx) = rx.last_fill && rx.last_fill + rx.days_supply

  def too_early?(rx, day)
    rx.last_fill && day < rx.last_fill + (rx.days_supply * 0.75).ceil
  end
end
