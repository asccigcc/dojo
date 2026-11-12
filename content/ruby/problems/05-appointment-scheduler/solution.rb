class Scheduler
  Appointment = Struct.new(:id, :provider, :start, :finish)

  def initialize
    @appointments = {}
    @sequence = 0
  end

  def book(provider, start, duration)
    return nil unless free?(provider, start, start + duration)

    id = "A#{@sequence += 1}"
    @appointments[id] = Appointment.new(id, provider, start, start + duration)
    id
  end

  def cancel(id) = !@appointments.delete(id).nil?

  def schedule(provider) = for_provider(provider).map { |a| [a.start, a.finish] }.sort

  def next_available(provider, after, duration, day_end)
    candidates = [after] + for_provider(provider).map(&:finish).select { |f| f > after }
    candidates.sort.find do |start|
      start + duration <= day_end && free?(provider, start, start + duration)
    end
  end

  def book_any(providers, start, duration)
    open = providers.select { |p| free?(p, start, start + duration) }
    provider = open.min_by { |p| for_provider(p).size } or return nil
    [provider, book(provider, start, duration)]
  end

  private

  def for_provider(provider) = @appointments.values.select { |a| a.provider == provider }

  def free?(provider, start, finish)
    for_provider(provider).none? { |a| start < a.finish && a.start < finish }
  end
end
